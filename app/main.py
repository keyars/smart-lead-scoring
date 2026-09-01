from pathlib import Path

import joblib
import pandas as pd
from fastapi import FastAPI

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
    version="0.1.0",
    description="Predict sales lead conversion probability using a small ML baseline.",
)

model = joblib.load(MODEL_PATH)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/predict", response_model=LeadPrediction)
def predict(lead: LeadInput) -> LeadPrediction:
    frame = pd.DataFrame([lead.model_dump()])[FEATURES]
    probability = float(model.predict_proba(frame)[0][1])
    score = round(probability * 100)

    if score >= 70:
        priority = "High"
    elif score >= 40:
        priority = "Medium"
    else:
        priority = "Low"

    return LeadPrediction(
        score=score,
        probability=round(probability, 4),
        priority=priority,
        converted=probability >= 0.5,
    )
