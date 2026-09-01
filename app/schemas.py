from pydantic import BaseModel, Field


class LeadInput(BaseModel):
    company_size: int = Field(ge=1, le=100000)
    website_visits: int = Field(ge=0, le=10000)
    email_opens: int = Field(ge=0, le=1000)
    form_submissions: int = Field(ge=0, le=100)
    sales_calls: int = Field(ge=0, le=100)
    days_since_first_contact: int = Field(ge=0, le=3650)


class LeadPrediction(BaseModel):
    score: int
    probability: float
    priority: str
    converted: bool
