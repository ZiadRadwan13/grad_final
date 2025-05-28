from firebase_functions import https_fn
from firebase_admin import initialize_app
import json # For handling JSON input/output
import os   # For path manipulation

# AI model specific imports
import pandas as pd
import numpy as np

# For XGBoost
import xgboost as xgb
import pickle # For loading pickle files

# For Prophet
from prophet import Prophet

# For LSTM (TensorFlow/Keras example)
import tensorflow as tf
from tensorflow.keras.models import load_model
# Add this simple function somewhere in your main.py
# (e.g., above or below your existing predict_ functions)
@https_fn.on_request()
def helloworld(req: https_fn.Request) -> https_fn.Response:
    """Responds to an HTTP request with a 'Hello, World!' message."""
    return https_fn.Response("Hello from Firebase Cloud Functions!", status=200)

# ... (your existing initialize_app, model loading, and predict_ functions)
initialize_app()