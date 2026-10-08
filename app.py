"""
TunTrust AI FastAPI Server
--------------------------
Wraps ChromaDB semantic search + Ollama qwen2.5:3b as an HTTP service.
NestJS calls POST /ask to get real AI-generated answers.

Start with:
  .\\venv\\Scripts\\python.exe -m uvicorn app:app --host 0.0.0.0 --port 8000 --reload

ROOT CAUSE FIX (2026-08-19):
  The original sync `def ask()` endpoint ran inside uvicorn's threadpool executor.
  When ollama.chat() (which internally uses httpx sync) was called from that thread,
  the combination of the threadpool + Ollama's llama-server cold-start caused a
  Windows CUDA shared-object initialization race → 0xc0000409 crash.

  Fix: use `async def ask()` + `ollama.AsyncClient` so the Ollama HTTP call is
  a proper async I/O operation, never blocking the event loop or a sync thread.
  Greeting bypass removed — greetings go through the model like any other input.
"""

import logging
import asyncio
from contextlib import asynccontextmanager
from typing import List, Optional

import chromadb
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer
import ollama

# ── constants ──────────────────────────────────────────────────────────────────
OLLAMA_MODEL = "qwen2.5:3b"
CHROMA_COLLECTION_NAME = "tuntrust"
CHROMA_DB_PATH = "./chroma_db"
EMBED_MODEL_NAME = "sentence-transformers/all-MiniLM-L6-v2"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger("tuntrust-ai")

# ── global singletons (loaded once at startup) ─────────────────────────────────
EMBED_MODEL: SentenceTransformer = None
COLLECTION = None
ASYNC_OLLAMA: ollama.AsyncClient = None


# ── lifespan: load heavy models once, pre-warm Ollama ──────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    global EMBED_MODEL, COLLECTION, ASYNC_OLLAMA

    logger.info("[STARTUP] Loading SentenceTransformer embedding model...")
    EMBED_MODEL = SentenceTransformer(EMBED_MODEL_NAME)
    logger.info(f"[STARTUP] Embedding model loaded: {EMBED_MODEL_NAME}")

    logger.info("[STARTUP] Connecting to ChromaDB...")
    chroma_client = chromadb.PersistentClient(path=CHROMA_DB_PATH)
    try:
        COLLECTION = chroma_client.get_collection(CHROMA_COLLECTION_NAME)
        logger.info(f"[STARTUP] ChromaDB collection '{CHROMA_COLLECTION_NAME}' loaded — {COLLECTION.count()} chunks.")
    except Exception as e:
        logger.warning(f"[STARTUP] WARNING: Could not load ChromaDB collection: {e}")
        COLLECTION = None

    # Use AsyncClient so all Ollama calls are non-blocking async HTTP
    ASYNC_OLLAMA = ollama.AsyncClient()
    logger.info(f"[STARTUP] Ollama AsyncClient created. Model: {OLLAMA_MODEL}")

    # Pre-warm: send a trivial request so llama-server initialises its CUDA
    # context before the first real user request arrives.
    logger.info("[STARTUP] Pre-warming Ollama model (cold-start prevention)...")
    try:
        warm_response = await ASYNC_OLLAMA.chat(
            model=OLLAMA_MODEL,
            messages=[{"role": "user", "content": "ping"}],
            keep_alive=-1,   # keep model loaded indefinitely from startup
        )
        logger.info(f"[STARTUP] Ollama pre-warm OK: '{warm_response.message.content.strip()[:60]}'")
    except Exception as e:
        logger.warning(f"[STARTUP] Ollama pre-warm failed (server may not be running yet): {e}")

    logger.info("[STARTUP] TunTrust AI server ready.")
    yield
    logger.info("[SHUTDOWN] TunTrust AI server stopped.")


# ── FastAPI app ────────────────────────────────────────────────────────────────
app = FastAPI(title="TunTrust AI", version="2.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── request / response schemas ─────────────────────────────────────────────────
class KnowledgeEntry(BaseModel):
    title: str
    content: str
    source: Optional[str] = None


class ProductEntry(BaseModel):
    name: str
    description: Optional[str] = None
    shortDescription: Optional[str] = None
    category: Optional[str] = None


class AskContext(BaseModel):
    knowledgeEntries: Optional[List[KnowledgeEntry]] = []
    products: Optional[List[ProductEntry]] = []


class AskRequest(BaseModel):
    question: str
    language: str = "fr"   # fr | en | ar | ar_tn
    context: Optional[AskContext] = None


class AskResponse(BaseModel):
    answer: str
    retrieved_chunks: int
    model: str


# ── language instructions ──────────────────────────────────────────────────────
LANG_INSTRUCTIONS = {
    "fr":    "Tu DOIS répondre en français.",
    "en":    "You MUST answer in English.",
    "ar":    "يجب أن تُجيب باللغة العربية الفصحى.",
    "ar_tn": "يجب أن تُجيب باللهجة التونسية (الدارجة).",
}


# ── helpers ────────────────────────────────────────────────────────────────────
def search_chroma(question: str, n: int = 5) -> tuple[str, int]:
    """Query ChromaDB with semantic embedding search. Returns (context_str, chunk_count)."""
    if COLLECTION is None:
        logger.warning("[RETRIEVAL] ChromaDB collection not available — skipping vector search.")
        return "", 0
    embedding = EMBED_MODEL.encode(question).tolist()
    result = COLLECTION.query(query_embeddings=[embedding], n_results=n)
    docs = result.get("documents", [[]])[0]
    logger.info(f"[RETRIEVAL] Retrieved {len(docs)} ChromaDB chunks for: '{question}'")
    for i, doc in enumerate(docs):
        logger.info(f"  Chunk {i+1}: {doc[:120].replace(chr(10), ' ')}...")
    return "\n\n---\n\n".join(docs), len(docs)


def build_mongo_context(ctx: AskContext) -> str:
    """Format NestJS-provided MongoDB context (knowledgeEntries + products) as plain text."""
    parts = []
    if ctx.knowledgeEntries:
        knowledge_lines = "\n".join(
            f"[{e.title}] {e.content[:400]}" for e in ctx.knowledgeEntries[:5]
        )
        parts.append(f"=== Documentation TunTrust ===\n{knowledge_lines}")
    if ctx.products:
        product_lines = "\n".join(
            f"- {p.name} ({p.category or 'Produit'}): {p.description or p.shortDescription or 'N/A'}"
            for p in ctx.products[:5]
        )
        parts.append(f"=== Produits TunTrust ===\n{product_lines}")
    return "\n\n".join(parts)


def build_prompt(question: str, context: str, language: str) -> str:
    """
    Build the Ollama prompt. The model is instructed to answer ONLY from the
    provided context and never fabricate information.
    """
    lang_instruction = LANG_INSTRUCTIONS.get(language, LANG_INSTRUCTIONS["fr"])

    if context.strip():
        return f"""Tu es l'assistant officiel de TunTrust, l'Agence Nationale de Certification Électronique tunisienne.

{lang_instruction}

RÈGLES STRICTES — respecte-les ABSOLUMENT:
1. Réponds UNIQUEMENT en te basant sur le contexte documentaire ci-dessous.
2. N'invente AUCUNE information qui ne figure pas dans ce contexte.
3. Si la réponse n'est pas dans le contexte, dis honnêtement: "Je n'ai pas cette information dans ma base de connaissances."
4. Sois concis et direct — maximum 10 lignes sauf si l'utilisateur demande des détails.
5. Utilise des points (•) pour les listes.
6. Ne mentionne jamais les bases de données, embeddings, RAG ou IA interne.
7. Ne répète pas la question.

CONTEXTE DOCUMENTAIRE TUNTRUST:
{context}

QUESTION DE L'UTILISATEUR: {question}

RÉPONSE:"""
    else:
        # No context retrieved — be honest rather than hallucinating
        return f"""Tu es l'assistant officiel de TunTrust, l'Agence Nationale de Certification Électronique tunisienne.

{lang_instruction}

RÈGLES STRICTES:
1. N'invente AUCUNE information.
2. Si tu ne disposes pas d'informations spécifiques, dis-le clairement.
3. Tu peux proposer à l'utilisateur de reformuler sa question sur: les certificats ID-Trust, Enterprise-ID, SSL (Wildcard, SAN, Organisation), la signature de code, VPN, Tunsign ou Digigo.

QUESTION DE L'UTILISATEUR: {question}

RÉPONSE:"""


# ── endpoints ──────────────────────────────────────────────────────────────────
@app.get("/health")
async def health():
    return {
        "status": "ok",
        "model": OLLAMA_MODEL,
        "chroma_chunks": COLLECTION.count() if COLLECTION else 0,
        "ollama_client": "AsyncClient",
    }


@app.post("/ask", response_model=AskResponse)
async def ask(req: AskRequest):
    """
    Main RAG endpoint.
    Uses async/await throughout to avoid blocking uvicorn's event loop
    and to prevent the Windows CUDA init crash (0xc0000409) that occurred
    when calling Ollama synchronously from a threadpool worker.
    """
    question = req.question.strip()
    language = req.language or "fr"

    logger.info(f"\n{'='*60}")
    logger.info(
        f"[NEST -> PYTHON REQUEST] question='{question}' language={language} "
        f"knowledgeEntries={len(req.context.knowledgeEntries) if req.context else 0} "
        f"products={len(req.context.products) if req.context else 0}"
    )

    if not question:
        raise HTTPException(status_code=400, detail="Question cannot be empty.")

    # ── Step 1: ChromaDB semantic retrieval (runs in executor to not block event loop) ──
    chroma_context, chunk_count = await asyncio.get_event_loop().run_in_executor(
        None, search_chroma, question
    )

    # ── Step 2: Merge with MongoDB context from NestJS ──
    mongo_context = build_mongo_context(req.context) if req.context else ""
    context_parts = [p for p in [chroma_context, mongo_context] if p.strip()]
    combined_context = "\n\n".join(context_parts)

    logger.info(
        f"[CONTEXT] ChromaDB chunks: {chunk_count} | "
        f"MongoDB knowledge: {len(req.context.knowledgeEntries) if req.context else 0} | "
        f"MongoDB products: {len(req.context.products) if req.context else 0}"
    )

    # ── Step 3: Build prompt ──
    prompt = build_prompt(question, combined_context, language)

    # Log the full prompt for debugging (shows exactly what Ollama receives)
    logger.info(f"[PROMPT SENT TO OLLAMA]\n{'-'*40}\n{prompt}\n{'-'*40}")

    # ── Step 4: Call Ollama asynchronously (no threadpool, no blocking) ──
    logger.info(f"[OLLAMA] Sending async request to model '{OLLAMA_MODEL}'...")
    try:
        response = await ASYNC_OLLAMA.chat(
            model=OLLAMA_MODEL,
            messages=[{"role": "user", "content": prompt}],
            keep_alive=-1,   # keep model loaded in VRAM indefinitely between requests
        )
        answer = response.message.content.strip()
    except Exception as e:
        logger.error(f"[OLLAMA ERROR] {type(e).__name__}: {e}")
        raise HTTPException(status_code=503, detail=f"Ollama error: {str(e)}")

    logger.info(f"[PYTHON RESPONSE] Answer ({len(answer)} chars): {answer[:300].replace(chr(10), ' ')}{'...' if len(answer) > 300 else ''}")
    logger.info(f"{'='*60}\n")

    return AskResponse(
        answer=answer,
        retrieved_chunks=chunk_count,
        model=OLLAMA_MODEL,
    )
