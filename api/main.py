from fastapi import FastAPI
import json
import random
import os

# API'nin profesyonel isimlendirmesi
app = FastAPI(title="Bonfire Quotes API")

def load_quotes():
    # quotes.json dosyasının yolunu dinamik olarak bul ve oku
    file_path = os.path.join(os.path.dirname(__file__), 'quotes.json')
    with open(file_path, 'r', encoding='utf-8') as file:
        return json.load(file)

# Profesyonel endpoint isimlendirmesi (v1 = Versiyon 1)
@app.get("/api/v1/quote/daily")
def get_daily_quote():
    quotes_data = load_quotes()
    selected_quote = random.choice(quotes_data)
    
    # Sektör standardı JSON dönüş formatı (status ve data)
    return {
        "status": "success",
        "data": selected_quote
    }