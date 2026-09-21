from flask import Blueprint, request, jsonify
import joblib
import numpy as np
from extensions import mysql



bp_ai = Blueprint(
    "ai",
    __name__,
    url_prefix="/ai"
)



# ================= LOAD MODEL =================


state_model = joblib.load(
    "models/state_model.pkl"
)


ext_model = joblib.load(
    "models/extraction_model.pkl"
)


state_encoder = joblib.load(
    "models/state_encoder.pkl"
)


ext_encoder = joblib.load(
    "models/extraction_encoder.pkl"
)


features = joblib.load(
    "models/features.pkl"
)





# ================= CREATE ALERT =================

# ================= CREATE ALERT WITHOUT DUPLICATE =================

def create_alert(
        user_id,
        alert_type,
        message,
        severity
):

    try:

        if user_id is None:

            print("USER ID MANQUANT")
            return


        cur = mysql.connection.cursor()


        # Vérifier si une alerte identique non lue existe déjà

        cur.execute(
        """
        SELECT id

        FROM alerts

        WHERE user_id=%s

        AND type=%s

        AND status='unread'

        LIMIT 1

        """,
        (
            user_id,
            alert_type
        )
        )


        existing_alert = cur.fetchone()



        # Si elle existe déjà, ne pas créer une nouvelle

        if existing_alert:

            print("ALERT ALREADY EXISTS")

            cur.close()

            return



        # Création de l'alerte

        cur.execute(
        """
        INSERT INTO alerts
        (
            user_id,
            type,
            message,
            severity,
            status
        )

        VALUES
        (%s,%s,%s,%s,'unread')

        """,
        (
            user_id,
            alert_type,
            message,
            severity
        )
        )


        mysql.connection.commit()


        cur.close()


        print("ALERT CREATED")



    except Exception as e:

        print(
            "ALERT ERROR : ",
            e
        )

# ================= FEATURE ENGINEERING =================


def feature_engineering(data):


    weight = float(
        data.get("weight",0)
    )


    temperature = float(
        data.get("temperature",0)
    )


    humidity = float(
        data.get("humidity",0)
    )


    vibration = float(
        data.get("vibration",0)
    )



    temp_mean_1h = temperature



    temp_variation = abs(
        temperature - 34.5
    )



    humidity_combined = (

        0.7 * humidity

        +

        0.3 * humidity

    )



    thermal_stress = abs(
        temperature - 34.5
    )



    vibration_spike = abs(
        vibration
    )



    activity_score = (

        weight * vibration

    )



    return {


        "weight":weight,


        "temperature":temperature,


        "humidity":humidity,


        "vibration":vibration,


        "temp_mean_1h":temp_mean_1h,


        "temp_variation":temp_variation,


        "humidity_combined":humidity_combined,


        "thermal_stress":thermal_stress,


        "vibration_spike":vibration_spike,


        "activity_score":activity_score

    }








# ================= PREDICTION =================


@bp_ai.route(
    "/predict",
    methods=["POST"]
)

def predict():


    try:


        data = request.get_json()



        print("AI INPUT")

        print(data)




        # récupération user connecté

        user_id = data.get("user_id")



        if user_id is None:


            return jsonify({

                "status":False,

                "error":
                "user_id manquant"

            }),400






        engineered = feature_engineering(data)





        X = np.array(

            [

                engineered[f]

                for f in features

            ]

        ).reshape(1,-1)









        # ================= STATE =================


        state_id = (

            state_model
            .predict(X)[0]

        )



        state = (

            state_encoder
            .inverse_transform(

                [state_id]

            )[0]

        )









        # ================= EXTRACTION =================


        ext_id = (

            ext_model
            .predict(X)[0]

        )



        extraction = (

            ext_encoder
            .inverse_transform(

                [ext_id]

            )[0]

        )









        # ================= SAFETY =================


        if state == "stress":


            extraction = "not_favorable"









        # ================= ALERT SYSTEM =================


        temperature = engineered["temperature"]

        humidity = engineered["humidity"]

        vibration = engineered["vibration"]







        # -------- Stress abeilles --------


        if state == "stress":


            create_alert(

                user_id,

                "Stress abeilles",

                "Etat de la ruche critique détecté par IA",

                "HIGH"

            )







        # -------- Température --------


        if temperature > 36:


            create_alert(

                user_id,

                "Température élevée",

                "La température dépasse la limite normale",

                "HIGH"

            )







        # -------- Humidité --------


        if humidity > 70:


            create_alert(

                user_id,

                "Humidité élevée",

                "Humidité trop élevée dans la ruche",

                "MEDIUM"

            )







        # -------- Vibration --------


        if vibration > 20:


            create_alert(

                user_id,

                "Vibration anormale",

                "Activité inhabituelle détectée",

                "HIGH"

            )









        # ================= CONFIDENCE =================


        confidence = round(

            max(

                state_model
                .predict_proba(X)[0]

            )

            *

            100,

            2

        )









        return jsonify({


            "status":True,


            "state":state,


            "extraction":extraction,


            "confidence":confidence,


            "features":engineered


        }),200







    except Exception as e:


        print(
            "AI ERROR : ",
            e
        )



        return jsonify({


            "status":False,


            "error":str(e)


        }),500