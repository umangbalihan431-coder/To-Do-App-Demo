from django.contrib.auth import authenticate
from django.contrib.auth.models import User
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