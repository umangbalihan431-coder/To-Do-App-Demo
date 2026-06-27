import os
import json
import firebase_admin
from firebase_admin import credentials

firebase_json = os.environ.get("FIREBASE_SERVICE_ACCOUNT_JSON")

if firebase_json:
    firebase_credentials = json.loads(firebase_json)
    cred = credentials.Certificate(firebase_credentials)
else:
    cred = credentials.Certificate("firebase-service-account.json")

try:
    firebase_admin.get_app()
except ValueError:
    firebase_admin.initialize_app(cred)