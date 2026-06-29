from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    register_user,
    login_user,
    protected_test,
    todos,
    todo_detail,
    save_fcm_token,
    upload_image,
    user_images,
    delete_image,
    upload_media,
    user_media,
)

urlpatterns = [
    path('register/', register_user),
    path('login/', login_user),
    path('protected/', protected_test),
    path('token/refresh/', TokenRefreshView.as_view()),

    path('upload-media/', upload_media),
path('user-media/', user_media),

    path('todos/', todos),
    path('todos/<str:todo_id>/', todo_detail),

    path('save-fcm-token/', save_fcm_token),

    path('upload-image/', upload_image),
    path('user-images/', user_images),
    path('user-images/<str:image_id>/', delete_image),
]