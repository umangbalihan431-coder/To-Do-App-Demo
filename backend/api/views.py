from django.contrib.auth.models import User
from django.contrib.auth.hashers import make_password, check_password
from bson import ObjectId
from db import (
    users_collection,
    todos_collection,
    fcm_tokens_collection,
    images_collection,
)
from s3 import upload_image_to_s3
from datetime import datetime, timezone
from firebase_admin import messaging
import firebase_config

from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken


@api_view(['POST'])
@permission_classes([AllowAny])
def register_user(request):
    email = request.data.get('email')
    password = request.data.get('password')

    if not email or not password:
        return Response({'error': 'Email and password required'}, status=400)

    existing_user = users_collection.find_one({"email": email})

    if existing_user:
        return Response({'error': 'User already exists'}, status=400)

    users_collection.insert_one({
        "email": email,
        "password": make_password(password),
    })

    User.objects.get_or_create(
        username=email,
        defaults={"email": email}
    )

    return Response({
        'message': 'User created successfully',
        'email': email,
    }, status=201)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_user(request):
    email = request.data.get('email')
    password = request.data.get('password')

    if not email or not password:
        return Response({'error': 'Email and password required'}, status=400)

    mongo_user = users_collection.find_one({"email": email})

    if not mongo_user:
        return Response({'error': 'User not found. Please register first.'}, status=401)

    if not check_password(password, mongo_user["password"]):
        return Response({'error': 'Invalid email or password'}, status=401)

    django_user, created = User.objects.get_or_create(
        username=email,
        defaults={"email": email}
    )

    if created:
        django_user.set_unusable_password()
        django_user.save()

    refresh = RefreshToken.for_user(django_user)

    return Response({
        'access': str(refresh.access_token),
        'refresh': str(refresh),
        'email': email,
    }, status=200)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def protected_test(request):
    return Response({
        'message': 'JWT is working',
        'user': request.user.email,
    })


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def todos(request):
    user_email = request.user.email

    if request.method == 'GET':
        user_todos = list(todos_collection.find({"user_email": user_email}))

        for todo in user_todos:
            todo["_id"] = str(todo["_id"])

        return Response(user_todos, status=200)

    if request.method == 'POST':
        task_name = request.data.get("task_name")

        if not task_name:
            return Response({"error": "Task name is required"}, status=400)

        todo = {
            "user_email": user_email,
            "task_name": task_name,
            "completed": False,
        }

        result = todos_collection.insert_one(todo)
        todo["_id"] = str(result.inserted_id)

        token_doc = fcm_tokens_collection.find_one({
            "user_email": user_email
        })

        if token_doc:
            try:
                message = messaging.Message(
                    notification=messaging.Notification(
                        title="New Task Added ✅",
                        body=task_name,
                    ),
                    token=token_doc["fcm_token"],
                )

                response = messaging.send(message)
                print("Notification sent:", response)

            except Exception as e:
                print("Notification error:", e)

        return Response(todo, status=201)


@api_view(['PUT', 'DELETE'])
@permission_classes([IsAuthenticated])
def todo_detail(request, todo_id):
    user_email = request.user.email

    try:
        object_id = ObjectId(todo_id)
    except Exception:
        return Response({"error": "Invalid todo ID"}, status=400)

    todo = todos_collection.find_one({
        "_id": object_id,
        "user_email": user_email,
    })

    if todo is None:
        return Response({"error": "Todo not found"}, status=404)

    if request.method == 'PUT':
        completed = request.data.get("completed")

        todos_collection.update_one(
            {"_id": object_id},
            {"$set": {"completed": completed}}
        )

        return Response({"message": "Todo updated"}, status=200)

    if request.method == 'DELETE':
        todos_collection.delete_one({"_id": object_id})

        return Response({"message": "Todo deleted"}, status=200)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def save_fcm_token(request):
    user_email = request.user.email
    fcm_token = request.data.get("fcm_token")

    if not fcm_token:
        return Response({"error": "FCM token is required"}, status=400)

    fcm_tokens_collection.update_one(
        {"user_email": user_email},
        {
            "$set": {
                "user_email": user_email,
                "fcm_token": fcm_token,
            }
        },
        upsert=True
    )

    return Response({
        "message": "FCM token saved successfully",
        "user_email": user_email,
    }, status=200)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def upload_image(request):
    user_email = request.user.email
    image_file = request.FILES.get("image")

    if not image_file:
        return Response({"error": "Image file is required"}, status=400)

    try:
        image_url, s3_key = upload_image_to_s3(image_file, user_email)

        image_doc = {
            "user_email": user_email,
            "image_url": image_url,
            "s3_key": s3_key,
            "created_at": datetime.now(timezone.utc).isoformat(),
        }

        result = images_collection.insert_one(image_doc)
        image_doc["_id"] = str(result.inserted_id)

        return Response(image_doc, status=201)

    except Exception as e:
        return Response({"error": str(e)}, status=500)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_images(request):
    user_email = request.user.email

    images = list(
        images_collection.find({"user_email": user_email}).sort("created_at", -1)
    )

    for image in images:
        image["_id"] = str(image["_id"])

    return Response(images, status=200)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_image(request, image_id):
    user_email = request.user.email

    try:
        object_id = ObjectId(image_id)
    except Exception:
        return Response({"error": "Invalid image ID"}, status=400)

    image = images_collection.find_one({
        "_id": object_id,
        "user_email": user_email,
    })

    if image is None:
        return Response({"error": "Image not found"}, status=404)

    images_collection.delete_one({"_id": object_id})

    return Response({"message": "Image deleted"}, status=200)