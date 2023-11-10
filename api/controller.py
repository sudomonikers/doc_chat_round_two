from opensearchpy import OpenSearch, RequestsHttpConnection, AWSV4SignerAuth
import boto3
import datetime
import os

from functions.create_embeddings import get_embeddings
from functions.text_splitter import split_into_overlapping_chunks

client = boto3.client('opensearchserverless', region_name='us-east-2')
credentials = boto3.Session().get_credentials()
auth = AWSV4SignerAuth(credentials, 'us-east-2', 'aoss')
host = os.getenv('OPEN_SEARCH_ENDPOINT') #'jxqf7aupk0fvdcgh7u2.us-east-2.aoss.amazonaws.com'

def indexData(text: str, doc_type: str, doc_title):
    client = OpenSearch(
        hosts=[{'host': host, 'port': 443}],
        http_auth=auth,
        use_ssl=True,
        verify_certs=True,
        connection_class=RequestsHttpConnection,
        timeout=10
    )

    chunks = split_into_overlapping_chunks(text)
    vectors = get_embeddings(chunks)
    for index, vector in enumerate(vectors):
        document_body = {
            'doc_vector': vector,
            'doc_title': doc_title,
            'doc_text': chunks[index],
            'doc_type': doc_type,
            'doc_date_added': datetime.datetime.now()
        }
        client.index(index='doc-chat-index', body=document_body)

    return True


if __name__ == "__main__":
    indexData('hey this is some random text')