from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from bson import ObjectId

from db import todos_collection, fcm_tokens_collection
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

    if User.objects.filter(username=email).exists():
        return Response({'error': 'User already exists'}, status=400)

    user = User.objects.create_user(
        username=email,
        email=email,
        password=password
    )

    return Response({
        'message': 'User created successfully',
        'email': user.email,
    }, status=201)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_user(request):
    email = request.data.get('email')
    password = request.data.get('password')

    user = authenticate(username=email, password=password)

    if user is None:
        return Response({'error': 'Invalid email or password'}, status=401)

    refresh = RefreshToken.for_user(user)

    return Response({
        'access': str(refresh.access_token),
        'refresh': str(refresh),
        'email': user.email,
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