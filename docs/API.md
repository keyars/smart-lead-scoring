# API

## Health

`GET /health`

Returns service and model status.

## Predict

`POST /predict`

Request fields:

| Field | Type | Meaning |
|---|---|---|
| company_size | integer | Prospect company size |
| website_visits | integer | Website visits |
| email_opens | integer | Marketing email opens |
| form_submissions | integer | Submitted forms |
| sales_calls | integer | Sales calls |
| days_since_first_contact | integer | Lead age |

Response:

- `score`: 0–100
- `probability`: conversion probability from 0 to 1
- `priority`: Low, Medium or High
- `converted`: boolean threshold result

Interactive documentation is available through FastAPI at `/docs` when the service is running.
