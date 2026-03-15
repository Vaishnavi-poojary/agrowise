import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import joblib
import os

os.makedirs("models", exist_ok=True)

# ─── CROP MODEL ───────────────────────────────────────────────
print("Training crop recommendation model...")
crop_df = pd.read_csv("data/crop_data.csv")

X_crop = crop_df[["N", "P", "K", "temperature", "humidity", "ph", "rainfall"]]
y_crop = crop_df["label"]

le_crop = LabelEncoder()
y_crop_enc = le_crop.fit_transform(y_crop)

X_train, X_test, y_train, y_test = train_test_split(X_crop, y_crop_enc, test_size=0.2, random_state=42)

crop_model = RandomForestClassifier(n_estimators=100, random_state=42)
crop_model.fit(X_train, y_train)
acc = accuracy_score(y_test, crop_model.predict(X_test))
print(f"  Crop model accuracy: {acc*100:.2f}%")

joblib.dump(crop_model, "models/crop_model.pkl")
joblib.dump(le_crop, "models/crop_label_encoder.pkl")

# ─── FERTILIZER MODEL ─────────────────────────────────────────
print("Training fertilizer recommendation model...")
fert_df = pd.read_csv("data/fertilizer_data.csv")

le_soil = LabelEncoder()
le_crop_type = LabelEncoder()
le_fert = LabelEncoder()

fert_df["Soil Type Enc"] = le_soil.fit_transform(fert_df["Soil Type"])
fert_df["Crop Type Enc"] = le_crop_type.fit_transform(fert_df["Crop Type"])
fert_df["Fert Enc"] = le_fert.fit_transform(fert_df["Fertilizer Name"])

X_fert = fert_df[["Temparature", "Humidity", "Moisture", "Soil Type Enc", "Crop Type Enc", "Nitrogen", "Potassium", "Phosphorous"]]
y_fert = fert_df["Fert Enc"]

X_train2, X_test2, y_train2, y_test2 = train_test_split(X_fert, y_fert, test_size=0.2, random_state=42)

fert_model = RandomForestClassifier(n_estimators=100, random_state=42)
fert_model.fit(X_train2, y_train2)
acc2 = accuracy_score(y_test2, fert_model.predict(X_test2))
print(f"  Fertilizer model accuracy: {acc2*100:.2f}%")

joblib.dump(fert_model, "models/fert_model.pkl")
joblib.dump(le_soil, "models/le_soil.pkl")
joblib.dump(le_crop_type, "models/le_crop_type.pkl")
joblib.dump(le_fert, "models/le_fert.pkl")

print("\n✅ All models trained and saved!")
print(f"Crop classes: {list(le_crop.classes_)}")
print(f"Soil types: {list(le_soil.classes_)}")
print(f"Crop types (fertilizer): {list(le_crop_type.classes_)}")
print(f"Fertilizer types: {list(le_fert.classes_)}")
