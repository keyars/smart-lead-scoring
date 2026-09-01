# Architecture

## Product flow

```text
Flutter Client
     |
     | POST /predict
     v
FastAPI
     |
     | validated LeadInput
     v
ML Pipeline
(StandardScaler + Logistic Regression)
     |
     | conversion probability
     v
Score + Priority
     |
     v
Flutter Result UI
```

## Responsibilities

### Flutter
- Collects six lead signals.
- Validates user input.
- Calls the prediction API.
- Shows loading, empty, success and error states.
- Displays score, probability and sales priority.
- Uses `API_BASE_URL` so the same client can target local, emulator or deployed APIs.

### FastAPI
- Validates the request with Pydantic.
- Loads the trained model artifact.
- Performs prediction.
- Converts probability to a 0–100 score.
- Maps the score to Low, Medium or High priority.
- Exposes health and prediction endpoints.
- Enables local Flutter Web CORS.

### ML
The baseline uses StandardScaler + Logistic Regression. This is deliberately small, inexpensive and explainable. The training script evaluates the held-out test set using classification metrics and ROC-AUC before saving the model artifact.

## Local deployment

The API can run directly with Python or inside Docker. The Docker image trains the model during image build, so the runtime container contains the model artifact needed by the API.

## CI

GitHub Actions validates both layers:

- Python dependency installation
- Model training
- Python API tests
- Flutter dependency installation
- Flutter static analysis
- Flutter widget smoke test

## Production path

Before operational use:

- Replace synthetic data with representative historical CRM outcomes.
- Add authentication and tenant isolation.
- Version datasets and models.
- Monitor precision, recall, ROC-AUC and calibration.
- Add model explainability and feature drift monitoring.
- Add batch scoring for CRM imports.
- Capture actual conversion outcomes for retraining.
- Restrict CORS to trusted production origins.
- Add observability, rate limiting and secure deployment.
