import os
import uuid
from pathlib import Path

import boto3
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent
env_path = BASE_DIR / ".env"

load_dotenv(dotenv_path=env_path, override=True)

AWS_ACCESS_KEY_ID = os.environ.get("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.environ.get("AWS_SECRET_ACCESS_KEY")
AWS_STORAGE_BUCKET_NAME = os.environ.get("AWS_STORAGE_BUCKET_NAME")
AWS_S3_REGION_NAME = os.environ.get("AWS_S3_REGION_NAME", "ap-south-1")

print("S3 ENV PATH =", env_path)
print("S3 AWS KEY =", AWS_ACCESS_KEY_ID)

if AWS_ACCESS_KEY_ID is None:
    raise Exception("AWS_ACCESS_KEY_ID is missing")

if AWS_SECRET_ACCESS_KEY is None:
    raise Exception("AWS_SECRET_ACCESS_KEY is missing")

if AWS_STORAGE_BUCKET_NAME is None:
    raise Exception("AWS_STORAGE_BUCKET_NAME is missing")

s3_client = boto3.client(
    "s3",
    region_name=AWS_S3_REGION_NAME,
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
)


def upload_image_to_s3(image_file, user_email):
    extension = os.path.splitext(image_file.name)[1] or ".jpg"
    safe_email = user_email.replace("@", "_").replace(".", "_")

    s3_key = f"user-images/{safe_email}/{uuid.uuid4().hex}{extension}"

    s3_client.upload_fileobj(
        image_file,
        AWS_STORAGE_BUCKET_NAME,
        s3_key,
        ExtraArgs={
            "ContentType": image_file.content_type or "image/jpeg",
        },
    )

    image_url = (
        f"https://{AWS_STORAGE_BUCKET_NAME}.s3."
        f"{AWS_S3_REGION_NAME}.amazonaws.com/{s3_key}"
    )

    return image_url, s3_key