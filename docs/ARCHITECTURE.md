# Architecture

## Product flow

CRM lead attributes are submitted by a client application. The FastAPI service validates the request and passes the numeric features to a trained Logistic Regression pipeline. The model produces conversion probability; the API exposes that probability as a 0–100 score and a simple sales priority.

## Why this architecture

The model is intentionally small. It is fast, inexpensive to run, easy to retrain and understandable to a software engineer who is learning practical ML.

## Future production path

- Replace synthetic data with historical CRM outcomes.
- Add authentication and tenant isolation.
- Version datasets and models.
- Track precision, recall, ROC-AUC and calibration over time.
- Add model explainability.
- Add batch scoring for CRM imports.
- Add feedback from actual conversion outcomes for retraining.
- Deploy API as a containerized service.
