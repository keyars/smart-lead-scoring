from pathlib import Path

import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from app.schemas import LeadInput, LeadPrediction

ROOT = Path(__file__).resolve().parents[1]
MODEL_PATH = ROOT / "artifacts" / "lead_model.joblib"
FEATURES = [
    "company_size",
    "website_visits",
    "email_opens",
    "form_submissions",
    "sales_calls",
    "days_since_first_contact",
]

app = FastAPI(
    title="Smart Lead Scoring API",
    version="1.0.0",
    description="Predict sales lead conversion probability using a lightweight ML model.",
)

# Local/demo CORS policy so the Flutter Web client can call the API.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost", "http://localhost:8000", "http://127.0.0.1", "http://127.0.0.1:8000"],
    allow_credentials=False,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)


def load_model():
    if not MODEL_PATH.exists():
        raise RuntimeError("Model artifact not found. Run: python -m model.train")
    return joblib.load(MODEL_PATH)


model = load_model()


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "model": "loaded"}


@app.post("/predict", response_model=LeadPrediction)
def predict(lead: LeadInput) -> LeadPrediction:
    try:
        frame = pd.DataFrame([lead.model_dump()])[FEATURES]
        probability = float(model.predict_proba(frame)[0][1])
    except Exception as exc:
        raise HTTPException(status_code=500, detail="Prediction failed") from exc

    score = round(probability * 100)
    priority = "High" if score >= 70 else "Medium" if score >= 40 else "Low"

    return LeadPrediction(
        score=score,
        probability=round(probability, 4),
        priority=priority,
        converted=probability >= 0.5,
    )
