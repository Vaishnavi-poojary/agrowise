import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

// ─── CONFIGURATION ──────────────────────────────────────────
const String BASE_URL = 'https://agrowise.onrender.com';
const String WEATHER_API_KEY = '45b3f6baa2b6ea5ca19624f7d83b1317';
<<<<<<< HEAD
const String NEWS_API_KEY = 'e97459942afb4012b8a99a210e53b4c9';
=======
const String NEWS_API_KEY    = 'e97459942afb4012b8a99a210e53b4c9';

>>>>>>> 98cf8ed015d72007c1943840f38bc98ad6d64de1

// ─── LANGUAGE SUPPORT ───────────────────────────────────────
enum AppLanguage { english, kannada, hindi, tamil, telugu }

extension AppLanguageExt on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.kannada:
        return 'kn';
      case AppLanguage.hindi:
        return 'hi';
      case AppLanguage.tamil:
        return 'ta';
      case AppLanguage.telugu:
        return 'te';
    }
  }

  String get nativeName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.kannada:
        return 'ಕನ್ನಡ';
      case AppLanguage.hindi:
        return 'हिंदी';
      case AppLanguage.tamil:
        return 'தமிழ்';
      case AppLanguage.telugu:
        return 'తెలుగు';
    }
  }
}

// ─── TRANSLATIONS ────────────────────────────────────────────
const Map<String, Map<String, String>> _translations = {
  'en': {
    'appName': 'AgroWise',
    'tagline': 'AI CROP ADVISOR',
    'home': 'Home',
    'news': 'News',
    'profile': 'Profile',
    'history': 'History',
    'locationWeather': 'Your Location & Weather',
    'enterCity': 'Enter city name (e.g. Udupi)',
    'soilNutrients': 'Soil Nutrients',
    'soilType': 'Soil Type',
    'getRecommendation': 'Get Recommendation',
    'yourRecommendation': 'Your Recommendation',
    'recommendedCrop': 'Recommended Crop',
    'recommendedFertilizer': 'Recommended Fertilizer',
    'confidence': 'confidence',
    'season': 'Season',
    'duration': 'Duration',
    'water': 'Water',
    'top3': 'Top 3 Alternatives',
    'tryAgain': 'Try Again',
    'noHistory': 'No history yet',
    'historySubtitle': 'Your recommendations will appear here',
    'clearHistory': 'Clear History',
    'clearHistoryMsg': 'Delete all saved recommendations?',
    'cancel': 'Cancel',
    'clear': 'Clear',
    'fetchWeatherFirst': 'Please enter your city and fetch weather first!',
    'serverWaking': '⏳ Server is waking up, please try again in 10 seconds!',
    'cityNotFound': 'City not found. Try Mumbai or Delhi',
    'fetchingWeather': 'Fetching weather...',
    'enterCityToLoad': 'Enter your city above to load weather',
    'retry': 'Retry',
    'nitrogen': 'Nitrogen (N)',
    'phosphorus': 'Phosphorus (P)',
    'potassium': 'Potassium (K)',
    'phLevel': 'pH Level',
    'soilSummary': 'Soil Summary',
    'fertilizer': 'Fertilizer',
    'language': 'Language',
    'selectLanguage': 'Select Language',
    'agriNews': 'Agricultural News',
    'farmingTips': 'Farming Tips',
    'govSchemes': 'Govt Schemes',
    'mandiRates': 'Mandi Rates',
    'loadingNews': 'Loading news...',
    'noNews': 'No news available',
    'todaysTip': "Today's Tip",
    'profileTitle': 'My Profile',
    'farmerName': 'Farmer Name',
    'farmSize': 'Farm Size (acres)',
    'village': 'Village',
    'taluk': 'Taluk',
    'district': 'District',
    'state': 'State',
    'myCrops': 'My Crops',
    'soilPreference': 'Soil Type',
    'saveProfile': 'Save Profile',
    'profileSaved': '✅ Profile saved!',
    'editProfile': 'Edit Profile',
    'selectState': 'Select State',
    'selectCrops': 'Select Your Crops',
    'photoHint': 'Tap to add photo',
    'required': 'Required',
  },
  'kn': {
    'appName': 'ಅಗ್ರೋವೈಸ್',
    'tagline': 'AI ಬೆಳೆ ಸಲಹೆಗಾರ',
    'home': 'ಮುಖ್ಯ',
    'news': 'ಸುದ್ದಿ',
    'profile': 'ಪ್ರೊಫೈಲ್',
    'history': 'ಇತಿಹಾಸ',
    'locationWeather': 'ನಿಮ್ಮ ಸ್ಥಳ ಮತ್ತು ಹವಾಮಾನ',
    'enterCity': 'ನಗರದ ಹೆಸರು ನಮೂದಿಸಿ (ಉದಾ: ಉಡುಪಿ)',
    'soilNutrients': 'ಮಣ್ಣಿನ ಪೋಷಕಾಂಶಗಳು',
    'soilType': 'ಮಣ್ಣಿನ ಪ್ರಕಾರ',
    'getRecommendation': 'ಶಿಫಾರಸು ಪಡೆಯಿರಿ',
    'yourRecommendation': 'ನಿಮ್ಮ ಶಿಫಾರಸು',
    'recommendedCrop': 'ಶಿಫಾರಸು ಮಾಡಿದ ಬೆಳೆ',
    'recommendedFertilizer': 'ಶಿಫಾರಸು ಮಾಡಿದ ಗೊಬ್ಬರ',
    'confidence': 'ವಿಶ್ವಾಸ',
    'season': 'ಋತು',
    'duration': 'ಅವಧಿ',
    'water': 'ನೀರು',
    'top3': 'ಮೇಲ್ 3 ಪರ್ಯಾಯಗಳು',
    'tryAgain': 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ',
    'noHistory': 'ಇನ್ನೂ ಇತಿಹಾಸ ಇಲ್ಲ',
    'historySubtitle': 'ನಿಮ್ಮ ಶಿಫಾರಸುಗಳು ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತವೆ',
    'clearHistory': 'ಇತಿಹಾಸ ತೆರವುಗೊಳಿಸಿ',
    'clearHistoryMsg': 'ಎಲ್ಲಾ ಶಿಫಾರಸುಗಳನ್ನು ಅಳಿಸಲೇ?',
    'cancel': 'ರದ್ದುಮಾಡಿ',
    'clear': 'ತೆರವು',
    'fetchWeatherFirst': 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ನಗರವನ್ನು ನಮೂದಿಸಿ!',
    'serverWaking': '⏳ ಸರ್ವರ್ ಎಚ್ಚರಗೊಳ್ಳುತ್ತಿದೆ!',
    'cityNotFound': 'ನಗರ ಕಂಡುಬಂದಿಲ್ಲ',
    'fetchingWeather': 'ಹವಾಮಾನ ತರಿಸಲಾಗುತ್ತಿದೆ...',
    'enterCityToLoad': 'ಹವಾಮಾನ ಲೋಡ್ ಮಾಡಲು ನಗರ ನಮೂದಿಸಿ',
    'retry': 'ಮತ್ತೆ ಪ್ರಯತ್ನ',
    'nitrogen': 'ಸಾರಜನಕ (N)',
    'phosphorus': 'ರಂಜಕ (P)',
    'potassium': 'ಪೊಟ್ಯಾಶಿಯಂ (K)',
    'phLevel': 'pH ಮಟ್ಟ',
    'soilSummary': 'ಮಣ್ಣಿನ ಸಾರಾಂಶ',
    'fertilizer': 'ಗೊಬ್ಬರ',
    'language': 'ಭಾಷೆ',
    'selectLanguage': 'ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ',
    'agriNews': 'ಕೃಷಿ ಸುದ್ದಿ',
    'farmingTips': 'ಕೃಷಿ ಸಲಹೆ',
    'govSchemes': 'ಸರ್ಕಾರಿ ಯೋಜನೆ',
    'mandiRates': 'ಮಂಡಿ ದರ',
    'loadingNews': 'ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
    'noNews': 'ಸುದ್ದಿ ಇಲ್ಲ',
    'todaysTip': 'ಇಂದಿನ ಸಲಹೆ',
    'profileTitle': 'ನನ್ನ ಪ್ರೊಫೈಲ್',
    'farmerName': 'ರೈತರ ಹೆಸರು',
    'farmSize': 'ಜಮೀನು ಗಾತ್ರ (ಎಕರೆ)',
    'village': 'ಗ್ರಾಮ',
    'taluk': 'ತಾಲೂಕು',
    'district': 'ಜಿಲ್ಲೆ',
    'state': 'ರಾಜ್ಯ',
    'myCrops': 'ನನ್ನ ಬೆಳೆಗಳು',
    'soilPreference': 'ಮಣ್ಣಿನ ಪ್ರಕಾರ',
    'saveProfile': 'ಪ್ರೊಫೈಲ್ ಉಳಿಸಿ',
    'profileSaved': '✅ ಪ್ರೊಫೈಲ್ ಉಳಿಸಲಾಗಿದೆ!',
    'editProfile': 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ',
    'selectState': 'ರಾಜ್ಯ ಆಯ್ಕೆ',
    'selectCrops': 'ನಿಮ್ಮ ಬೆಳೆ ಆಯ್ಕೆ',
    'photoHint': 'ಫೋಟೋ ಸೇರಿಸಲು ಟ್ಯಾಪ್',
    'required': 'ಅಗತ್ಯ',
  },
  'hi': {
    'appName': 'एग्रोवाइज़',
    'tagline': 'AI फसल सलाहकार',
    'home': 'होम',
    'news': 'समाचार',
    'profile': 'प्रोफ़ाइल',
    'history': 'इतिहास',
    'locationWeather': 'आपका स्थान और मौसम',
    'enterCity': 'शहर का नाम दर्ज करें (जैसे: मुंबई)',
    'soilNutrients': 'मिट्टी के पोषक तत्व',
    'soilType': 'मिट्टी का प्रकार',
    'getRecommendation': 'सिफारिश प्राप्त करें',
    'yourRecommendation': 'आपकी सिफारिश',
    'recommendedCrop': 'अनुशंसित फसल',
    'recommendedFertilizer': 'अनुशंसित उर्वरक',
    'confidence': 'विश्वास',
    'season': 'मौसम',
    'duration': 'अवधि',
    'water': 'पानी',
    'top3': 'शीर्ष 3 विकल्प',
    'tryAgain': 'पुनः प्रयास करें',
    'noHistory': 'अभी तक कोई इतिहास नहीं',
    'historySubtitle': 'आपकी सिफारिशें यहाँ दिखेंगी',
    'clearHistory': 'इतिहास साफ़ करें',
    'clearHistoryMsg': 'सभी सिफारिशें हटाएं?',
    'cancel': 'रद्द करें',
    'clear': 'साफ़ करें',
    'fetchWeatherFirst': 'कृपया अपना शहर दर्ज करें!',
    'serverWaking': '⏳ सर्वर जाग रहा है, 10 सेकंड बाद प्रयास करें!',
    'cityNotFound': 'शहर नहीं मिला। मुंबई या दिल्ली आज़माएं',
    'fetchingWeather': 'मौसम प्राप्त हो रहा है...',
    'enterCityToLoad': 'मौसम लोड करने के लिए शहर दर्ज करें',
    'retry': 'पुनः प्रयास',
    'nitrogen': 'नाइट्रोजन (N)',
    'phosphorus': 'फास्फोरस (P)',
    'potassium': 'पोटेशियम (K)',
    'phLevel': 'pH स्तर',
    'soilSummary': 'मिट्टी सारांश',
    'fertilizer': 'उर्वरक',
    'language': 'भाषा',
    'selectLanguage': 'भाषा चुनें',
    'agriNews': 'कृषि समाचार',
    'farmingTips': 'खेती की सलाह',
    'govSchemes': 'सरकारी योजनाएं',
    'mandiRates': 'मंडी भाव',
    'loadingNews': 'लोड हो रहा है...',
    'noNews': 'समाचार नहीं',
    'todaysTip': 'आज की सलाह',
    'profileTitle': 'मेरी प्रोफ़ाइल',
    'farmerName': 'किसान का नाम',
    'farmSize': 'खेत का आकार (एकड़)',
    'village': 'गांव',
    'taluk': 'तालुक',
    'district': 'जिला',
    'state': 'राज्य',
    'myCrops': 'मेरी फसलें',
    'soilPreference': 'मिट्टी का प्रकार',
    'saveProfile': 'प्रोफ़ाइल सहेजें',
    'profileSaved': '✅ प्रोफ़ाइल सहेजी!',
    'editProfile': 'प्रोफ़ाइल संपादित करें',
    'selectState': 'राज्य चुनें',
    'selectCrops': 'फसलें चुनें',
    'photoHint': 'फ़ोटो जोड़ने के लिए टैप करें',
    'required': 'आवश्यक',
  },
  'ta': {
    'appName': 'அக்ரோவைஸ்',
    'tagline': 'AI பயிர் ஆலோசகர்',
    'home': 'முகப்பு',
    'news': 'செய்திகள்',
    'profile': 'சுயவிவரம்',
    'history': 'வரலாறு',
    'locationWeather': 'இடம் மற்றும் வானிலை',
    'enterCity': 'நகர பெயரை உள்ளிடுக (எ.கா: சென்னை)',
    'soilNutrients': 'மண் ஊட்டச்சத்துகள்',
    'soilType': 'மண் வகை',
    'getRecommendation': 'பரிந்துரை பெறுக',
    'yourRecommendation': 'உங்கள் பரிந்துரை',
    'recommendedCrop': 'பரிந்துரைக்கப்பட்ட பயிர்',
    'recommendedFertilizer': 'பரிந்துரைக்கப்பட்ட உரம்',
    'confidence': 'நம்பகத்தன்மை',
    'season': 'பருவம்',
    'duration': 'கால அளவு',
    'water': 'நீர்',
    'top3': 'சிறந்த 3 மாற்றுகள்',
    'tryAgain': 'மீண்டும் முயற்சிக்கவும்',
    'noHistory': 'இன்னும் வரலாறு இல்லை',
    'historySubtitle': 'உங்கள் பரிந்துரைகள் இங்கே தெரியும்',
    'clearHistory': 'வரலாற்றை அழிக்கவும்',
    'clearHistoryMsg': 'அனைத்து பரிந்துரைகளையும் நீக்கவா?',
    'cancel': 'ரத்து செய்',
    'clear': 'அழி',
    'fetchWeatherFirst': 'நகரத்தை உள்ளிட்டு வானிலை பெறுக!',
    'serverWaking': '⏳ சர்வர் விழித்துக்கொள்கிறது!',
    'cityNotFound': 'நகரம் கிடைக்கவில்லை',
    'fetchingWeather': 'வானிலை பெறப்படுகிறது...',
    'enterCityToLoad': 'வானிலை ஏற்ற நகரத்தை உள்ளிடுக',
    'retry': 'மீண்டும் முயற்சி',
    'nitrogen': 'நைட்ரஜன் (N)',
    'phosphorus': 'பாஸ்பரஸ் (P)',
    'potassium': 'பொட்டாசியம் (K)',
    'phLevel': 'pH அளவு',
    'soilSummary': 'மண் சுருக்கம்',
    'fertilizer': 'உரம்',
    'language': 'மொழி',
    'selectLanguage': 'மொழியை தேர்ந்தெடுக்கவும்',
    'agriNews': 'வேளாண் செய்திகள்',
    'farmingTips': 'விவசாய குறிப்புகள்',
    'govSchemes': 'அரசு திட்டங்கள்',
    'mandiRates': 'சந்தை விலை',
    'loadingNews': 'ஏற்றுகிறது...',
    'noNews': 'செய்திகள் இல்லை',
    'todaysTip': 'இன்றைய குறிப்பு',
    'profileTitle': 'என் சுயவிவரம்',
    'farmerName': 'விவசாயி பெயர்',
    'farmSize': 'நிலம் (ஏக்கர்)',
    'village': 'கிராமம்',
    'taluk': 'தாலுகா',
    'district': 'மாவட்டம்',
    'state': 'மாநிலம்',
    'myCrops': 'என் பயிர்கள்',
    'soilPreference': 'மண் வகை',
    'saveProfile': 'சுயவிவரம் சேமி',
    'profileSaved': '✅ சேமிக்கப்பட்டது!',
    'editProfile': 'சுயவிவரம் திருத்து',
    'selectState': 'மாநிலம் தேர்வு',
    'selectCrops': 'பயிர்கள் தேர்வு',
    'photoHint': 'புகைப்படம் சேர்க்க தட்டவும்',
    'required': 'தேவை',
  },
  'te': {
    'appName': 'అగ్రోవైజ్',
    'tagline': 'AI పంట సలహాదారు',
    'home': 'హోమ్',
    'news': 'వార్తలు',
    'profile': 'ప్రొఫైల్',
    'history': 'చరిత్ర',
    'locationWeather': 'స్థానం మరియు వాతావరణం',
    'enterCity': 'నగర పేరు నమోదు చేయండి (ఉదా: హైదరాబాద్)',
    'soilNutrients': 'నేల పోషకాలు',
    'soilType': 'నేల రకం',
    'getRecommendation': 'సిఫారసు పొందండి',
    'yourRecommendation': 'మీ సిఫారసు',
    'recommendedCrop': 'సిఫారసు చేసిన పంట',
    'recommendedFertilizer': 'సిఫారసు చేసిన ఎరువు',
    'confidence': 'నమ్మకం',
    'season': 'సీజన్',
    'duration': 'వ్యవధి',
    'water': 'నీరు',
    'top3': 'టాప్ 3 ప్రత్యామ్నాయాలు',
    'tryAgain': 'మళ్ళీ ప్రయత్నించండి',
    'noHistory': 'ఇంకా చరిత్ర లేదు',
    'historySubtitle': 'మీ సిఫారసులు ఇక్కడ కనిపిస్తాయి',
    'clearHistory': 'చరిత్రను తొలగించు',
    'clearHistoryMsg': 'అన్ని సిఫారసులను తొలగించాలా?',
    'cancel': 'రద్దు చేయి',
    'clear': 'తొలగించు',
    'fetchWeatherFirst': 'నగరాన్ని నమోదు చేసి వాతావరణం తీసుకోండి!',
    'serverWaking': '⏳ సర్వర్ మేల్కొంటోంది!',
    'cityNotFound': 'నగరం కనుగొనబడలేదు',
    'fetchingWeather': 'వాతావరణం తీసుకోబడుతోంది...',
    'enterCityToLoad': 'వాతావరణం లోడ్ చేయడానికి నగరం నమోదు చేయండి',
    'retry': 'మళ్ళీ ప్రయత్నం',
    'nitrogen': 'నత్రజని (N)',
    'phosphorus': 'భాస్వరం (P)',
    'potassium': 'పొటాషియం (K)',
    'phLevel': 'pH స్థాయి',
    'soilSummary': 'నేల సారాంశం',
    'fertilizer': 'ఎరువు',
    'language': 'భాష',
    'selectLanguage': 'భాష ఎంచుకోండి',
    'agriNews': 'వ్యవసాయ వార్తలు',
    'farmingTips': 'వ్యవసాయ చిట్కాలు',
    'govSchemes': 'ప్రభుత్వ పథకాలు',
    'mandiRates': 'మండి రేట్లు',
    'loadingNews': 'లోడ్ అవుతోంది...',
    'noNews': 'వార్తలు లేవు',
    'todaysTip': 'నేటి చిట్కా',
    'profileTitle': 'నా ప్రొఫైల్',
    'farmerName': 'రైతు పేరు',
    'farmSize': 'పొలం పరిమాణం (ఎకరాలు)',
    'village': 'గ్రామం',
    'taluk': 'తాలూకా',
    'district': 'జిల్లా',
    'state': 'రాష్ట్రం',
    'myCrops': 'నా పంటలు',
    'soilPreference': 'నేల రకం',
    'saveProfile': 'ప్రొఫైల్ సేవ్',
    'profileSaved': '✅ ప్రొఫైల్ సేవ్ అయింది!',
    'editProfile': 'ప్రొఫైల్ సవరించు',
    'selectState': 'రాష్ట్రం ఎంచుకోండి',
    'selectCrops': 'పంటలు ఎంచుకోండి',
    'photoHint': 'ఫోటో జోడించడానికి నొక్కండి',
    'required': 'అవసరం',
  },
};

String t(String key, AppLanguage lang) =>
    _translations[lang.code]?[key] ?? _translations['en']?[key] ?? key;

// ─── FARMING TIPS ────────────────────────────────────────────
const List<String> _tips = [
  '🌱 Test your soil pH before planting. Most crops grow best between pH 6.0–7.0.',
  '💧 Water crops in the early morning to reduce evaporation and fungal diseases.',
  '🌿 Use crop rotation every season to prevent soil nutrient depletion.',
  '🐛 Introduce natural predators like ladybugs to control aphid populations.',
  '🌾 Add organic compost to improve soil structure and water retention.',
  '☀️ Ensure your crops get at least 6 hours of direct sunlight daily.',
  '🧪 Apply fertilizers based on soil test results, not guesswork.',
  '🌧️ Collect rainwater for irrigation during dry seasons.',
  '🍂 Use mulching to retain moisture and suppress weed growth.',
  '🦋 Plant pollinator-friendly flowers near crops to improve yield.',
  '🔬 Inspect plants weekly for early signs of disease or pest damage.',
  '📅 Keep a farm diary to track what works best each season.',
];

// ─── GOV SCHEMES ─────────────────────────────────────────────
const List<Map<String, String>> _govSchemes = [
  {
    'title': 'PM-KISAN Scheme',
    'desc':
        'Direct income support of ₹6,000/year to eligible farmer families in 3 installments.',
    'link': 'https://pmkisan.gov.in',
    'emoji': '💰',
    'tag': 'Income Support'
  },
  {
    'title': 'PM Fasal Bima Yojana',
    'desc':
        'Crop insurance scheme providing financial support to farmers suffering crop loss due to calamities.',
    'link': 'https://pmfby.gov.in',
    'emoji': '🛡️',
    'tag': 'Insurance'
  },
  {
    'title': 'Soil Health Card Scheme',
    'desc':
        'Free soil health cards to farmers with crop-wise recommendations of nutrients and fertilizers.',
    'link': 'https://soilhealth.dac.gov.in',
    'emoji': '🧪',
    'tag': 'Soil Health'
  },
  {
    'title': 'Kisan Credit Card',
    'desc':
        'Provides farmers with affordable credit for agricultural needs at subsidized interest rates.',
    'link': 'https://www.nabard.org',
    'emoji': '💳',
    'tag': 'Credit'
  },
  {
    'title': 'National Agriculture Market (eNAM)',
    'desc':
        'Online trading platform for agricultural commodities to get better prices for produce.',
    'link': 'https://enam.gov.in',
    'emoji': '🏪',
    'tag': 'Market'
  },
  {
    'title': 'PMKSY - Irrigation Scheme',
    'desc':
        'Har Khet Ko Pani — ensures water to every field through micro-irrigation support.',
    'link': 'https://pmksy.gov.in',
    'emoji': '💧',
    'tag': 'Irrigation'
  },
];

// ─── MANDI RATES ─────────────────────────────────────────────
const List<Map<String, String>> _mandiRates = [
  {
    'crop': 'Rice (Paddy)',
    'price': '₹2,183',
    'unit': 'quintal',
    'market': 'MSP 2024-25',
    'emoji': '🌾'
  },
  {
    'crop': 'Wheat',
    'price': '₹2,275',
    'unit': 'quintal',
    'market': 'MSP 2024-25',
    'emoji': '🌿'
  },
  {
    'crop': 'Maize',
    'price': '₹2,090',
    'unit': 'quintal',
    'market': 'MSP 2024-25',
    'emoji': '🌽'
  },
  {
    'crop': 'Cotton',
    'price': '₹7,121',
    'unit': 'quintal',
    'market': 'MSP 2024-25',
    'emoji': '🤍'
  },
  {
    'crop': 'Soybean',
    'price': '₹4,892',
    'unit': 'quintal',
    'market': 'MSP 2024-25',
    'emoji': '🟡'
  },
  {
    'crop': 'Groundnut',
    'price': '₹6,783',
    'unit': 'quintal',
    'market': 'MSP 2024-25',
    'emoji': '🥜'
  },
  {
    'crop': 'Sugarcane',
    'price': '₹340',
    'unit': 'quintal',
    'market': 'FRP 2024-25',
    'emoji': '🎋'
  },
  {
    'crop': 'Tomato',
    'price': '₹1,200',
    'unit': 'quintal',
    'market': 'Avg India',
    'emoji': '🍅'
  },
  {
    'crop': 'Onion',
    'price': '₹800',
    'unit': 'quintal',
    'market': 'Avg India',
    'emoji': '🧅'
  },
  {
    'crop': 'Potato',
    'price': '₹1,100',
    'unit': 'quintal',
    'market': 'Avg India',
    'emoji': '🥔'
  },
];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const AgroWiseApp());
}

class AppColors {
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color accent = Color(0xFF76C442);
  static const Color accentLight = Color(0xFFA8E063);
  static const Color gold = Color(0xFFF79C00);
  static const Color bg = Color(0xFFF1F8E9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color soil = Color(0xFF6D4C41);
}

// ─── ROOT APP ────────────────────────────────────────────────
class AgroWiseApp extends StatefulWidget {
  const AgroWiseApp({super.key});
  static _AgroWiseAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_AgroWiseAppState>();
  @override
  State<AgroWiseApp> createState() => _AgroWiseAppState();
}

class _AgroWiseAppState extends State<AgroWiseApp> {
  AppLanguage _language = AppLanguage.english;
  AppLanguage get language => _language;
  void setLanguage(AppLanguage lang) => setState(() => _language = lang);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
      ),
      home: SplashPage(language: _language),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SPLASH PAGE
// ═══════════════════════════════════════════════════════════
class SplashPage extends StatefulWidget {
  final AppLanguage language;
  const SplashPage({super.key, required this.language});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _logoScale = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.5)));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(_textCtrl);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _logoCtrl.forward().then((_) => _textCtrl.forward());
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, a, __) => MainShell(language: widget.language),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 600),
            ));
      }
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D2818), Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                    opacity: _logoFade,
                    child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.accentLight.withOpacity(0.4),
                                width: 2)),
                        child: const Center(child: _AgroLogo(size: 84))))),
            const SizedBox(height: 36),
            SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                    opacity: _textFade,
                    child: Column(children: [
                      Text(t('appName', lang).toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.accentLight,
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 7)),
                      const SizedBox(height: 8),
                      Text(t('tagline', lang),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 12,
                              letterSpacing: 3)),
                    ]))),
            const SizedBox(height: 64),
            FadeTransition(
                opacity: _textFade,
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accentLight.withOpacity(0.6)))),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MAIN SHELL — Bottom Navigation
// ═══════════════════════════════════════════════════════════
class MainShell extends StatefulWidget {
  final AppLanguage language;
  const MainShell({super.key, required this.language});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late AppLanguage _lang;

  @override
  void initState() {
    super.initState();
    _lang = widget.language;
  }

  void _showLanguagePicker() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(t('selectLanguage', _lang)),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: AppLanguage.values
                      .map((lang) => ListTile(
                            title: Text(lang.nativeName,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            trailing: _lang == lang
                                ? const Icon(Icons.check_circle,
                                    color: AppColors.primary)
                                : null,
                            onTap: () {
                              setState(() => _lang = lang);
                              AgroWiseApp.of(context)?.setLanguage(lang);
                              Navigator.pop(context);
                            },
                          ))
                      .toList()),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(language: _lang),
      NewsPage(language: _lang),
      ProfilePage(language: _lang),
      HistoryPage(language: _lang),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Row(children: [
          const _AgroLogo(size: 28),
          const SizedBox(width: 10),
          const Text('AgroWise',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20)),
        ]),
        actions: [
          _ProfileAvatar(onTap: () => setState(() => _currentIndex = 2)),
          TextButton.icon(
            onPressed: _showLanguagePicker,
            icon: const Icon(Icons.language, color: Colors.white, size: 18),
            label: Text(_lang.nativeName,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home, color: AppColors.primary),
              label: t('home', _lang)),
          NavigationDestination(
              icon: const Icon(Icons.newspaper_outlined),
              selectedIcon:
                  const Icon(Icons.newspaper, color: AppColors.primary),
              label: t('news', _lang)),
          NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person, color: AppColors.primary),
              label: t('profile', _lang)),
          NavigationDestination(
              icon: const Icon(Icons.history_outlined),
              selectedIcon: const Icon(Icons.history, color: AppColors.primary),
              label: t('history', _lang)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// HOME PAGE
// ═══════════════════════════════════════════════════════════
class HomePage extends StatefulWidget {
  final AppLanguage language;
  const HomePage({super.key, required this.language});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppLanguage _lang;
  final _formKey = GlobalKey<FormState>();
  final _nCtrl = TextEditingController();
  final _pCtrl = TextEditingController();
  final _kCtrl = TextEditingController();
  final _phCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  String _soilType = 'Loamy';
  bool _loadingWeather = false;
  bool _loadingResult = false;
  Map<String, dynamic>? _weather;
  String? _weatherError;
  double? _lat, _lon;

  final List<String> _soilTypes = ['Black', 'Clayey', 'Loamy', 'Red', 'Sandy'];
  final List<String> _quickCities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Chennai',
    'Hyderabad',
    'Pune',
    'Mangalore',
    'Udupi',
  ];

  @override
  void initState() {
    super.initState();
    _lang = widget.language;
    _wakeUpBackend();
    _loadProfileDefaults();
  }

  Future<void> _wakeUpBackend() async {
    try {
      await http
          .get(Uri.parse('$BASE_URL/'))
          .timeout(const Duration(seconds: 60));
    } catch (_) {}
  }

  Future<void> _loadProfileDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    final soil = prefs.getString('profile_soil') ?? '';
    if (soil.isNotEmpty && mounted) setState(() => _soilType = soil);
  }

  @override
  void dispose() {
    _nCtrl.dispose();
    _pCtrl.dispose();
    _kCtrl.dispose();
    _phCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchWeatherByCity(String city) async {
    if (city.trim().isEmpty) return;
    setState(() {
      _loadingWeather = true;
      _weatherError = null;
      _weather = null;
    });
    try {
      final wRes = await http
          .get(Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather'
            '?q=${Uri.encodeComponent(city.trim())}&appid=$WEATHER_API_KEY&units=metric',
          ))
          .timeout(const Duration(seconds: 10));
      if (wRes.statusCode != 200) throw Exception(t('cityNotFound', _lang));
      final wd = json.decode(wRes.body);
      _lat = (wd['coord']['lat'] as num).toDouble();
      _lon = (wd['coord']['lon'] as num).toDouble();
      setState(() {
        _weather = {
          'temperature': (wd['main']['temp'] as num).toDouble(),
          'humidity': (wd['main']['humidity'] as num).toDouble(),
          'rainfall': ((wd['rain'] ?? {})['1h'] ?? 0.0),
          'city': wd['name'],
          'country': wd['sys']['country'],
          'weather_description':
              (wd['weather'][0]['description'] as String).capitalize(),
        };
      });
    } catch (e) {
      setState(() {
        _weatherError = e.toString().replaceAll('Exception: ', '');
        _lat = null;
        _lon = null;
      });
    } finally {
      setState(() => _loadingWeather = false);
    }
  }

  Future<void> _getRecommendation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_weather == null || _lat == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(t('fetchWeatherFirst', _lang)),
          backgroundColor: Colors.orange));
      return;
    }
    setState(() => _loadingResult = true);
    try {
      final res = await http
          .post(
            Uri.parse('$BASE_URL/recommend'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'nitrogen': double.parse(_nCtrl.text),
              'phosphorus': double.parse(_pCtrl.text),
              'potassium': double.parse(_kCtrl.text),
              'ph': double.parse(_phCtrl.text),
              'soil_type': _soilType,
              'latitude': _lat,
              'longitude': _lon,
            }),
          )
          .timeout(const Duration(seconds: 60));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        await _saveHistory(data);
        if (mounted)
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ResultPage(data: data, language: _lang)));
      } else {
        throw Exception('API error ${res.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().contains('timeout')
            ? t('serverWaking', _lang)
            : 'Error: $e'),
        backgroundColor:
            e.toString().contains('timeout') ? Colors.orange : Colors.red,
        duration: const Duration(seconds: 4),
      ));
    } finally {
      setState(() => _loadingResult = false);
    }
  }

  Future<void> _saveHistory(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('history') ?? [];
    list.insert(
        0,
        json.encode({
          'crop': data['crop_recommendation']['recommended_crop'],
          'fertilizer': data['fertilizer_recommendation']['fertilizer_name'],
          'city': data['location']['city'],
          'date': DateTime.now().toIso8601String(),
          'confidence': data['crop_recommendation']['confidence'],
        }));
    if (list.length > 20) list.removeLast();
    await prefs.setStringList('history', list);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SectionLabel(
                icon: Icons.wb_sunny_outlined,
                label: t('locationWeather', _lang)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextFormField(
                controller: _cityCtrl,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: _fetchWeatherByCity,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: t('enterCity', _lang),
                  prefixIcon: const Icon(Icons.location_city_outlined,
                      color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.3))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.3))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              )),
              const SizedBox(width: 10),
              SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loadingWeather
                        ? null
                        : () => _fetchWeatherByCity(_cityCtrl.text),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16)),
                    child: _loadingWeather
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.search_rounded, size: 22),
                  )),
            ]),
            const SizedBox(height: 10),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickCities
                    .map((city) => GestureDetector(
                          onTap: () {
                            _cityCtrl.text = city;
                            _fetchWeatherByCity(city);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        AppColors.primary.withOpacity(0.25))),
                            child: Text(city,
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ))
                    .toList()),
            const SizedBox(height: 14),
            _WeatherCard(
                weather: _weather,
                loading: _loadingWeather,
                error: _weatherError,
                onRetry: () => _fetchWeatherByCity(_cityCtrl.text),
                lang: _lang),
            const SizedBox(height: 24),
            _SectionLabel(
                icon: Icons.science_outlined, label: t('soilNutrients', _lang)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _SoilField(
                      ctrl: _nCtrl,
                      label: t('nitrogen', _lang),
                      hint: '0–140',
                      color: const Color(0xFF388E3C))),
              const SizedBox(width: 10),
              Expanded(
                  child: _SoilField(
                      ctrl: _pCtrl,
                      label: t('phosphorus', _lang),
                      hint: '0–145',
                      color: const Color(0xFF1565C0))),
              const SizedBox(width: 10),
              Expanded(
                  child: _SoilField(
                      ctrl: _kCtrl,
                      label: t('potassium', _lang),
                      hint: '0–205',
                      color: const Color(0xFFF57F17))),
            ]),
            const SizedBox(height: 12),
            _SoilField(
                ctrl: _phCtrl,
                label: t('phLevel', _lang),
                hint: '0–14',
                color: AppColors.soil,
                isDecimal: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final d = double.tryParse(v);
                  if (d == null || d < 0 || d > 14) return 'Enter 0–14';
                  return null;
                }),
            const SizedBox(height: 20),
            _SectionLabel(
                icon: Icons.layers_outlined, label: t('soilType', _lang)),
            const SizedBox(height: 12),
            _SoilTypeSelector(
                selected: _soilType,
                options: _soilTypes,
                onChanged: (v) => setState(() => _soilType = v)),
            const SizedBox(height: 32),
            SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loadingResult ? null : _getRecommendation,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4),
                  child: _loadingResult
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              const Icon(Icons.eco_rounded, size: 22),
                              const SizedBox(width: 10),
                              Text(t('getRecommendation', _lang),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                            ]),
                )),
            const SizedBox(height: 20),
          ])),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// NEWS PAGE
// ═══════════════════════════════════════════════════════════
class NewsPage extends StatefulWidget {
  final AppLanguage language;
  const NewsPage({super.key, required this.language});
  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Map<String, dynamic>> _articles = [];
  bool _loadingNews = false;
  String? _newsError;
  int _tipIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _fetchNews();
    _tipIndex = DateTime.now().day % _tips.length;
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  AppLanguage get _lang => widget.language;

  Future<void> _fetchNews() async {
    setState(() {
      _loadingNews = true;
      _newsError = null;
    });
    try {
      final res = await http
          .get(Uri.parse(
            'https://newsapi.org/v2/everything?q=farming+agriculture+India+crops'
            '&language=en&sortBy=publishedAt&pageSize=20&apiKey=$NEWS_API_KEY',
          ))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final articles =
            List<Map<String, dynamic>>.from(data['articles'] ?? []);
        setState(() {
          _articles = articles
              .where((a) => a['title'] != null && a['title'] != '[Removed]')
              .toList();
        });
      } else {
        throw Exception('News fetch failed');
      }
    } catch (e) {
      setState(() => _newsError = e.toString());
    } finally {
      setState(() => _loadingNews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          color: AppColors.primary,
          child: TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            indicatorColor: AppColors.accentLight,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: t('agriNews', _lang)),
              Tab(text: t('farmingTips', _lang)),
              Tab(text: t('govSchemes', _lang)),
              Tab(text: t('mandiRates', _lang)),
            ],
          )),
      Expanded(
          child: TabBarView(controller: _tabCtrl, children: [
        // Tab 1: News
        _loadingNews
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(t('loadingNews', _lang),
                        style: const TextStyle(color: AppColors.textMuted)),
                  ]))
            : _newsError != null
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        const Icon(Icons.wifi_off,
                            size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(t('noNews', _lang),
                            style: const TextStyle(color: AppColors.textMuted)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: _fetchNews,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary),
                            child: Text(t('retry', _lang),
                                style: const TextStyle(color: Colors.white))),
                      ]))
                : RefreshIndicator(
                    onRefresh: _fetchNews,
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _articles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _NewsCard(article: _articles[i]),
                    )),

        // Tab 2: Farming Tips
        SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ]),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Text('💡', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(t('todaysTip', _lang),
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                        ]),
                        const SizedBox(height: 10),
                        Text(_tips[_tipIndex],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.5,
                                fontWeight: FontWeight.w500)),
                      ])),
              const SizedBox(height: 16),
              ..._tips
                  .asMap()
                  .entries
                  .map((e) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2))
                            ]),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.value.split(' ')[0],
                                  style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(
                                      e.value
                                          .substring(e.value.indexOf(' ') + 1),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                          color: AppColors.textDark))),
                            ]),
                      ))
                  .toList(),
            ])),

        // Tab 3: Govt Schemes
        ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _govSchemes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final s = _govSchemes[i];
              return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ]),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(s['emoji']!,
                              style: const TextStyle(fontSize: 26)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(s['title']!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppColors.textDark)),
                                const SizedBox(height: 2),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                        color:
                                            AppColors.primary.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text(s['tag']!,
                                        style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600))),
                              ])),
                        ]),
                        const SizedBox(height: 10),
                        Text(s['desc']!,
                            style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                                height: 1.5)),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                                  content: Text('Visit: ${s['link']}'))),
                          child: Row(children: [
                            const Icon(Icons.open_in_new,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(s['link']!,
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline)),
                          ]),
                        ),
                      ]));
            }),

        // Tab 4: Mandi Rates
        SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AppColors.gold.withOpacity(0.3))),
                  child: const Row(children: [
                    Text('ℹ️', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 10),
                    Expanded(
                        child: Text(
                            'Prices are MSP/FRP rates. Check local mandi for exact rates.',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textDark,
                                height: 1.4))),
                  ])),
              const SizedBox(height: 16),
              ..._mandiRates
                  .map((m) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2))
                            ]),
                        child: Row(children: [
                          Text(m['emoji']!,
                              style: const TextStyle(fontSize: 26)),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(m['crop']!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppColors.textDark)),
                                Text(m['market']!,
                                    style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12)),
                              ])),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(m['price']!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: AppColors.primary)),
                                Text('per ${m['unit']!}',
                                    style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11)),
                              ]),
                        ]),
                      ))
                  .toList(),
            ])),
      ])),
    ]);
  }
}

// ─── News Card ────────────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  final Map<String, dynamic> article;
  const _NewsCard({required this.article});
  @override
  Widget build(BuildContext context) {
    final title = article['title'] ?? '';
    final source = article['source']?['name'] ?? '';
    final desc = article['description'] ?? '';
    final imgUrl = article['urlToImage'];
    final url = article['url'] ?? '';
    final pubDate = article['publishedAt'] ?? '';
    String timeAgo = '';
    try {
      final dt = DateTime.parse(pubDate);
      final diff = DateTime.now().difference(dt);
      timeAgo =
          diff.inHours < 24 ? '${diff.inHours}h ago' : '${diff.inDays}d ago';
    } catch (_) {}
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Read more: $url'),
          duration: const Duration(seconds: 3))),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (imgUrl != null)
            ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(imgUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        height: 80,
                        color: AppColors.bg,
                        child: const Center(
                            child: Icon(Icons.image_not_supported,
                                color: AppColors.textMuted))))),
          Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(source,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600))),
                      const Spacer(),
                      Text(timeAgo,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11)),
                    ]),
                    const SizedBox(height: 8),
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textDark,
                            height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(desc,
                          style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 8),
                    const Row(children: [
                      Icon(Icons.open_in_new,
                          size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Read more',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ])),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PROFILE PAGE
// ═══════════════════════════════════════════════════════════
class ProfilePage extends StatefulWidget {
  final AppLanguage language;
  const ProfilePage({super.key, required this.language});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _farmCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();
  final _talukCtrl = TextEditingController();
  final _distCtrl = TextEditingController();

  String _state = '', _soilType = 'Loamy', _photoPath = '';
  bool _saving = false, _editing = false;
  List<String> _myCrops = [];

  final List<String> _soilTypes = ['Black', 'Clayey', 'Loamy', 'Red', 'Sandy'];
  final List<String> _allCrops = [
    'Rice',
    'Maize',
    'Chickpea',
    'Kidney Beans',
    'Pigeon Peas',
    'Moth Beans',
    'Mung Bean',
    'Black Gram',
    'Lentil',
    'Pomegranate',
    'Banana',
    'Mango',
    'Grapes',
    'Watermelon',
    'Muskmelon',
    'Apple',
    'Orange',
    'Papaya',
    'Coconut',
    'Cotton',
    'Jute',
    'Coffee',
    'Wheat',
    'Sugarcane',
    'Groundnut',
    'Soybean',
    'Sunflower',
    'Turmeric',
    'Ginger',
  ];
  final List<String> _states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi',
    'Jammu & Kashmir',
    'Ladakh',
    'Puducherry',
  ];

  AppLanguage get _lang => widget.language;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _farmCtrl.dispose();
    _villageCtrl.dispose();
    _talukCtrl.dispose();
    _distCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text = prefs.getString('profile_name') ?? '';
      _farmCtrl.text = prefs.getString('profile_farm') ?? '';
      _villageCtrl.text = prefs.getString('profile_village') ?? '';
      _talukCtrl.text = prefs.getString('profile_taluk') ?? '';
      _distCtrl.text = prefs.getString('profile_district') ?? '';
      _state = prefs.getString('profile_state') ?? '';
      _soilType = prefs.getString('profile_soil') ?? 'Loamy';
      _photoPath = prefs.getString('profile_photo') ?? '';
      _myCrops = prefs.getStringList('profile_crops') ?? [];
      _editing = _nameCtrl.text.isEmpty;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _nameCtrl.text);
    await prefs.setString('profile_farm', _farmCtrl.text);
    await prefs.setString('profile_village', _villageCtrl.text);
    await prefs.setString('profile_taluk', _talukCtrl.text);
    await prefs.setString('profile_district', _distCtrl.text);
    await prefs.setString('profile_state', _state);
    await prefs.setString('profile_soil', _soilType);
    await prefs.setString('profile_photo', _photoPath);
    await prefs.setStringList('profile_crops', _myCrops);
    setState(() {
      _saving = false;
      _editing = false;
    });
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(t('profileSaved', _lang)),
          backgroundColor: AppColors.primary));
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        ListTile(
            leading: const Icon(Icons.camera_alt, color: AppColors.primary),
            title: const Text('Take Photo'),
            onTap: () async {
              Navigator.pop(context);
              final img = await picker.pickImage(
                  source: ImageSource.camera, imageQuality: 70);
              if (img != null) setState(() => _photoPath = img.path);
            }),
        ListTile(
            leading: const Icon(Icons.photo_library, color: AppColors.primary),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              Navigator.pop(context);
              final img = await picker.pickImage(
                  source: ImageSource.gallery, imageQuality: 70);
              if (img != null) setState(() => _photoPath = img.path);
            }),
        ListTile(
            leading: const Icon(Icons.cancel, color: Colors.red),
            title: const Text('Cancel'),
            onTap: () => Navigator.pop(context)),
        const SizedBox(height: 8),
      ])),
    );
  }

  void _showCropPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
          builder: (ctx, setModal) => DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (_, ctrl) => Column(children: [
                    const SizedBox(height: 12),
                    Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 12),
                    Text(t('selectCrops', _lang),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 12),
                    Expanded(
                        child: ListView(
                            controller: ctrl,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: _allCrops
                                .map((crop) => CheckboxListTile(
                                      title: Text(crop),
                                      value: _myCrops.contains(crop),
                                      activeColor: AppColors.primary,
                                      onChanged: (v) {
                                        setModal(() {
                                          if (v == true)
                                            _myCrops.add(crop);
                                          else
                                            _myCrops.remove(crop);
                                          setState(() {});
                                        });
                                      },
                                    ))
                                .toList())),
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                child: const Text('Done',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700))))),
                  ]))),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_editing && _nameCtrl.text.isNotEmpty) {
      // VIEW MODE
      return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6))
                    ]),
                child: Column(children: [
                  CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: _photoPath.isNotEmpty
                          ? FileImage(File(_photoPath))
                          : null,
                      child: _photoPath.isEmpty
                          ? Text(
                              _nameCtrl.text.isNotEmpty
                                  ? _nameCtrl.text[0].toUpperCase()
                                  : '👤',
                              style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white))
                          : null),
                  const SizedBox(height: 12),
                  Text(_nameCtrl.text,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  if (_villageCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('${_villageCtrl.text}, $_state',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (_farmCtrl.text.isNotEmpty)
                      _InfoBadge(
                          icon: Icons.landscape,
                          label: '${_farmCtrl.text} acres'),
                    if (_farmCtrl.text.isNotEmpty) const SizedBox(width: 8),
                    _InfoBadge(icon: Icons.layers, label: _soilType),
                  ]),
                ])),
            const SizedBox(height: 16),
            if (_villageCtrl.text.isNotEmpty || _state.isNotEmpty)
              _ProfileInfoCard(title: '📍 Location', items: [
                if (_villageCtrl.text.isNotEmpty)
                  MapEntry(t('village', _lang), _villageCtrl.text),
                if (_talukCtrl.text.isNotEmpty)
                  MapEntry(t('taluk', _lang), _talukCtrl.text),
                if (_distCtrl.text.isNotEmpty)
                  MapEntry(t('district', _lang), _distCtrl.text),
                if (_state.isNotEmpty) MapEntry(t('state', _lang), _state),
              ]),
            const SizedBox(height: 12),
            if (_myCrops.isNotEmpty) ...[
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ]),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🌾 ${t('myCrops', _lang)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.textDark)),
                        const SizedBox(height: 12),
                        Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _myCrops
                                .map((c) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: AppColors.primary
                                                  .withOpacity(0.3))),
                                      child: Text(c,
                                          style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                    ))
                                .toList()),
                      ])),
              const SizedBox(height: 12),
            ],
            SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _editing = true),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(t('editProfile', _lang),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                )),
            const SizedBox(height: 24),
          ]));
    }

    // EDIT MODE
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                  child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Stack(children: [
                        CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage: _photoPath.isNotEmpty
                                ? FileImage(File(_photoPath))
                                : null,
                            child: _photoPath.isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        const Icon(Icons.camera_alt,
                                            color: AppColors.primary, size: 28),
                                        const SizedBox(height: 4),
                                        Text(t('photoHint', _lang),
                                            style: const TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 9),
                                            textAlign: TextAlign.center),
                                      ])
                                : null),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2)),
                                child: const Icon(Icons.edit,
                                    color: Colors.white, size: 14))),
                      ]))),
              const SizedBox(height: 24),
              _SectionLabel(icon: Icons.person_outline, label: 'Personal Info'),
              const SizedBox(height: 12),
              _ProfileField(
                  ctrl: _nameCtrl,
                  label: t('farmerName', _lang),
                  icon: Icons.person,
                  required: true),
              const SizedBox(height: 12),
              _ProfileField(
                  ctrl: _farmCtrl,
                  label: t('farmSize', _lang),
                  icon: Icons.landscape,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              _SectionLabel(
                  icon: Icons.location_on_outlined, label: 'Location'),
              const SizedBox(height: 12),
              _ProfileField(
                  ctrl: _villageCtrl,
                  label: t('village', _lang),
                  icon: Icons.villa),
              const SizedBox(height: 12),
              _ProfileField(
                  ctrl: _talukCtrl, label: t('taluk', _lang), icon: Icons.map),
              const SizedBox(height: 12),
              _ProfileField(
                  ctrl: _distCtrl,
                  label: t('district', _lang),
                  icon: Icons.location_city),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _state.isEmpty ? null : _state,
                hint: Text(t('selectState', _lang)),
                decoration: InputDecoration(
                  labelText: t('state', _lang),
                  prefixIcon:
                      const Icon(Icons.flag_outlined, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.3))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.3))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2)),
                ),
                items: _states
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _state = v ?? ''),
              ),
              const SizedBox(height: 20),
              _SectionLabel(
                  icon: Icons.eco_outlined, label: t('myCrops', _lang)),
              const SizedBox(height: 12),
              GestureDetector(
                  onTap: _showCropPicker,
                  child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3))),
                      child: _myCrops.isEmpty
                          ? Row(children: [
                              const Icon(Icons.add_circle_outline,
                                  color: AppColors.primary),
                              const SizedBox(width: 10),
                              Text(t('selectCrops', _lang),
                                  style: const TextStyle(
                                      color: AppColors.textMuted)),
                            ])
                          : Wrap(spacing: 6, runSpacing: 6, children: [
                              ..._myCrops.map((c) => Chip(
                                  label: Text(c,
                                      style: const TextStyle(fontSize: 12)),
                                  backgroundColor:
                                      AppColors.primary.withOpacity(0.1),
                                  side: BorderSide(
                                      color:
                                          AppColors.primary.withOpacity(0.3)),
                                  deleteIcon: const Icon(Icons.close, size: 14),
                                  onDeleted: () =>
                                      setState(() => _myCrops.remove(c)))),
                              Chip(
                                  label: const Text('+ Add',
                                      style: TextStyle(fontSize: 12)),
                                  backgroundColor:
                                      AppColors.accent.withOpacity(0.15),
                                  side: BorderSide(
                                      color:
                                          AppColors.accent.withOpacity(0.3))),
                            ]))),
              const SizedBox(height: 20),
              _SectionLabel(
                  icon: Icons.layers_outlined,
                  label: t('soilPreference', _lang)),
              const SizedBox(height: 12),
              _SoilTypeSelector(
                  selected: _soilType,
                  options: _soilTypes,
                  onChanged: (v) => setState(() => _soilType = v)),
              const SizedBox(height: 32),
              SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4),
                    child: _saving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(t('saveProfile', _lang),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                  )),
              const SizedBox(height: 24),
            ])));
  }
}

// ─── Profile Avatar ───────────────────────────────────────────
class _ProfileAvatar extends StatefulWidget {
  final VoidCallback onTap;
  const _ProfileAvatar({required this.onTap});
  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  String _name = '', _imgPath = '';
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('profile_name') ?? '';
      _imgPath = prefs.getString('profile_photo') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: widget.onTap,
        child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.accentLight.withOpacity(0.3),
                backgroundImage:
                    _imgPath.isNotEmpty ? FileImage(File(_imgPath)) : null,
                child: _imgPath.isEmpty
                    ? Text(_name.isNotEmpty ? _name[0].toUpperCase() : '👤',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white))
                    : null)),
      );
}

// ─── Profile Helper Widgets ───────────────────────────────────
class _ProfileField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final bool required;
  final TextInputType keyboardType;
  const _ProfileField(
      {required this.ctrl,
      required this.label,
      required this.icon,
      this.required = false,
      this.keyboardType = TextInputType.text});
  @override
  Widget build(BuildContext context) => TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.primary.withOpacity(0.3))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.primary.withOpacity(0.3))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        validator: required
            ? (v) {
                if (v == null || v.isEmpty) return 'Required';
                return null;
              }
            : null,
      );
}

class _ProfileInfoCard extends StatelessWidget {
  final String title;
  final List<MapEntry<String, String>> items;
  const _ProfileInfoCard({required this.title, required this.items});
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textDark)),
          const SizedBox(height: 12),
          ...items.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                SizedBox(
                    width: 80,
                    child: Text(e.key,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 13))),
                const Text(': ', style: TextStyle(color: AppColors.textMuted)),
                Expanded(
                    child: Text(e.value,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textDark))),
              ]))),
        ]));
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoBadge({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white70, size: 13),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ]));
}

// ═══════════════════════════════════════════════════════════
// RESULT PAGE
// ═══════════════════════════════════════════════════════════
class ResultPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final AppLanguage language;
  const ResultPage({super.key, required this.data, required this.language});

  @override
  Widget build(BuildContext context) {
    final lang = language;
    final crop = data['crop_recommendation'];
    final fert = data['fertilizer_recommendation'];
    final loc = data['location'];
    final wthr = data['weather'];
    final soil = data['soil'];
    final top3 =
        List<Map<String, dynamic>>.from(crop['top_3_alternatives'] ?? []);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: Text(t('yourRecommendation', lang),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _InfoChipRow(
              city: loc['city'],
              country: loc['country'],
              temp: (wthr['temperature_c'] as num).toDouble(),
              humidity: (wthr['humidity_percent'] as num).toDouble()),
          const SizedBox(height: 20),
          // Crop card
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6))
                  ]),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('🌾', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 8),
                      Text(t('recommendedCrop', lang),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ]),
                    const SizedBox(height: 8),
                    Text(crop['recommended_crop'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.accentLight.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                            '${crop['confidence']}% ${t('confidence', lang)}',
                            style: const TextStyle(
                                color: AppColors.accentLight,
                                fontSize: 12,
                                fontWeight: FontWeight.w600))),
                    const SizedBox(height: 20),
                    Row(children: [
                      _CropStat(
                          icon: Icons.wb_sunny_outlined,
                          label: t('season', lang),
                          value: crop['season']),
                      _CropStat(
                          icon: Icons.schedule_outlined,
                          label: t('duration', lang),
                          value: crop['duration']),
                      _CropStat(
                          icon: Icons.water_drop_outlined,
                          label: t('water', lang),
                          value: crop['water_requirement']),
                    ]),
                  ])),
          const SizedBox(height: 16),
          // Fertilizer card
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF8B4F00), Color(0xFFF79C00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.gold.withOpacity(0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 6))
                  ]),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('🧪', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(t('recommendedFertilizer', lang),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ]),
                    const SizedBox(height: 8),
                    Text(fert['fertilizer_name'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800)),
                    Text(fert['full_name'],
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 12),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text('NPK  ${fert['npk_ratio']}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5))),
                    const SizedBox(height: 12),
                    Text(fert['usage_tip'],
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13, height: 1.5)),
                  ])),
          const SizedBox(height: 16),
          _SoilSummaryCard(soil: soil, lang: lang),
          const SizedBox(height: 16),
          if (top3.isNotEmpty) ...[
            _SectionLabel(
                icon: Icons.format_list_numbered, label: t('top3', lang)),
            const SizedBox(height: 12),
            ...top3.map((c) => _AlternativeTile(crop: c)),
            const SizedBox(height: 16),
          ],
          SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(t('tryAgain', lang),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
              )),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// HISTORY PAGE
// ═══════════════════════════════════════════════════════════
class HistoryPage extends StatefulWidget {
  final AppLanguage language;
  const HistoryPage({super.key, required this.language});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('history') ?? [];
    setState(() {
      _history =
          list.map((e) => json.decode(e) as Map<String, dynamic>).toList();
      _loading = false;
    });
  }

  Future<void> _clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    setState(() => _history = []);
  }

  String _fmt(String iso) {
    final d = DateTime.parse(iso).toLocal();
    return '${d.day}/${d.month}/${d.year}  ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: Text(t('history', lang),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white70),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                            title: Text(t('clearHistory', lang)),
                            content: Text(t('clearHistoryMsg', lang)),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(t('cancel', lang))),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(t('clear', lang),
                                      style:
                                          const TextStyle(color: Colors.red))),
                            ],
                          ));
                  if (ok == true) _clear();
                }),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _history.isEmpty
              ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(Icons.history_edu_outlined,
                          size: 72,
                          color: AppColors.textMuted.withOpacity(0.35)),
                      const SizedBox(height: 16),
                      Text(t('noHistory', lang),
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(t('historySubtitle', lang),
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 13)),
                    ]))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final e = _history[i];
                    return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ]),
                        child: Row(children: [
                          Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Center(
                                  child: Text('🌾',
                                      style: TextStyle(fontSize: 22)))),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(e['crop'] ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: AppColors.textDark)),
                                      Text('${e['confidence']}%',
                                          style: const TextStyle(
                                              color: AppColors.accent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                    ]),
                                const SizedBox(height: 4),
                                Text(
                                    '${t('fertilizer', lang)}: ${e['fertilizer']}',
                                    style: const TextStyle(
                                        color: AppColors.soil,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Row(children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 13, color: AppColors.textMuted),
                                  const SizedBox(width: 2),
                                  Text(e['city'] ?? '',
                                      style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12)),
                                  const Spacer(),
                                  Text(_fmt(e['date'] ?? ''),
                                      style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11)),
                                ]),
                              ])),
                        ]));
                  }),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════
class _AgroLogo extends StatelessWidget {
  final double size;
  const _AgroLogo({required this.size});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _LogoPainter());
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    canvas.drawPath(
        Path()
          ..moveTo(w * .5, h * .9)
          ..quadraticBezierTo(w * .48, h * .6, w * .5, h * .3),
        Paint()
          ..color = const Color(0xFF2E7D32)
          ..strokeWidth = w * .08
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
    canvas.drawPath(
        Path()
          ..moveTo(w * .5, h * .55)
          ..quadraticBezierTo(w * .2, h * .35, w * .08, h * .25)
          ..quadraticBezierTo(w * .28, h * .5, w * .5, h * .55)
          ..close(),
        Paint()
          ..color = const Color(0xFF56AB2F)
          ..style = PaintingStyle.fill);
    canvas.drawPath(
        Path()
          ..moveTo(w * .5, h * .45)
          ..quadraticBezierTo(w * .8, h * .25, w * .92, h * .15)
          ..quadraticBezierTo(w * .72, h * .42, w * .5, h * .45)
          ..close(),
        Paint()
          ..color = const Color(0xFF2ECC71)
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        Offset(w * .78, h * .22),
        w * .1,
        Paint()
          ..color = const Color(0xFFF79C00)
          ..style = PaintingStyle.fill);
    canvas.drawPath(
        Path()
          ..moveTo(w * .5, h * .3)
          ..quadraticBezierTo(w * .32, h * .18, w * .25, h * .08)
          ..quadraticBezierTo(w * .42, h * .22, w * .5, h * .3)
          ..close(),
        Paint()
          ..color = const Color(0xFF56AB2F)
          ..style = PaintingStyle.fill);
    canvas.drawPath(
        Path()
          ..moveTo(w * .5, h * .28)
          ..quadraticBezierTo(w * .65, h * .15, w * .7, h * .06)
          ..quadraticBezierTo(w * .58, h * .2, w * .5, h * .28)
          ..close(),
        Paint()
          ..color = const Color(0xFF2ECC71)
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _WeatherCard extends StatelessWidget {
  final Map<String, dynamic>? weather;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final AppLanguage lang;
  const _WeatherCard(
      {required this.weather,
      required this.loading,
      required this.error,
      required this.onRetry,
      required this.lang});

  @override
  Widget build(BuildContext context) {
    if (!loading && weather == null && error == null) {
      return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.2))),
          child: Row(children: [
            const Icon(Icons.cloud_outlined,
                color: AppColors.textMuted, size: 22),
            const SizedBox(width: 10),
            Flexible(
                child: Text(t('enterCityToLoad', lang),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13))),
          ]));
    }
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ]),
        child: loading
            ? Row(children: [
                const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white54)),
                const SizedBox(width: 10),
                Text(t('fetchingWeather', lang),
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
              ])
            : error != null
                ? Row(children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(error!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13))),
                    GestureDetector(
                        onTap: onRetry,
                        child: Text(t('retry', lang),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline))),
                  ])
                : Row(children: [
                    const Text('🌤️', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('${weather!['city']}, ${weather!['country']}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                          Text(weather!['weather_description'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ])),
                    _WStat(
                        value: '${weather!['temperature']}°C',
                        icon: Icons.thermostat_outlined),
                    const SizedBox(width: 16),
                    _WStat(
                        value: '${weather!['humidity']}%',
                        icon: Icons.water_drop_outlined),
                  ]));
  }
}

class _WStat extends StatelessWidget {
  final String value;
  final IconData icon;
  const _WStat({required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      ]);
}

class _SoilField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final Color color;
  final bool isDecimal;
  final String? Function(String?)? validator;
  const _SoilField(
      {required this.ctrl,
      required this.label,
      required this.hint,
      required this.color,
      this.isDecimal = false,
      this.validator});
  @override
  Widget build(BuildContext context) => TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600),
            filled: true,
            fillColor: color.withOpacity(0.06),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color.withOpacity(0.3))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color.withOpacity(0.3))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
        validator: validator ??
            (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (double.tryParse(v) == null) return 'Invalid';
              return null;
            },
      );
}

class _SoilTypeSelector extends StatelessWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _SoilTypeSelector(
      {required this.selected, required this.options, required this.onChanged});
  static const Map<String, Color> _clr = {
    'Black': Color(0xFF263238),
    'Clayey': Color(0xFF795548),
    'Loamy': Color(0xFF558B2F),
    'Red': Color(0xFFC62828),
    'Sandy': Color(0xFFF9A825),
  };
  @override
  Widget build(BuildContext context) => Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((s) {
        final sel = s == selected;
        final c = _clr[s] ?? AppColors.primary;
        return GestureDetector(
            onTap: () => onChanged(s),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                    color: sel ? c : c.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: c.withOpacity(sel ? 1 : 0.3), width: 1.5)),
                child: Text(s,
                    style: TextStyle(
                        color: sel ? Colors.white : c,
                        fontWeight: FontWeight.w700,
                        fontSize: 13))));
      }).toList());
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Flexible(
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textDark))),
      ]);
}

class _CropStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _CropStat(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(
          child: Column(children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 10),
            textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
            textAlign: TextAlign.center),
      ]));
}

class _InfoChipRow extends StatelessWidget {
  final String city, country;
  final double temp, humidity;
  const _InfoChipRow(
      {required this.city,
      required this.country,
      required this.temp,
      required this.humidity});
  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 8, runSpacing: 8, children: [
        _Chip(
            icon: Icons.location_on_outlined,
            label: '$city, $country',
            color: AppColors.primary),
        _Chip(
            icon: Icons.thermostat_outlined,
            label: '${temp}°C',
            color: const Color(0xFFE65100)),
        _Chip(
            icon: Icons.water_drop_outlined,
            label: '$humidity%',
            color: const Color(0xFF1565C0)),
      ]);
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ]));
}

class _SoilSummaryCard extends StatelessWidget {
  final Map<String, dynamic> soil;
  final AppLanguage lang;
  const _SoilSummaryCard({required this.soil, required this.lang});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🪱', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(t('soilSummary', lang),
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textDark)),
        ]),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _SoilVal(
              label: 'N',
              value: '${soil['nitrogen']}',
              color: const Color(0xFF388E3C)),
          _SoilVal(
              label: 'P',
              value: '${soil['phosphorus']}',
              color: const Color(0xFF1565C0)),
          _SoilVal(
              label: 'K',
              value: '${soil['potassium']}',
              color: const Color(0xFFF57F17)),
          _SoilVal(label: 'pH', value: '${soil['ph']}', color: AppColors.soil),
          _SoilVal(
              label: 'Soil',
              value: soil['soil_type'],
              color: AppColors.primary),
        ]),
      ]));
}

class _SoilVal extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SoilVal(
      {required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 16, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ]);
}

class _AlternativeTile extends StatelessWidget {
  final Map<String, dynamic> crop;
  const _AlternativeTile({required this.crop});
  @override
  Widget build(BuildContext context) {
    final conf = (crop['confidence'] as num).toDouble();
    return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ]),
        child: Row(children: [
          const Text('🌱', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
              child: Text((crop['crop'] as String).capitalize(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14))),
          SizedBox(
              width: 80,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                      value: conf / 100,
                      backgroundColor: AppColors.accent.withOpacity(0.15),
                      color: AppColors.accent,
                      minHeight: 6))),
          const SizedBox(width: 8),
          Text('$conf%',
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]));
  }
}

extension StrExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
