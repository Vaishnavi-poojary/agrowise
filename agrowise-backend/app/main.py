from fastapi import FastAPI, HTTPException

app = FastAPI()
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional
import joblib
import numpy as np
import requests
import os


app = FastAPI(
    title="🌾 Crop & Fertilizer Recommendation API",
    description="AI-powered crop and fertilizer recommendation using soil and weather data",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Load Models ───────────────────────────────────────────────
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.path.join(BASE_DIR, "..", "models")

crop_model     = joblib.load(os.path.join(MODELS_DIR, "crop_model.pkl"))
crop_le        = joblib.load(os.path.join(MODELS_DIR, "crop_label_encoder.pkl"))

# ─── Constants ─────────────────────────────────────────────────
OPENWEATHER_API_KEY = "1eb2298216b09cd00d3a80c6cfa7b257"

# Fertilizer lookup: crop_type → soil_type → fertilizer
FERTILIZER_MAP = {
    "Barley":       {"Black": "14-35-14", "Clayey": "10-26-26", "Loamy": "14-35-14", "Red": "20-20",    "Sandy": "20-20"},
    "Cotton":       {"Black": "DAP",      "Clayey": "20-20",    "Loamy": "17-17-17", "Red": "Urea",     "Sandy": "17-17-17"},
    "Ground Nuts":  {"Black": "14-35-14", "Clayey": "28-28",    "Loamy": "DAP",      "Red": "Urea",     "Sandy": "Urea"},
    "Maize":        {"Black": "DAP",      "Clayey": "14-35-14", "Loamy": "10-26-26", "Red": "Urea",     "Sandy": "DAP"},
    "Millets":      {"Black": "14-35-14", "Clayey": "28-28",    "Loamy": "20-20",    "Red": "14-35-14", "Sandy": "Urea"},
    "Oil seeds":    {"Black": "14-35-14", "Clayey": "28-28",    "Loamy": "DAP",      "Red": "28-28",    "Sandy": "14-35-14"},
    "Paddy":        {"Black": "17-17-17", "Clayey": "17-17-17", "Loamy": "DAP",      "Red": "28-28",    "Sandy": "Urea"},
    "Pulses":       {"Black": "14-35-14", "Clayey": "17-17-17", "Loamy": "20-20",    "Red": "14-35-14", "Sandy": "14-35-14"},
    "Sugarcane":    {"Black": "10-26-26", "Clayey": "14-35-14", "Loamy": "28-28",    "Red": "20-20",    "Sandy": "14-35-14"},
    "Tobacco":      {"Black": "DAP",      "Clayey": "10-26-26", "Loamy": "Urea",     "Red": "14-35-14", "Sandy": "10-26-26"},
    "Wheat":        {"Black": "Urea",     "Clayey": "20-20",    "Loamy": "10-26-26", "Red": "DAP",      "Sandy": "10-26-26"},
}

# Crop → closest fertilizer crop mapping
CROP_TO_FERT_CROP = {
    "rice": "Paddy", "maize": "Maize", "chickpea": "Pulses", "kidneybeans": "Pulses",
    "pigeonpeas": "Pulses", "mothbeans": "Pulses", "mungbean": "Pulses",
    "blackgram": "Pulses", "lentil": "Pulses", "pomegranate": "Oil seeds",
    "banana": "Sugarcane", "mango": "Oil seeds", "grapes": "Oil seeds",
    "watermelon": "Sugarcane", "muskmelon": "Sugarcane", "apple": "Oil seeds",
    "orange": "Oil seeds", "papaya": "Sugarcane", "coconut": "Oil seeds",
    "cotton": "Cotton", "jute": "Pulses", "coffee": "Oil seeds",
}

# Fertilizer descriptions
FERTILIZER_INFO = {
    "DAP":      {"full_name": "Di-Ammonium Phosphate", "npk": "18-46-0",  "use": "Excellent for root development and early growth. High in phosphorus."},
    "Urea":     {"full_name": "Urea",                  "npk": "46-0-0",   "use": "High nitrogen fertilizer, ideal for leafy growth and green vegetation."},
    "14-35-14": {"full_name": "NPK 14-35-14",          "npk": "14-35-14", "use": "Balanced fertilizer with high phosphorus, great for flowering crops."},
    "10-26-26": {"full_name": "NPK 10-26-26",          "npk": "10-26-26", "use": "High phosphorus & potassium blend, ideal for fruiting and rooting."},
    "17-17-17": {"full_name": "NPK 17-17-17",          "npk": "17-17-17", "use": "Perfectly balanced fertilizer, suitable for general all-crop use."},
    "20-20":    {"full_name": "NPK 20-20-0",           "npk": "20-20-0",  "use": "Equal nitrogen and phosphorus blend, great for early crop stages."},
    "28-28":    {"full_name": "NPK 28-28-0",           "npk": "28-28-0",  "use": "High nitrogen and phosphorus, used for fast-growing cereal crops."},
}

# Crop info
CROP_INFO = {
    "rice":        {"season": "Kharif", "duration": "90-150 days", "water": "High"},
    "maize":       {"season": "Kharif/Rabi", "duration": "60-90 days", "water": "Medium"},
    "chickpea":    {"season": "Rabi", "duration": "90-95 days", "water": "Low"},
    "kidneybeans": {"season": "Kharif", "duration": "60-90 days", "water": "Medium"},
    "pigeonpeas":  {"season": "Kharif", "duration": "150-180 days", "water": "Low"},
    "mothbeans":   {"season": "Kharif", "duration": "60-75 days", "water": "Low"},
    "mungbean":    {"season": "Kharif/Zaid", "duration": "60-75 days", "water": "Low"},
    "blackgram":   {"season": "Kharif", "duration": "70-80 days", "water": "Low"},
    "lentil":      {"season": "Rabi", "duration": "100-110 days", "water": "Low"},
    "pomegranate": {"season": "Year-round", "duration": "5-7 months", "water": "Low"},
    "banana":      {"season": "Year-round", "duration": "10-12 months", "water": "High"},
    "mango":       {"season": "Summer", "duration": "3-5 months", "water": "Medium"},
    "grapes":      {"season": "Winter", "duration": "1-2 months", "water": "Medium"},
    "watermelon":  {"season": "Summer/Zaid", "duration": "70-90 days", "water": "Medium"},
    "muskmelon":   {"season": "Zaid", "duration": "75-90 days", "water": "Medium"},
    "apple":       {"season": "Winter", "duration": "4-5 months", "water": "Medium"},
    "orange":      {"season": "Winter", "duration": "7-8 months", "water": "Medium"},
    "papaya":      {"season": "Year-round", "duration": "9-11 months", "water": "Medium"},
    "coconut":     {"season": "Year-round", "duration": "Year-round", "water": "High"},
    "cotton":      {"season": "Kharif", "duration": "150-180 days", "water": "Medium"},
    "jute":        {"season": "Kharif", "duration": "100-120 days", "water": "High"},
    "coffee":      {"season": "Year-round", "duration": "Year-round", "water": "High"},
}

# ─── Schemas ───────────────────────────────────────────────────
class WeatherData(BaseModel):
    temperature: float
    humidity: float
    rainfall: float

class SoilInput(BaseModel):
    nitrogen: float = Field(..., ge=0, le=140, description="Nitrogen (N) in kg/ha")
    phosphorus: float = Field(..., ge=0, le=145, description="Phosphorus (P) in kg/ha")
    potassium: float = Field(..., ge=0, le=205, description="Potassium (K) in kg/ha")
    ph: float = Field(..., ge=0, le=14, description="Soil pH level")
    soil_type: str = Field(..., description="Soil type: Black, Clayey, Loamy, Red, Sandy")
    latitude: float = Field(..., description="GPS latitude for weather fetch")
    longitude: float = Field(..., description="GPS longitude for weather fetch")

class RecommendRequest(BaseModel):
    nitrogen: float = Field(..., ge=0, le=140)
    phosphorus: float = Field(..., ge=0, le=145)
    potassium: float = Field(..., ge=0, le=205)
    ph: float = Field(..., ge=0, le=14)
    soil_type: str
    latitude: float
    longitude: float

# ─── Weather Fetch ─────────────────────────────────────────────
def fetch_weather(lat: float, lon: float) -> dict:
    url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={OPENWEATHER_API_KEY}&units=metric"
    resp = requests.get(url, timeout=10)
    if resp.status_code != 200:
        raise HTTPException(status_code=502, detail=f"Weather API error: {resp.text}")
    data = resp.json()
    return {
        "temperature": round(data["main"]["temp"], 2),
        "humidity": round(data["main"]["humidity"], 2),
        "rainfall": round(data.get("rain", {}).get("1h", 0) * 24, 2),  # mm/day estimate
        "city": data.get("name", "Unknown"),
        "country": data.get("sys", {}).get("country", ""),
        "weather_description": data["weather"][0]["description"].capitalize(),
    }

# ─── Endpoints ─────────────────────────────────────────────────

@app.get("/")
def root():
    return {
        "message": "🌾 Crop & Fertilizer Recommendation API is running!",
        "endpoints": {
            "recommend": "POST /recommend - Full crop + fertilizer recommendation",
            "weather": "GET /weather?lat=xx&lon=yy - Fetch weather data",
            "crops": "GET /crops - List all supported crops",
            "soil_types": "GET /soil-types - List all soil types",
        }
    }

@app.get("/weather")
def get_weather(lat: float, lon: float):
    """Fetch current weather data by GPS coordinates"""
    return fetch_weather(lat, lon)

@app.get("/crops")
def list_crops():
    """List all supported crops with info"""
    return {
        "total": len(CROP_INFO),
        "crops": [
            {"name": crop, **info}
            for crop, info in CROP_INFO.items()
        ]
    }

@app.get("/soil-types")
def list_soil_types():
    """List all supported soil types"""
    return {
        "soil_types": ["Black", "Clayey", "Loamy", "Red", "Sandy"]
    }

@app.post("/recommend")
def recommend(req: RecommendRequest):
    """
    Main endpoint: takes N, P, K, pH, soil type + GPS coordinates.
    Returns crop recommendation + fertilizer recommendation + weather data.
    """

    # 1. Validate soil type
    valid_soils = ["Black", "Clayey", "Loamy", "Red", "Sandy"]
    soil_type = req.soil_type.strip().capitalize()
    if soil_type not in valid_soils:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid soil type. Choose from: {valid_soils}"
        )

    # 2. Fetch weather from OpenWeatherMap
    weather = fetch_weather(req.latitude, req.longitude)

    # 3. Predict crop
    features = np.array([[
        req.nitrogen,
        req.phosphorus,
        req.potassium,
        weather["temperature"],
        weather["humidity"],
        req.ph,
        weather["rainfall"]
    ]])
    crop_pred_enc = crop_model.predict(features)[0]
    crop_name = crop_le.inverse_transform([crop_pred_enc])[0]

    # Get top 3 crop probabilities
    proba = crop_model.predict_proba(features)[0]
    top3_idx = np.argsort(proba)[::-1][:3]
    top3_crops = [
        {"crop": crop_le.inverse_transform([i])[0], "confidence": round(float(proba[i]) * 100, 1)}
        for i in top3_idx
    ]

    # 4. Get fertilizer recommendation
    fert_crop_key = CROP_TO_FERT_CROP.get(crop_name, "Pulses")
    fertilizer_name = FERTILIZER_MAP.get(fert_crop_key, {}).get(soil_type, "DAP")
    fert_info = FERTILIZER_INFO.get(fertilizer_name, {})
    crop_details = CROP_INFO.get(crop_name, {})

    return {
        "status": "success",
        "location": {
            "latitude": req.latitude,
            "longitude": req.longitude,
            "city": weather["city"],
            "country": weather["country"],
        },
        "weather": {
            "temperature_c": weather["temperature"],
            "humidity_percent": weather["humidity"],
            "rainfall_mm": weather["rainfall"],
            "description": weather["weather_description"],
        },
        "soil": {
            "nitrogen": req.nitrogen,
            "phosphorus": req.phosphorus,
            "potassium": req.potassium,
            "ph": req.ph,
            "soil_type": soil_type,
        },
        "crop_recommendation": {
            "recommended_crop": crop_name.capitalize(),
            "confidence": top3_crops[0]["confidence"],
            "top_3_alternatives": top3_crops,
            "season": crop_details.get("season", "N/A"),
            "duration": crop_details.get("duration", "N/A"),
            "water_requirement": crop_details.get("water", "N/A"),
        },
        "fertilizer_recommendation": {
            "fertilizer_name": fertilizer_name,
            "full_name": fert_info.get("full_name", fertilizer_name),
            "npk_ratio": fert_info.get("npk", "N/A"),
            "usage_tip": fert_info.get("use", "Apply as per soil test recommendations."),
        }
    }


@app.post("/weather-only")
def weather_only(lat: float, lon: float):
    """Just fetch weather — used by FlutterFlow on location detect"""
    return fetch_weather(lat, lon)
