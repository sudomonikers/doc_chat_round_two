import sagemaker
from sagemaker.huggingface import HuggingFaceModel, get_huggingface_llm_image_uri
import time

sagemaker_session = sagemaker.Session()
print(sagemaker_session)
region = sagemaker_session.boto_region_name
role = 'arn:aws:iam::145880140878:role/service-role/AmazonSageMaker-ExecutionRole-20230823T213585'
print(role)
image_uri = get_huggingface_llm_image_uri(
  backend="huggingface", # or lmi
  region=region
)

model_name = "falcon-7b-" + time.strftime("%Y-%m-%d-%H-%M-%S", time.gmtime())

hub = {
    'HF_MODEL_ID':'tiiuae/falcon-7b',
    'HF_TASK':'text-generation',
    'SM_NUM_GPUS':'1' # Setting to 1 because sharding is not supported for this model
}

model = HuggingFaceModel(
    name=model_name,
    env=hub,
    role=role,
    image_uri=image_uri
)

predictor = model.deploy(
    initial_instance_count=1,
    instance_type="ml.g5.2xlarge",
    endpoint_name=model_name
)

input_data = {
  "inputs": "The diamondback terrapin was the first reptile to",
  "parameters": {
    "do_sample": True,
    "max_new_tokens": 100,
    "temperature": 0.7,
    "watermark": True
  }
}

response = predictor.predict(input_data)

print(response)