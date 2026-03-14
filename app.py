from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def home():
    return {"message": "Crop Recommendation API running"}
