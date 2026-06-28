import os
from pymongo import MongoClient

MONGO_URI = os.environ.get(
    "MONGODB_URI",
    "mongodb+srv://umangbalihan431_db_user:Umang%403012@todoapp.1hjipqk.mongodb.net/todo_app?retryWrites=true&w=majority&appName=ToDoApp"
)

client = MongoClient(MONGO_URI)
db = client["todo_app"]

users_collection = db["users"]
todos_collection = db["todos"]
fcm_tokens_collection = db["fcm_tokens"]
images_collection = db["images"]