import ollama
import chromadb
from sentence_transformers import SentenceTransformer



print("Loading AI...")

model = SentenceTransformer(
    "sentence-transformers/all-MiniLM-L6-v2"
)



client = chromadb.PersistentClient(
    path="./chroma_db"
)



collection = client.get_collection(
    "tuntrust"
)



def search_knowledge(question):

    query_embedding = model.encode(
        question
    )


    result = collection.query(

        query_embeddings=[
            query_embedding.tolist()
        ],

        n_results=5

    )


    return "\n\n".join(
        result["documents"][0]
    )





def ask(question):


    # greetings

    greetings = [
        "hi",
        "hello",
        "bonjour",
        "salut",
        "hey"
    ]


    if question.lower().strip() in greetings:

        return (
            "Bonjour 👋 Je suis TunTrust AI Assistant. "
            "Je peux vous aider avec les produits, "
            "certificats électroniques et solutions TunTrust."
        )



    context = search_knowledge(
        question
    )


    prompt = f"""

You are TunTrust AI Assistant.

Answer the user using the information below.

Rules:
- You are a mobile application assistant.
- Keep answers short and easy to read.
- Start with a direct answer.
- Use bullet points when possible.
- Maximum 8 lines unless the user asks for details.
- Do not write long paragraphs.
- Do not repeat the question.
- If useful, ask if the user wants more details.
- Never mention databases, embeddings or AI.

Information:

{context}


Question:

{question}


Answer:

"""


    response = ollama.chat(

        model="qwen2.5:3b",

        messages=[
            {
                "role":"user",
                "content":prompt
            }
        ]

    )


    return response["message"]["content"]





if __name__ == "__main__":


    print("🤖 TunTrust AI ready")
    print("Type exit to stop\n")


    while True:


        question = input("You: ")


        if question.lower()=="exit":

            break


        answer = ask(question)


        print(
            "\nTunTrust AI:",
            answer,
            "\n"
        )