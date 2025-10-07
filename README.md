# 🌿 Green Eye – Mobile Application

🔍 **Overview**

**Green Eye** is a mobile application powered by Artificial Intelligence (AI) and IoT technologies to support smart agriculture.
It enables farmers to detect plant leaf diseases through image analysis and monitor environmental parameters in real time via connected sensors.
Developed to meet the needs of Tunisian farmers, Green Eye delivers data-driven insights and early alerts to improve crop health, optimize resources, and increase productivity.

At the core of the application lies a trained deep learning model—integrated and deployed directly within the app—that performs real-time detection and classification of leaf diseases based on images captured by the user.
---

🚀 **Features**

-🌱 **AI-Powered Leaf Disease Detection**: integrates a YOLOv12 object detection model capable of identifying and classifying plant diseases from leaf images with high accuracy and speed.
- 📊 **Sensor Data Integration**: Real-time environmental monitoring (temperature, humidity, soil moisture, etc.).
- 📸 **Camera Integration**: Capture images directly from the app for diagnosis.
- 🌐 **User-Friendly Interface**: Simple and intuitive design tailored for farmers.
- 🗣️ **Multilingual Support**: Support for Arabic and French (in progress).

---
🧠 **AI Aspect**

The AI core of Green Eye is built around YOLOv12 (You Only Look Once, version 12) — a state-of-the-art object detection architecture optimized for speed and accuracy on mobile devices.
The model was trained on datasets of healthy and diseased plant leaves, enabling it to detect multiple disease types and classify them in real time.

By leveraging YOLO’s efficient detection pipeline, Green Eye provides:
- Instant inference on captured images.
- High precision in identifying visual symptoms (spots, color changes, mold, etc.).
- Lightweight performance, making it suitable for deployment in mobile environments.

This AI integration transforms Green Eye into an intelligent assistant that empowers farmers with data-driven insights for early disease prevention and better crop management.

---

🛠️ **Installation**

**1. Clone the Repository**

```bash
git clone https://github.com/sahar-chaari/Mobile-application-Green_Eye.git
cd Mobile-application-Green_Eye
```

**2. Open in Android Studio**

- Launch Android Studio.
- Click **File > Open** and select the `Mobile-application-Green_Eye` directory.

**3. Build the Project**

- Let Android Studio download dependencies and sync the project.
- Connect an Android device or launch an emulator.
- Run the application.

---

💡 **Future Improvements**

- 🧠 Improve model accuracy with more localized dataset.
- 📶 Real-time sync with cloud-based dashboard.
- 🔔 Push notifications for critical environmental alerts.
- 🧪 Add treatment recommendations for detected diseases.
- 🗺️ GPS-based disease mapping and analytics.
