from flask import Flask, request, jsonify
from ultralytics import YOLO
from PIL import Image
import io

app = Flask(__name__)

# Load your YOLO model
model = YOLO("best.pt")

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400

    image = request.files['image'].read()
    img = Image.open(io.BytesIO(image))

    results = model(img)
    detections = results[0].boxes.data.tolist()

    return jsonify({
        'detections': detections,
        'labels': results[0].names
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
