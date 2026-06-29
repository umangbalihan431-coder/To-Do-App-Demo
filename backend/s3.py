import os
import uuid
from pathlib import Path

import boto3
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env", override=True)

AWS_ACCESS_KEY_ID = os.environ.get("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.environ.get("AWS_SECRET_ACCESS_KEY")
AWS_STORAGE_BUCKET_NAME = os.environ.get("AWS_STORAGE_BUCKET_NAME")
AWS_S3_REGION_NAME = os.environ.get("AWS_S3_REGION_NAME", "ap-south-1")

s3_client = boto3.client(
    "s3",
    region_name=AWS_S3_REGION_NAME,
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
)


def upload_file_to_s3(file_obj, user_email, folder="user-media"):
    extension = os.path.splitext(file_obj.name)[1] or ""
    safe_email = user_email.replace("@", "_").replace(".", "_")
    file_name = f"{uuid.uuid4().hex}{extension}"
    s3_key = f"{folder}/{safe_email}/{file_name}"

    s3_client.upload_fileobj(
        file_obj,
        AWS_STORAGE_BUCKET_NAME,
        s3_key,
        ExtraArgs={
            "ContentType": getattr(file_obj, "content_type", None)
            or "application/octet-stream",
        },
    )

    file_url = (
        f"https://{AWS_STORAGE_BUCKET_NAME}.s3."
        f"{AWS_S3_REGION_NAME}.amazonaws.com/{s3_key}"
    )

    return file_url, s3_key


def upload_image_to_s3(image_file, user_email):
    return upload_file_to_s3(
        file_obj=image_file,
        user_email=user_email,
        folder="user-images",
    )