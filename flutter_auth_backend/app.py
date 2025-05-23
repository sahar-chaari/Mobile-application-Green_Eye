from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pymongo import MongoClient
from PIL import Image
import torch
import io
import datetime
from ultralytics import YOLO
import uvicorn
from fastapi import HTTPException


# Load YOLOv8 model
model = YOLO(r"C:\Users\DHOUIB\Downloads\best (4).pt")  # Update if needed

# Disease list (class index must match YOLO model)
disease_list = ['Early Blight', 'Healthy', 'Late Blight', 'Leaf Miner', 'Leaf Mold', 'Mosaic Virus', 'Septoria', 'Spider Mites', 'Yellow Leaf Curl Virus']

# Create FastAPI app
app = FastAPI()

# CORS setup — required to allow mobile app access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # You can restrict this to your mobile IP later
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Connect to MongoDB Atlas
client = MongoClient("mongodb+srv://ahmed:ahmed123..@cluster0.87ihpdb.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")
db = client["test"]
detections_collection = db["detections"]

@app.delete("/detections/{filename}")
def delete_detection(filename: str):
    result = detections_collection.delete_one({"filename": filename})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Detection not found")
    return {"status":"deleted"}
@app.get("/detections")
def get_detections(userId: str = None):
    query = {}
    if userId:
        query['userId'] = userId
    return list(detections_collection.find(query, {"_id": 0}))

from fastapi.staticfiles import StaticFiles
import os

# Make sure 'images' folder exists
os.makedirs("images", exist_ok=True)

# Mount image folder
app.mount("/images", StaticFiles(directory="images"), name="images")
from fastapi import Form  # add this import

@app.post("/predict")
async def predict(image: UploadFile = File(...), userId: str = Form(...)):
    contents = await image.read()
    filename = image.filename
    filepath = f"images/{filename}"

    with open(filepath, "wb") as f:
        f.write(contents)

    img = Image.open(io.BytesIO(contents)).convert("RGB")
    results = model.predict(img)

    if len(results[0].boxes.cls) == 0:
        prediction = "No disease detected"
    else:
        class_id = int(results[0].boxes.cls[0].item())
        prediction = disease_list[class_id] if class_id < len(disease_list) else "Unknown disease"

    detections_collection.insert_one({
        "filename": filename,
        "prediction": prediction,
        "userId": userId,
        "timestamp": datetime.datetime.now().isoformat()
    })

    return {"prediction": prediction, "filename": filename}
# Only run if this file is executed directly (not imported)
uvicorn.run(app, host="0.0.0.0", port=8000)