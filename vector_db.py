import pickle
import chromadb
from sentence_transformers import SentenceTransformer


print("Loading embeddings...")


with open(
    "embeddings.pkl",
    "rb"
) as f:

    data = pickle.load(f)



chunks = data["chunks"]
embeddings = data["embeddings"]



print(
    "Chunks loaded:",
    len(chunks)
)



client = chromadb.PersistentClient(
    path="./chroma_db"
)



# delete old collection if exists

try:

    client.delete_collection(
        "tuntrust"
    )

except:

    pass



collection = client.create_collection(
    name="tuntrust"
)



collection.add(

    ids=[
        str(i)
        for i in range(len(chunks))
    ],

    documents=chunks,

    embeddings=[
        embedding.tolist()
        for embedding in embeddings
    ]

)



print(
    "Vectors stored successfully"
)



# test search

result = collection.query(

    query_texts=[
        "What is ID Trust?"
    ],

    n_results=3

)


print(result)