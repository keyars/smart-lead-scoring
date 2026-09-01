# Smart Lead Scoring

A practical end-to-end AI/ML product that predicts sales lead conversion likelihood and turns it into an actionable 0–100 score.

## Product

Sales teams enter or import lead activity. The ML service estimates conversion probability and classifies the lead as **Low**, **Medium**, or **High** priority.

## Stack

- **ML:** Python, Pandas, scikit-learn, Logistic Regression
- **API:** FastAPI, Pydantic
- **Mobile:** Flutter
- **Testing:** Pytest + FastAPI TestClient
- **Deployment:** Docker
- **CI:** GitHub Actions

## Architecture

```text
Flutter / Web / React Native
             |
             v
        FastAPI API
             |
             v
      Validation + Features
             |
             v
     Logistic Regression
             |
             v
   Conversion Probability
             |
             v
       Lead Score 0-100
             |
             v
      Sales Priority
```

See [architecture](docs/ARCHITECTURE.md) and [API documentation](docs/API.md).

## API

### `GET /health`

Checks that the service and trained model are available.

### `POST /predict`

Example request:

```json
{
  "company_size": 250,
  "website_visits": 35,
  "email_opens": 16,
  "form_submissions": 3,
  "sales_calls": 2,
  "days_since_first_contact": 8
}
```

Example response:

```json
{
  "score": 86,
  "probability": 0.8642,
  "priority": "High",
  "converted": true
}
```

## Run the API

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python -m model.train
uvicorn app.main:app --reload
```

Open `http://127.0.0.1:8000/docs` for interactive API documentation.

## Run tests

```bash
pytest
```

## Run with Docker

```bash
docker build -t smart-lead-scoring .
docker run -p 8000:8000 smart-lead-scoring
```

## Flutter client

The Flutter client is in `flutter_app/`.

```bash
cd flutter_app
flutter pub get
flutter run
```

## Project status

**High-level V1 complete:** ML baseline + REST API + validation + tests + CI + Docker + Flutter client + documentation.

## Production considerations

The current training data is synthetic. Production deployment should use representative historical CRM outcomes, establish data-quality checks, evaluate model calibration and business impact, and version the dataset/model before making operational decisions.
