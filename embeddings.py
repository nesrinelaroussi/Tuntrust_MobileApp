import os
import pickle

from sentence_transformers import SentenceTransformer


DATA_FOLDER = "clean_data"


print("Loading embedding model...")


model = SentenceTransformer(
    "sentence-transformers/all-MiniLM-L6-v2"
)



documents = []


for filename in os.listdir(DATA_FOLDER):

    if filename.endswith(".md"):

        path = os.path.join(
            DATA_FOLDER,
            filename
        )


        with open(
            path,
            "r",
            encoding="utf-8"
        ) as file:

            text = file.read()


            if len(text.strip()) > 50:

                documents.append(text)



print(
    "Documents loaded:",
    len(documents)
)



chunks = []


for doc in documents:

    words = doc.split()

    chunk_size = 150

    overlap = 30


    for i in range(
        0,
        len(words),
        chunk_size - overlap
    ):

        chunk = " ".join(
            words[i:i + chunk_size]
        )


        if len(chunk) > 100:

            chunks.append(
                chunk
            )


print(
    "Chunks:",
    len(chunks)
)



print("Generating embeddings...")


embeddings = model.encode(
    chunks,
    show_progress_bar=True
)



with open(
    "embeddings.pkl",
    "wb"
) as f:

    pickle.dump(

        {
            "chunks": chunks,
            "embeddings": embeddings
        },

        f

    )



print(
    "Embedding generation completed"
)