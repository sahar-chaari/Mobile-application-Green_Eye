from pydantic import BaseModel

class Detection(BaseModel):
    filename: str
    prediction: str
    timestamp: str
