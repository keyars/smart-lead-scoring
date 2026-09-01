from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_predict() -> None:
    response = client.post(
        "/predict",
        json={
            "company_size": 250,
            "website_visits": 35,
            "email_opens": 16,
            "form_submissions": 3,
            "sales_calls": 2,
            "days_since_first_contact": 8,
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert 0 <= payload["score"] <= 100
    assert 0 <= payload["probability"] <= 1
    assert payload["priority"] in {"High", "Medium", "Low"}
    assert isinstance(payload["converted"], bool)
