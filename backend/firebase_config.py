import firebase_admin
from firebase_admin import credentials, messaging

cred = credentials.Certificate("firebase-service-account.json")

try:
    firebase_admin.get_app()
except ValueError:
    firebase_admin.initialize_app(cred)