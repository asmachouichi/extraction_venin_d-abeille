from flask import Blueprint, request, jsonify
import joblib
import numpy as np


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



# ================= FEATURE ENGINEERING =================
# ================= FEATURE ENGINEERING =================

def feature_engineering(data):


    weight = float(data.get("weight",0))

    temperature = float(data.get("temperature",0))

    humidity = float(data.get("humidity",0))

    vibration = float(data.get("vibration",0))



    # ================= FEATURES TEMPERATURE =================


    temp_mean_1h = temperature


    temp_variation = abs(
        temperature - 34.5
    )



    # ================= HUMIDITY =================


    humidity_combined = (
        0.7 * humidity
        +
        0.3 * humidity
    )



    # ================= STRESS =================


    thermal_stress = abs(
        temperature - 34.5
    )



    # ================= VIBRATION =================


    vibration_spike = abs(
        vibration
    )



    # ================= ACTIVITY =================


    activity_score = (

        weight * vibration

    )



    return {


        "weight":weight,


        "temperature":temperature,


        "humidity":humidity,


        "vibration":vibration,



        "temp_mean_1h":
        temp_mean_1h,



        "temp_variation":
        temp_variation,



        "humidity_combined":
        humidity_combined,



        "thermal_stress":
        thermal_stress,



        "vibration_spike":
        vibration_spike,



        "activity_score":
        activity_score


    }

# ================= PREDICTION =================


@bp_ai.route(
    "/predict",
    methods=["POST"]
)

def predict():


    try:


        data=request.get_json()


        print("AI INPUT")
        print(data)



        engineered=feature_engineering(data)



        X=np.array(

            [
                engineered[f]
                for f in features
            ]

        ).reshape(1,-1)



        # ========= STATE =========


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



        # ========= EXTRACTION =========


        ext_id=(

            ext_model
            .predict(X)[0]

        )


        extraction=(

            ext_encoder
            .inverse_transform(
                [ext_id]
            )[0]

        )



        # ========= SAFETY RULE =========


        if state=="stress":

            extraction="not_favorable"



        # ========= CONFIDENCE =========


        confidence=round(

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


        })



    except Exception as e:


        print(
            "AI ERROR",
            e
        )


        return jsonify({

            "status":False,

            "error":str(e)

        }),500