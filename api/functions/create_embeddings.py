from typing import List
from sentence_transformers import SentenceTransformer

model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')

def get_embeddings(text: List[str]) -> List[List[float]]:
    """
    This function takes a list of strings and returns a list of lists of floats.
    Each list of floats is a 384-dimensional vector representing the embedding of the corresponding string.
    """
    vectors = []
    for chunk in text:
        vectors.append(model.encode(chunk))
    return vectors


if __name__ == "__main__":
    #example usage
    sentences = ["This is an example sentence", "Each sentence is converted"]
    print(get_embeddings(sentences))