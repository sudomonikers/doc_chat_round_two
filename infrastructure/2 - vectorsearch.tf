resource "aws_opensearchserverless_security_policy" "encryption_policy" {
  name        = "opensearch-encryption-policy"
  type        = "encryption"
  description = "encryption policy for ${local.collection_name}"
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${local.collection_name}"
        ],
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_security_policy" "network_policy" {
  name        = "network-policy"
  type        = "network"
  description = "VPC access for collection endpoint"
  policy = jsonencode([
    {
      Description = "VPC access for collection endpoint",
      Rules = [
        {
          ResourceType = "collection",
          Resource = [
            "collection/${local.collection_name}"
          ]
        }
      ],
      AllowFromPublic = true
      #ENABLE THIS WHEN USING VPC
      # AllowFromPublic = false,
      # SourceVPCEs = [
      #   aws_opensearchserverless_vpc_endpoint.vpc_endpoint.id
      # ]
    }
  ])
}

resource "aws_opensearchserverless_access_policy" "data_access_policy" {
  name        = "data-access-policy"
  type        = "data"
  description = "allow index and collection access"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [
            "index/${local.collection_name}/*"
          ],
          Permission = [
            "aoss:*"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/${local.collection_name}"
          ],
          Permission = [
            "aoss:*"
          ]
        }
      ],
      Principal = [
        "${aws_iam_role.lambda_role.arn}",
        "${data.aws_caller_identity.current.arn}"
      ]
    }
  ])
}

resource "aws_opensearchserverless_collection" "doc_search_collection" {
  name = local.collection_name
  type = "VECTORSEARCH"

  depends_on = [
    aws_opensearchserverless_security_policy.encryption_policy,
    aws_opensearchserverless_security_policy.network_policy,
    aws_opensearchserverless_access_policy.data_access_policy
  ]
}

#ENABLE THIS WHEN USING VPC
# resource "aws_opensearchserverless_vpc_endpoint" "vpc_endpoint" {
#   name       = "doc-search-endpoint"
#   subnet_ids = [aws_subnet.doc_search_vpc.id]
#   vpc_id     = aws_vpc.doc_search_vpc.id
#   security_group_ids = [aws_security_group.opensearch_security_group.id]
# }

resource "null_resource" "create_index_mapping" {
  depends_on = [aws_opensearchserverless_collection.doc_search_collection]

  # You can use the local-exec provisioner to execute a shell command.
  provisioner "local-exec" {
    command = <<EOT
      sts_output=$(aws sts get-session-token)
      AWS_SESSION_TOKEN=$(echo "$sts_output" | jq -r .Credentials.SessionToken)
      AWS_ACCESS_KEY_ID=$(echo "$sts_output" | jq -r .Credentials.AccessKeyId)
      AWS_SECRET_ACCESS_KEY=$(echo "$sts_output" | jq -r .Credentials.SecretAccessKey)

      curl -X PUT "${aws_opensearchserverless_collection.doc_search_collection.collection_endpoint}/${local.index_name}" \
            --verbose \
            --user "$AWS_ACCESS_KEY_ID":"$AWS_SECRET_ACCESS_KEY" \
            --aws-sigv4 "aws:amz:us-east-2:aoss" \
            --header "x-amz-security-token: $AWS_SESSION_TOKEN" \
            --header "x-amz-content-sha256: UNSIGNED_PAYLOAD" \
            --header "Content-Type: application/json" \
            --data-binary @- <<EOF 
            {
              "settings": {
                "index": {
                  "knn": true,
                  "knn.algo_param.ef_search": 512
                }
              },
              "mappings": {
                "properties": {
                  "doc_vector": {
                    "type": "knn_vector",
                    "dimension": 384,
                    "method": {
                      "name": "hnsw",
                      "engine": "faiss",
                      "parameters": {},
                      "space_type": "innerproduct"
                    }
                  },
                  "doc_title": {
                    "type": "text",
                    "index": "true"
                  },
                  "doc_text": {
                    "type": "text",
                    "index": "false"
                  },
                  "doc_type": {
                    "type": "text",
                    "index": "true"
                  },
                  "doc_date_added": {
                    "type": "date",
                    "index": "false"
                  }
                }
              }
            }
      EOF
    EOT
  }
}
