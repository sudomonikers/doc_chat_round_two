resource "aws_s3_bucket" "model_bucket" {
  bucket = "doc-search-model-bucket"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.model_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# create this later once the model is figured out
# resource "aws_s3_object" "model" {
#   bucket = aws_s3_bucket.model_bucket.id
#   key    = "doc_search_model"
#   source = "../ml_model.tar.gz"

#   etag = filemd5("path/to/file")
# }
