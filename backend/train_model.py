import pandas as pd
import joblib
import os


from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix
)



# =====================================
# Création dossier modèles
# =====================================

os.makedirs(
    "models",
    exist_ok=True
)



# =====================================
# Chargement dataset
# =====================================

df = pd.read_csv(
    "enhanced_data.csv"
)


print("\n===== Dataset =====")
print(df.head())

print(df.shape)



# Suppression valeurs manquantes

df = df.dropna()



# =====================================
# Paramètres biologiques
# =====================================


TEMP_MIN = 33
TEMP_MAX = 36


HUM_MIN = 40
HUM_MAX = 70



# seuils calculés automatiquement

vibration_threshold = (
    df["vibration_spike"]
    .quantile(0.75)
)


activity_threshold = (
    df["activity_score"]
    .quantile(0.40)
)



# =====================================
# Features utilisées
# =====================================


features = [

    "weight",

    "temperature",

    "humidity",

    "vibration",

    "temp_mean_1h",

    "temp_variation",

    "humidity_combined",

    "thermal_stress",

    "vibration_spike",

    "activity_score"

]


X = df[features]



# =====================================
# Label état ruche
# =====================================


def state_label(row):

    score = 0


    if TEMP_MIN <= row["temperature"] <= TEMP_MAX:
        score += 1


    if HUM_MIN <= row["humidity"] <= HUM_MAX:
        score += 1


    if row["thermal_stress"] < 3:
        score += 1


    if row["vibration_spike"] < vibration_threshold:
        score += 1



    if score >= 3:

        return "optimal"


    elif score == 2:

        return "normal"


    else:

        return "stress"



df["state"] = df.apply(
    state_label,
    axis=1
)



print("\n===== Distribution état =====")

print(
    df["state"].value_counts()
)



# =====================================
# Label extraction corrigé
# =====================================


def extraction_label(row):

    score = 0


    # température favorable

    if 33 <= row["temperature"] <= 36:

        score += 1



    # humidité acceptable

    if 40 <= row["humidity"] <= 70:

        score += 1



    # faible stress thermique

    if row["thermal_stress"] < 3:

        score += 1



    # faible vibration

    if row["vibration_spike"] < vibration_threshold:

        score += 1



    # activité abeilles

    if row["activity_score"] > activity_threshold:

        score += 1



    # au moins 3 conditions satisfaites

    if score >= 3:

        return "favorable"


    else:

        return "not_favorable"



df["extraction"] = df.apply(
    extraction_label,
    axis=1
)



print("\n===== Distribution extraction =====")

print(
    df["extraction"].value_counts()
)



# =====================================
# Entraînement modèle STATE
# =====================================


state_encoder = LabelEncoder()


y_state = state_encoder.fit_transform(
    df["state"]
)



X_train, X_test, y_train, y_test = train_test_split(

    X,

    y_state,

    test_size=0.2,

    random_state=42,

    stratify=y_state

)



state_model = RandomForestClassifier(

    n_estimators=300,

    max_depth=10,

    class_weight="balanced",

    random_state=42

)



state_model.fit(

    X_train,

    y_train

)



state_pred = state_model.predict(
    X_test
)



print("\n================ STATE MODEL ================")


print(
    "Accuracy :",
    accuracy_score(
        y_test,
        state_pred
    )
)


print(
    classification_report(
        y_test,
        state_pred,
        target_names=state_encoder.classes_
    )
)



print(
    "Confusion Matrix:"
)

print(
    confusion_matrix(
        y_test,
        state_pred
    )
)




# =====================================
# Entraînement modèle EXTRACTION
# =====================================


ext_encoder = LabelEncoder()


y_ext = ext_encoder.fit_transform(
    df["extraction"]
)



X_train, X_test, y_train, y_test = train_test_split(

    X,

    y_ext,

    test_size=0.2,

    random_state=42,

    stratify=y_ext

)



ext_model = RandomForestClassifier(

    n_estimators=300,

    max_depth=10,

    class_weight="balanced",

    random_state=42

)



ext_model.fit(

    X_train,

    y_train

)



ext_pred = ext_model.predict(
    X_test
)



print("\n================ EXTRACTION MODEL ================")


print(
    "Accuracy :",
    accuracy_score(
        y_test,
        ext_pred
    )
)


print(
    classification_report(
        y_test,
        ext_pred,
        target_names=ext_encoder.classes_
    )
)



print(
    "Confusion Matrix:"
)

print(
    confusion_matrix(
        y_test,
        ext_pred
    )
)




# =====================================
# Sauvegarde modèles
# =====================================


joblib.dump(
    state_model,
    "models/state_model.pkl"
)


joblib.dump(
    ext_model,
    "models/extraction_model.pkl"
)



joblib.dump(
    state_encoder,
    "models/state_encoder.pkl"
)



joblib.dump(
    ext_encoder,
    "models/extraction_encoder.pkl"
)



joblib.dump(
    features,
    "models/features.pkl"
)



joblib.dump(

    {
        "TEMP_MIN": TEMP_MIN,
        "TEMP_MAX": TEMP_MAX,
        "HUM_MIN": HUM_MIN,
        "HUM_MAX": HUM_MAX,
        "vibration_threshold": vibration_threshold,
        "activity_threshold": activity_threshold
    },

    "models/thresholds.pkl"

)



print("\n================================")
print("MODELS SAVED SUCCESSFULLY")
print("================================")