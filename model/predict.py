from pathlib import Path

import joblib
import pandas as pd

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


def predict_score(lead: dict) -> dict:
    model = joblib.load(MODEL_PATH)
    frame = pd.DataFrame([lead])[FEATURES]
    probability = float(model.predict_proba(frame)[0][1])
    score = round(probability * 100)
    priority = "High" if score >= 70 else "Medium" if score >= 40 else "Low"
    return {
        "score": score,
        "probability": round(probability, 4),
        "priority": priority,
        "converted": probability >= 0.5,
    }
