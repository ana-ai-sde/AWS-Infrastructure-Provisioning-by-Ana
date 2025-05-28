import os
import json
import pickle
import numpy as np
from sklearn.base import BaseEstimator

class DummyEstimator(BaseEstimator):
    def predict(self, X):
        return np.zeros(len(X))

def model_fn(model_dir):
    """Load the model for inference"""
    model = DummyEstimator()
    return model

def input_fn(request_body, request_content_type):
    """Parse input data payload"""
    if request_content_type == 'application/json':
        data = json.loads(request_body)
        return np.array(data)
    else:
        raise ValueError(f"Unsupported content type: {request_content_type}")

def predict_fn(input_data, model):
    """Make prediction using model"""
    return model.predict(input_data)

def output_fn(prediction, accept):
    """Format prediction output"""
    if accept == 'application/json':
        return json.dumps(prediction.tolist())
    raise ValueError(f"Unsupported accept type: {accept}")