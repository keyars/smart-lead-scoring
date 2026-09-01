# Smart Lead Scoring

A small, practical machine-learning application that predicts whether a sales lead is likely to convert.

The project is intentionally product-oriented: Python handles the ML/API layer, while the client layer can later be implemented in Flutter, React Native, or Web.

## V1

- Synthetic CRM-style lead dataset
- Binary classification
- Logistic Regression baseline
- Standardized numeric features
- Validation metrics
- Saved model artifact
- FastAPI prediction endpoint
- Automated API tests

## Architecture

```text
Lead Data
   |
   v
Feature Engineering
   |
   v
Logistic Regression
   |
   v
Conversion Probability
   |
   v
Lead Score (0-100)
   |
   v
FastAPI
   |
   +--> Flutter
   +--> React Native
   +--> Web
```

## Lead features

The first model uses:

- company size
- website visits
- email opens
- form submissions
- sales calls
- days since first contact

The model returns a probability and converts it into a simple 0-100 lead score.

## Run locally

```bash
python -m venv .venv
source .venv/bin/activate

pip install -r requirements.txt
python -m model.train

uvicorn app.main:app --reload
```

API documentation: `http://127.0.0.1:8000/docs`

Run tests:

```bash
pytest
```

## Important

The initial dataset is synthetic and the model is a learning/demo baseline. It must be validated against representative historical CRM data before being used for real business decisions.
