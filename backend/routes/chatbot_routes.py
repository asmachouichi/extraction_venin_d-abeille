from flask import Blueprint, request, jsonify
import requests


chatbot_bp = Blueprint(
    "chatbot",
    __name__
)


OLLAMA_URL = "http://localhost:11434/api/generate"


@chatbot_bp.route("/chat", methods=["POST"])
def chat():

    data = request.json

    user_message = data.get("message")

    if not user_message:
        return jsonify({
            "error": "Message vide"
        }), 400


    prompt = f"""
Tu es un assistant expert en apiculture intelligente et en extraction du venin d'abeille.

Ton rôle est d'aider l'apiculteur à comprendre et utiliser un système IoT intelligent.

Informations sur le système :
- Le système utilise une carte ESP32.
- Les capteurs mesurent la température, l'humidité, le poids du venin et les vibrations.
- Un modèle Machine Learning analyse les données et prédit l'état de la ruche.
- L'application permet le suivi en temps réel et le contrôle de l'extraction.

Règles de réponse :
- Réponds toujours en français.
- Donne des réponses simples, précises et utiles.
- Explique les termes techniques.
- Si tu ne connais pas une information, indique-le clairement.
- Ne crée pas de fausses informations.

Question de l'utilisateur :
{user_message}

Réponse :
"""


    try:

        response = requests.post(
            OLLAMA_URL,
            json={
                "model": "gemma3:1b",
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": 0.2
                }
            },
            timeout=60
        )


        result = response.json()


        return jsonify({
            "answer": result.get("response", "Pas de réponse")
        })


    except Exception as e:

        return jsonify({
            "error": str(e)
        }), 500