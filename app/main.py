from pathlib import Path

import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException

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
