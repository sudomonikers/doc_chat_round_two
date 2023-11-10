# ------------------------------------------------------------------------------
# IAM role
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "sagemaker" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sagemaker" {
  name               = "sagemaker-execution-role"
  assume_role_policy = data.aws_iam_policy_document.sagemaker.json
}

resource "aws_iam_role_policy_attachment" "sagemaker" {
  role       = aws_iam_role.sagemaker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}


# # ------------------------------------------------------------------------------
# # Sagemaker model
# # ------------------------------------------------------------------------------
# resource "aws_sagemaker_model" "model" {
#   name               = local.hugging_face_model_id
#   execution_role_arn = aws_iam_role.sagemaker.arn

#   primary_container {
#     image = local.inference_image
#     environment = {
#       HF_MODEL_ID                   = local.hugging_face_model_id
#       HUGGING_FACE_HUB_TOKEN        = local.hugging_face_hub_token
#       SM_NUM_GPUS                   = local.sagemaker_endpoint_instance_gpus
#       MAX_INPUT_LENGTH              = local.hugging_face_model_max_input_length
#       MAX_TOTAL_TOKENS              = local.hugging_face_model_max_total_tokens
#       SAGEMAKER_CONTAINER_LOG_LEVEL = 20
#       SAGEMAKER_REGION              = local.sagemaker_region
#     }
#   }
# }


# # ------------------------------------------------------------------------------
# # Sagemaker Endpoint
# # ------------------------------------------------------------------------------
# resource "aws_sagemaker_endpoint_configuration" "huggingface" {
#   name = "${local.sagemaker_inference_endpoint_name}-config"

#   production_variants {
#     variant_name                                      = "AllTraffic"
#     container_startup_health_check_timeout_in_seconds = 300
#     model_name                                        = aws_sagemaker_model.model.name
#     initial_instance_count                            = local.aws_sagemaker_endpoint_initial_instance_count
#     instance_type                                     = local.aws_sagemaker_endpoint_instance_type
#   }
# }

# resource "aws_sagemaker_endpoint" "huggingface" {
#   name                 = local.sagemaker_inference_endpoint_name
#   endpoint_config_name = aws_sagemaker_endpoint_configuration.huggingface.name
# }