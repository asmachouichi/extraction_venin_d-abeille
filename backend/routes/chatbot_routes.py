from flask import Blueprint, request, jsonify
import requests


chatbot_bp = Blueprint(
    "chatbot",
    __name__
)


# API Ollama
OLLAMA_URL = "http://127.0.0.1:11434/api/generate"



@chatbot_bp.route("/chat", methods=["POST"])
def chat():

    data = request.get_json()


    if not data:
        return jsonify({
            "error": "Aucune donnée reçue"
        }), 400



    user_message = data.get("message", "").strip()



    if not user_message:
        return jsonify({
            "error": "Message vide"
        }), 400




    prompt = f"""

Tu es BeeGuardian AI, un assistant intelligent spécialisé dans
l'apiculture intelligente et l'extraction du venin d'abeille.


Contexte du système :

Le système utilise :

- Une carte ESP32 pour la collecte des données.
- Des capteurs IoT :
  * température
  * humidité
  * vibrations
  * poids du venin

Les données sont envoyées vers un serveur Flask.

Un modèle Machine Learning Random Forest analyse les données
et prédit l'état de la ruche :

- Optimal
- Normal
- Stress


L'application Flutter permet :

- suivi en temps réel
- historique des données
- prédiction IA
- contrôle du système d'extraction



Ton rôle :

Tu dois aider l'apiculteur à comprendre l'état de sa ruche.


Règles obligatoires :

- Réponds uniquement en français.
- Ne traduis jamais la question.
- Ne dis jamais "vous avez écrit".
- Ne répète pas la question utilisateur.
- Réponds directement au problème.
- Explique simplement les termes techniques.
- Donne des conseils pratiques.
- Ne crée jamais de valeurs de capteurs inexistantes.
- Si une information manque, indique :
  "Je ne dispose pas de cette information."



Structure de réponse obligatoire :


Analyse :
Explique la situation.


Causes possibles :
Liste les causes probables.


Actions recommandées :
Donne les actions à réaliser.



Question utilisateur :

{user_message}



Réponse :
"""



    try:


        response = requests.post(

            OLLAMA_URL,

            json={

                "model": "mistral:7b",

                "prompt": prompt,

                "stream": False,

                "options": {

                    "temperature": 0.2,

                    "top_p": 0.9,

                    "num_predict": 300

                }

            },

            timeout=300

        )



        print("==============================")
        print("QUESTION :", user_message)
        print("STATUS :", response.status_code)
        print("OLLAMA :", response.text)
        print("==============================")



        if response.status_code != 200:

            return jsonify({

                "error": "Erreur Ollama",

                "details": response.text

            }), 500




        result = response.json()



        answer = result.get(
            "response",
            ""
        )



        if answer == "":

            return jsonify({

                "error":
                "Ollama n'a pas généré de réponse"

            }),500




        return jsonify({

            "answer": answer

        })




    except requests.exceptions.Timeout:


        return jsonify({

            "error":
            "Temps de réponse dépassé"

        }),500




    except requests.exceptions.ConnectionError:


        return jsonify({

            "error":
            "Ollama n'est pas démarré. Lancez ollama serve"

        }),500




    except Exception as e:


        print("ERREUR :", e)


        return jsonify({

            "error": str(e)

        }),500