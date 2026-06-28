from django.urls import path
from .views import (
    register_user,
    login_user,
    protected_test,
    todos,
    todo_detail,
    save_fcm_token,
    upload_image,
    user_images,
)

urlpatterns = [
    path('register/', register_user),
    path('login/', login_user),
    path('protected/', protected_test),

    path('todos/', todos),
    path('todos/<str:todo_id>/', todo_detail),

    path('save-fcm-token/', save_fcm_token),

    path('upload-image/', upload_image),
    path('user-images/', user_images),
]