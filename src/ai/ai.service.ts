import { Injectable, Logger, Optional } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import * as http from 'http';
import { KnowledgeService } from '../knowledge/knowledge.service';
import { ProductService } from '../products/product.service';
import { Conversation, ConversationDocument } from './conversation.schema';

export type SupportedLanguage = 'fr' | 'en' | 'ar' | 'ar_tn';

const PYTHON_AI_HOST = 'localhost';
const PYTHON_AI_PORT = 8000;
const PYTHON_AI_PATH = '/ask';
const PYTHON_AI_TIMEOUT_MS = 60_000; // 60s — first request warms up Ollama model

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);

  constructor(
    private readonly knowledgeService: KnowledgeService,
    private readonly productService: ProductService,
    @Optional()
    @InjectModel(Conversation.name)
    private readonly conversationModel?: Model<ConversationDocument>,
  ) {}

  // ─── Language Detection ─────────────────────────────────────────────────────
  public detectLanguage(text: string): SupportedLanguage {
    const trimmed = text.trim();
    if (!trimmed) return 'fr';

    // Tunisian Arabic / Derja detection
    const derjaPatterns = [
      /\b(n7eb|kifesh|kifash|chneya|chnouwa|chounou|chkoun|3la|ya3tik|bch|mta3|ta3mel|n3ref|na3ref|na3mel|naamel|billehi|khater|taw|barcha|behi|labess)\b/i,
      /[\u0600-\u06FF]*?(شنوة|كيفاش|نحب|شكون|عصلامة|باهي|بربي|متاع|باش)[\u0600-\u06FF]*/,
    ];
    for (const pattern of derjaPatterns) {
      if (pattern.test(trimmed)) return 'ar_tn';
    }

    // Standard Arabic
    if (/[\u0600-\u06FF]/.test(trimmed)) return 'ar';

    // English
    const englishKw = ['what', 'how', 'which', 'where', 'why', 'who', 'is', 'are', 'can', 'help',
      'certificate', 'signature', 'price', 'cost', 'validity', 'requirements', 'documents', 'trust'];
    const lower = trimmed.toLowerCase();
    const words = lower.split(/\s+/);
    const enMatches = words.filter((w) => englishKw.includes(w.replace(/[^\w]/g, '')));
    if (enMatches.length >= 2 || (words.length <= 4 && enMatches.length >= 1)) return 'en';

    return 'fr';
  }

  // ─── Main Entry Point ───────────────────────────────────────────────────────
  async ask(question: string): Promise<string> {
    const trimmedQuestion = question.trim();
    if (!trimmedQuestion) {
      return 'Veuillez poser une question sur les produits, certificats ou services TunTrust.';
    }

    const lang = this.detectLanguage(trimmedQuestion);

    const [knowledgeEntries, productEntries] = await Promise.all([
      this.knowledgeService.search(trimmedQuestion),
      this.productService.findAll(),
    ]);

    const lowerQ = trimmedQuestion.toLowerCase();
    const queryWords = lowerQ.split(/\s+/).filter((w) => w.length > 2);
    const relevantProducts = productEntries.filter((p) => {
      const t = `${p.name} ${p.category} ${p.description || ''}`.toLowerCase();
      return queryWords.some((w) => t.includes(w));
    });

    const docTitles = knowledgeEntries.map((e) => `"${e.title}" (${e.source})`).join(', ') || 'None';
    const prodNames = relevantProducts.map((p) => `"${p.name}"`).join(', ') || 'None';

    this.logger.log(`\n${'='.repeat(60)}`);
    this.logger.log(`[AI AUDIT] User Message   : "${trimmedQuestion}"`);
    this.logger.log(`[AI AUDIT] Detected Lang  : ${lang.toUpperCase()}`);
    this.logger.log(`[AI AUDIT] MongoDB Docs   : [ ${docTitles} ]`);
    this.logger.log(`[AI AUDIT] Relevant Prods : [ ${prodNames} ]`);
    this.logger.log(`[AI AUDIT] Calling Python AI server → http://${PYTHON_AI_HOST}:${PYTHON_AI_PORT}${PYTHON_AI_PATH}`);

    let answer: string;
    try {
      answer = await this.callPythonAI(trimmedQuestion, lang, knowledgeEntries, relevantProducts);
    } catch (err: any) {
      const errMsg = err?.message ?? String(err);
      this.logger.error(`[AI AUDIT] Python AI server error: ${errMsg}`);
      answer = this.fallbackOfflineAnswer(lang);
    }

    this.logger.log(`[FINAL ANSWER] "${answer.slice(0, 200).replace(/\n/g, ' ')}${answer.length > 200 ? '...' : ''}"`);
    this.logger.log(`${'='.repeat(60)}\n`);

    return answer;
  }

  private buildMongoBackedAnswer(
    question: string,
    lang: SupportedLanguage,
    knowledgeEntries: Array<{ title: string; content: string }>,
    products: Array<{ name: string; description?: string; shortDescription?: string; category?: string }>,
  ): string {
    const normalizedQuestion = question.trim();
    const productContext = products.length > 0
      ? products
          .slice(0, 3)
          .map((p) => `- ${p.name} (${p.category || 'Produit'}): ${p.description || p.shortDescription || ''}`)
          .join('\n')
      : 'Aucun produit pertinent trouvé dans la base MongoDB.';

    const knowledgeContext = knowledgeEntries.length > 0
      ? knowledgeEntries
          .slice(0, 3)
          .map((doc) => `- ${doc.title}: ${doc.content.replace(/\s+/g, ' ').slice(0, 220)}`)
          .join('\n')
      : 'Aucune documentation pertinente n’a été trouvée.';

    switch (lang) {
      case 'en':
        return `Based on TunTrust MongoDB records, here is the best available answer:\n\n${productContext}\n\nSupporting documentation:\n${knowledgeContext}`;
      case 'ar':
        return `استنادًا إلى سجلات TunTrust في MongoDB، فيما يلي أفضل إجابة متاحة:\n\n${productContext}\n\nالوثائق الداعمة:\n${knowledgeContext}`;
      case 'ar_tn':
        return `بناء على سجلات TunTrust في MongoDB، هذي أحسن إجابة متوفرة:\n\n${productContext}\n\nالوثائق المساعدة:\n${knowledgeContext}`;
      default:
        return `D’après les informations disponibles dans MongoDB chez TunTrust, voici une réponse utile :\n\n${productContext}\n\nDocuments de support :\n${knowledgeContext}`;
    }
  }

  // ─── HTTP call to Python FastAPI ────────────────────────────────────────────
  private callPythonAI(
    question: string,
    language: SupportedLanguage,
    knowledgeEntries: Array<{ title: string; content: string; source?: string }>,
    products: Array<{ name: string; description?: string; shortDescription?: string; category?: string }>,
  ): Promise<string> {
    return new Promise((resolve, reject) => {
      const requestPayload = {
        question,
        language,
        context: {
          knowledgeEntries,
          products,
        },
      };

      const payload = JSON.stringify(requestPayload);

      this.logger.log(`[NEST -> PYTHON REQUEST] ${JSON.stringify({ question, language, knowledgeCount: knowledgeEntries.length, productCount: products.length })}`);

      const options: http.RequestOptions = {
        hostname: PYTHON_AI_HOST,
        port: PYTHON_AI_PORT,
        path: PYTHON_AI_PATH,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(payload),
        },
        timeout: PYTHON_AI_TIMEOUT_MS,
      };

      const req = http.request(options, (res) => {
        let body = '';
        res.on('data', (chunk) => { body += chunk; });
        res.on('end', () => {
          this.logger.log(`[PYTHON RESPONSE] HTTP ${res.statusCode} — ${body.slice(0, 300)}${body.length > 300 ? '...' : ''}`);
          try {
            if (res.statusCode && res.statusCode >= 400) {
              return reject(new Error(`Python AI server returned HTTP ${res.statusCode}: ${body}`));
            }
            const parsed = JSON.parse(body);
            if (typeof parsed?.answer === 'string') {
              resolve(parsed.answer);
            } else {
              reject(new Error(`Unexpected response format from Python AI: ${body}`));
            }
          } catch (e) {
            reject(new Error(`Failed to parse Python AI response: ${body}`));
          }
        });
      });

      req.on('timeout', () => {
        req.destroy();
        reject(new Error(`Python AI server timed out after ${PYTHON_AI_TIMEOUT_MS / 1000}s`));
      });

      req.on('error', (err) => {
        reject(new Error(`Cannot reach Python AI server on port ${PYTHON_AI_PORT}: ${err.message}`));
      });

      req.write(payload);
      req.end();
    });
  }

  // ─── Fallback when Python server is unreachable ─────────────────────────────
  private fallbackOfflineAnswer(lang: SupportedLanguage): string {
    switch (lang) {
      case 'en':
        return 'The AI assistant is temporarily unavailable. Please make sure the Python AI server is running (`uvicorn app:app --port 8000` in the tuntrust_ai folder) and try again.';
      case 'ar':
        return 'المساعد الذكي غير متاح حالياً. يرجى التأكد من تشغيل خادم الذكاء الاصطناعي Python وإعادة المحاولة.';
      case 'ar_tn':
        return 'المساعد ما موجودش الوقت هذا. خاصك تشغّل خادم Python الأول وبعد تعاود.';
      default:
        return "L'assistant IA est temporairement indisponible. Assurez-vous que le serveur Python AI est lancé (`uvicorn app:app --port 8000` dans le dossier tuntrust_ai) et réessayez.";
    }
  }

  // ─── Conversation Management ────────────────────────────────────────────────
  async createConversation(userId: string): Promise<ConversationDocument> {
    if (!this.conversationModel) {
      throw new Error('Le modèle de conversation n\'est pas disponible.');
    }
    if (!Types.ObjectId.isValid(userId)) {
      throw new Error('Identifiant utilisateur invalide.');
    }
    const created = new this.conversationModel({
      userId: new Types.ObjectId(userId),
      title: 'Nouvelle conversation',
      messages: [],
    });
    return created.save();
  }

  async getConversations(userId?: string): Promise<ConversationDocument[]> {
    if (!this.conversationModel) {
      throw new Error('Le modèle de conversation n\'est pas disponible.');
    }
    if (!userId || !Types.ObjectId.isValid(userId)) {
      return [];
    }
    return this.conversationModel
      .find({ userId: new Types.ObjectId(userId) })
      .sort({ updatedAt: -1 })
      .exec();
  }

  async getConversationById(id: string, userId?: string): Promise<ConversationDocument> {
    if (!this.conversationModel) {
      throw new Error('Le modèle de conversation n\'est pas disponible.');
    }
    if (!userId) {
      throw new Error('Identifiant utilisateur non fourni.');
    }
    if (!Types.ObjectId.isValid(id) || !Types.ObjectId.isValid(userId)) {
      throw new Error('Identifiants invalides.');
    }
    const conversation = await this.conversationModel
      .findOne({ _id: new Types.ObjectId(id), userId: new Types.ObjectId(userId) })
      .exec();
    if (!conversation) {
      throw new Error('Conversation introuvable.');
    }
    return conversation;
  }

  async deleteConversation(id: string, userId?: string): Promise<void> {
    if (!this.conversationModel) {
      throw new Error('Le modèle de conversation n\'est pas disponible.');
    }
    if (!userId) {
      throw new Error('Identifiant utilisateur non fourni.');
    }
    if (!Types.ObjectId.isValid(id) || !Types.ObjectId.isValid(userId)) {
      throw new Error('Identifiants invalides.');
    }
    const result = await this.conversationModel
      .deleteOne({ _id: new Types.ObjectId(id), userId: new Types.ObjectId(userId) })
      .exec();
    if (result.deletedCount === 0) {
      throw new Error('Impossible de supprimer la conversation ou introuvable.');
    }
  }

  async chat(
    question: string,
    conversationId?: string,
    userId?: string,
  ): Promise<{ answer: string; conversationId: string; title: string }> {
    let conversation: ConversationDocument;

    if (conversationId && userId) {
      conversation = await this.getConversationById(conversationId, userId);
    } else if (userId) {
      conversation = await this.createConversation(userId);
    } else {
      const answer = await this.ask(question);
      return { answer, conversationId: '', title: '' };
    }

    // Add user message
    conversation.messages.push({
      text: question,
      isUser: true,
      createdAt: new Date(),
    } as any);

    // Call existing ask logic
    const answer = await this.ask(question);

    // Add AI message
    conversation.messages.push({
      text: answer,
      isUser: false,
      createdAt: new Date(),
    } as any);

    // Auto generate title if it was default
    if (
      conversation.title === 'Nouvelle conversation' &&
      conversation.messages.filter((m) => m.isUser).length === 1
    ) {
      const firstUserMsg = conversation.messages.find((m) => m.isUser)?.text ?? question;
      conversation.title = this.generateTitle(firstUserMsg);
    }

    // Force Mongoose to recognize updates to nested array
    conversation.markModified('messages');
    await conversation.save();

    return {
      answer,
      conversationId: conversation._id.toString(),
      title: conversation.title,
    };
  }

  private generateTitle(text: string): string {
    const cleanText = text.trim();
    const words = cleanText.split(/\s+/);
    if (words.length <= 5) return cleanText;
    return words.slice(0, 5).join(' ') + '...';
  }
}
