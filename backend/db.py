from pymongo import MongoClient

MONGO_URI = "mongodb+srv://umangbalihan431_db_user:Umang%403012@todoapp.1hjipqk.mongodb.net/?retryWrites=true&w=majority&appName=ToDoApp"

client = MongoClient(MONGO_URI)

db = client["todo_app"]

todos_collection = db["todos"]
fcm_tokens_collection = db["fcm_tokens"]