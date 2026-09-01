# API

Base URL: `http://localhost:8000`

## Health

`GET /health`

Example response:

```json
{
  "status": "ok",
  "model": "loaded"
}
```

## Predict

`POST /predict`

### Request

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

### Fields

| Field | Type | Range | Meaning |
|---|---|---:|---|
| company_size | integer | 1–100000 | Prospect company size |
| website_visits | integer | 0–10000 | Website visits |
| email_opens | integer | 0–1000 | Marketing email opens |
| form_submissions | integer | 0–100 | Submitted forms |
| sales_calls | integer | 0–100 | Sales conversations |
| days_since_first_contact | integer | 0–3650 | Lead age |

### Response

```json
{
  "score": 86,
  "probability": 0.8642,
  "priority": "High",
  "converted": true
}
```

- `score`: 0–100 representation of model probability.
- `probability`: model conversion probability from 0 to 1.
- `priority`: `Low`, `Medium`, or `High` based on the score.
- `converted`: boolean baseline decision using a 0.5 probability threshold.

## Interactive documentation

Start the API and open `/docs` for the automatically generated Swagger UI.

## Client configuration

The Flutter client reads `API_BASE_URL` using `--dart-define`, allowing the same source to target localhost, an Android emulator, an iOS simulator, a physical device, or a deployed API.
