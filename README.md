# Smart Lead Scoring

A practical end-to-end AI/ML product that predicts sales lead conversion likelihood and turns it into an actionable 0–100 score.

## Product

Sales teams can enter lead activity in the Flutter client and receive a conversion probability plus a simple Low / Medium / High sales priority.

This project deliberately demonstrates **practical AI integration into an application**, rather than a large ML platform.

## Stack

- **ML:** Python, Pandas, scikit-learn, Logistic Regression
- **API:** FastAPI, Pydantic
- **Mobile/Web UI:** Flutter + Material 3
- **Testing:** Pytest + FastAPI TestClient + Flutter widget test
- **Deployment:** Docker
- **CI:** GitHub Actions

## Architecture

```text
Flutter Client
      |
      | POST /predict
      v
  FastAPI API
      |
      v
Validation + Features
      |
      v
StandardScaler
      |
      v
Logistic Regression
      |
      v
Conversion Probability
      |
      v
Score 0–100 + Priority
      |
      v
Flutter Result UI
```

See [architecture](docs/ARCHITECTURE.md) and [API documentation](docs/API.md).

## User experience

The Flutter client provides:

1. Clear lead-signal input form.
2. Demo data shortcut for quick testing.
3. Client-side validation.
4. Loading feedback while the model is called.
5. Empty state before the first prediction.
6. Visual 0–100 score result.
7. Conversion probability progress indicator.
8. Low / Medium / High priority.
9. Practical follow-up guidance.
10. API error feedback and retry flow.
11. Responsive layout for narrow and wide screens.

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

## Run with Docker

```bash
docker build -t smart-lead-scoring .
docker run -p 8000:8000 smart-lead-scoring
```

## Run the Flutter client

```bash
cd flutter_app
flutter create --platforms=android,ios,web .
flutter pub get
flutter run
```

For Flutter Web, keep the API at `http://localhost:8000`.

For Android Emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

For a physical device, set `API_BASE_URL` to the API host's LAN address.

## Tests

Python:

```bash
pytest
```

Flutter:

```bash
cd flutter_app
flutter analyze
flutter test
```

## Project status

**High-level V1 complete:** ML model + API + validation + reusable prediction service + Flutter UI/UX + Flutter widget test + Docker + CI + documentation.

## Production considerations

The current training dataset is synthetic. Production deployment should use representative historical CRM outcomes, establish data-quality checks, evaluate calibration and business impact, version datasets/models, secure the API, restrict CORS, and monitor model performance and drift.
