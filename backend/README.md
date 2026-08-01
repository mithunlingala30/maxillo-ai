# 🚀 Gemini AI Model Backend

> **Built for Hackathon** — A high-performance, intelligent Generative AI Backend powered by **Google Gemini 1.5 Flash**. Capable of real-time **Image Prediction & Diagnosis** (e.g. Plant Disease Detection), **Multimodal Chat**, **Smart AI Suggestions**, and **Performance Scoring**, with built-in interactive **Swagger UI Documentation** (`/docs`).

![Node.js](https://img.shields.io/badge/Node.js-v18+-339933?style=for-the-badge&logo=node.js&logoColor=white)
![Express](https://img.shields.io/badge/Express-v5-000000?style=for-the-badge&logo=express&logoColor=white)
![Google Gemini](https://img.shields.io/badge/Google_Gemini-1.5_Flash-4285F4?style=for-the-badge&logo=google&logoColor=white)
![Swagger UI](https://img.shields.io/badge/Swagger_UI-FastAPI_Style-85EA2D?style=for-the-badge&logo=swagger&logoColor=black)
![Render](https://img.shields.io/badge/Render-Deployed-46E3B7?style=for-the-badge&logo=render&logoColor=white)

---

## 💡 Key Features

- 📷 **Image Prediction & Diagnosis (`/api/ai/predict-image`)** — Send base64 images for plant leaf disease analysis, crop status, object recognition, and detailed treatment recommendations.
- 💬 **Multimodal AI Chat (`/api/ai/chat`)** — Conversational AI supporting both text messages and base64 image attachments.
- 💡 **Smart AI Suggestions (`/api/ai/suggestions`)** — Generates structured JSON recommendations for focus, break, schedule, and usage optimizations.
- 📊 **Performance Scoring (`/api/ai/predict-score`)** — Predicts performance scores (0–100) based on user metrics and activity data.
- 📚 **Interactive Swagger Docs (`/docs`)** — Test endpoints directly in your browser with a FastAPI-style Swagger interface.
- ⚡ **High Payload Capacity** — Supports up to 50MB base64 image uploads seamlessly.

---

## 🏗️ System Architecture

```
┌───────────────────────────┐
│ Client (Flutter / Web /   │
│ Mobile / Postman)         │
└─────────────┬─────────────┘
              │ HTTP Request (JSON / Base64 Image)
              v
┌───────────────────────────┐
│  Gemini AI Model Backend  │  (Node.js + Express + Swagger UI)
│   http://localhost:3000   │
└─────────────┬─────────────┘
              │ Generative AI API Call
              v
┌───────────────────────────┐
│ Google Gemini 1.5 Flash   │  (Multimodal AI Model)
└───────────────────────────┘
```

---

## ⚡ Quick Start

### 1. Clone & Install

```bash
git clone https://github.com/mithunlingala30/gemini.git
cd gemini
npm install
```

### 2. Environment Setup

Set your Gemini API key in `server.js` or via environment variable:

```bash
# Optional: Set via environment variable
export GEMINI_API_KEY="YOUR_GEMINI_API_KEY"
```

Get a free key at [Google AI Studio](https://aistudio.google.com/app/apikey).

### 3. Run the Server

```bash
npm start
```

```
✅ Gen AI Backend is running!
🌐 Server URL: http://localhost:3000
📚 Interactive Docs (FastAPI Style): http://localhost:3000/docs
```

---

## 📚 Interactive API Documentation

Access live interactive documentation in your browser at:
👉 **`http://localhost:3000/docs`**

---

## 📡 API Endpoints Reference

### 1. 📷 Image Prediction / Analysis

**`POST /api/ai/predict-image`** *(Alias: `/api/ai/predict`)*

Submit a base64 encoded image for diagnosis or prediction.

**Request Body:**
```json
{
  "image": "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
  "mimeType": "image/jpeg",
  "prompt": "Analyze this plant leaf and predict if it has any disease."
}
```

**Response:**
```json
{
  "success": true,
  "prediction": "Plant: Tomato\nStatus: Early Blight\nConfidence: 94%\nSymptoms: Concentric dark rings on lower leaves...\nTreatment: Apply copper-based fungicide and prune infected foliage."
}
```

---

### 2. 💬 Chat with AI (Text + Vision)

**`POST /api/ai/chat`**

Conversational AI endpoint supporting text and optional base64 image context.

**Request Body:**
```json
{
  "message": "How do I prevent early blight in tomato crops?",
  "image": "optional_base64_string"
}
```

**Response:**
```json
{
  "reply": "To prevent early blight, ensure proper crop rotation, avoid overhead watering, and maintain good airflow between plants..."
}
```

---

### 3. 💡 Smart AI Suggestions

**`POST /api/ai/suggestions`**

Returns structured JSON recommendations based on context.

**Request Body:**
```json
{
  "prompt": "Tips to maintain crop health during humid weather"
}
```

**Response:**
```json
{
  "suggestions": [
    {
      "title": "Improve Air Circulation",
      "description": "Space out plants to prevent moisture accumulation on leaves.",
      "category": "focus",
      "priority": "high"
    }
  ]
}
```

---

### 4. 📊 Predict Performance Score

**`POST /api/ai/predict-score`**

Calculates an AI score from 0 to 100 based on activity data.

**Request Body:**
```json
{
  "userId": "user123",
  "data": {
    "tasksCompleted": 8,
    "hoursWorked": 6,
    "distractions": 3
  }
}
```

**Response:**
```json
{
  "predictedScore": 82
}
```

---

## 🌐 Deploy to Render (1-Click Setup)

This repository includes a `render.yaml` configuration file for automatic deployment on Render.

1. Push code to GitHub repository (`mithunlingala30/gemini`).
2. Go to **[Render Dashboard](https://dashboard.render.com)** -> **New Web Service**.
3. Connect your repository.
4. Set Build Command: `npm install` and Start Command: `npm start`.
5. Set Environment Variable: `GEMINI_API_KEY` (optional).
6. Click **Deploy**!

---

## 🛠️ Tech Stack

| Component | Technology |
|---|---|
| **Runtime** | Node.js v18+ |
| **Framework** | Express.js v5 |
| **AI Model** | Google Gemini 1.5 Flash (`@google/generative-ai`) |
| **API Docs** | Swagger UI Express (`/docs`) |
| **CORS** | CORS npm middleware |
| **Deployment** | Render (`render.yaml`) |

---

## 🏆 Hackathon Project

Built with ❤️ for the Hackathon to showcase real-time multimodal Generative AI capabilities for image analysis, instant diagnosis, interactive chat, and intelligent user recommendations.

**License**: ISC