import pandas as pd
import joblib
import os

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.linear_model import LogisticRegression

from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.pipeline import Pipeline

from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    classification_report,
    confusion_matrix
)


# ============================================================
# 1. CREATION DU DOSSIER DES MODELES
# ============================================================

os.makedirs(
    "models",
    exist_ok=True
)


# ============================================================
# 2. CHARGEMENT DU DATASET
# ============================================================

df = pd.read_csv(
    "enhanced_data.csv"
)

print("\n================ DATASET ================")
print(df.head())
print("\nDimensions initiales :", df.shape)


# ============================================================
# 3. SUPPRESSION DES VALEURS MANQUANTES
# ============================================================

df = df.dropna()

print("\nDimensions après suppression des valeurs manquantes :")
print(df.shape)


# ============================================================
# 4. PARAMETRES BIOLOGIQUES
# ============================================================

TEMP_MIN = 33
TEMP_MAX = 36

HUM_MIN = 40
HUM_MAX = 70


# ============================================================
# 5. CALCUL DES SEUILS
# ============================================================

vibration_threshold = (
    df["vibration_spike"].quantile(0.75)
)

activity_threshold = (
    df["activity_score"].quantile(0.40)
)

print("\n================ SEUILS ================")

print(
    "Seuil vibration :",
    vibration_threshold
)

print(
    "Seuil activité :",
    activity_threshold
)


# ============================================================
# 6. FEATURES UTILISEES PAR LES MODELES
# ============================================================

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


print("\n================ FEATURES ================")

print(
    "Nombre de caractéristiques :",
    len(features)
)

print(
    features
)


# ============================================================
# 7. CREATION DE LA VARIABLE CIBLE STATE
# ============================================================

def state_label(row):

    score = 0

    # Température acceptable

    if TEMP_MIN <= row["temperature"] <= TEMP_MAX:
        score += 1

    # Humidité acceptable

    if HUM_MIN <= row["humidity"] <= HUM_MAX:
        score += 1

    # Faible stress thermique

    if row["thermal_stress"] < 3:
        score += 1

    # Faibles vibrations

    if row["vibration_spike"] < vibration_threshold:
        score += 1

    # Classification

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


print("\n================ DISTRIBUTION STATE ================")

print(
    df["state"].value_counts()
)


# ============================================================
# 8. CREATION DE LA VARIABLE CIBLE EXTRACTION
# ============================================================

def extraction_label(row):

    score = 0

    # Température favorable

    if 33 <= row["temperature"] <= 36:
        score += 1

    # Humidité acceptable

    if 40 <= row["humidity"] <= 70:
        score += 1

    # Faible stress thermique

    if row["thermal_stress"] < 3:
        score += 1

    # Faible vibration

    if row["vibration_spike"] < vibration_threshold:
        score += 1

    # Activité suffisante

    if row["activity_score"] > activity_threshold:
        score += 1

    # Classification

    if score >= 3:

        return "favorable"

    else:

        return "not_favorable"


df["extraction"] = df.apply(
    extraction_label,
    axis=1
)


print("\n================ DISTRIBUTION EXTRACTION ================")

print(
    df["extraction"].value_counts()
)


# ============================================================
# 9. MODELES A COMPARER
# ============================================================

def create_models():

    models = {

        "Random Forest":
            RandomForestClassifier(
                n_estimators=300,
                max_depth=10,
                class_weight="balanced",
                random_state=42
            ),

        "Decision Tree":
            DecisionTreeClassifier(
                max_depth=10,
                class_weight="balanced",
                random_state=42
            ),

        "KNN":
            Pipeline([
                (
                    "scaler",
                    StandardScaler()
                ),
                (
                    "knn",
                    KNeighborsClassifier(
                        n_neighbors=5
                    )
                )
            ]),

        "Logistic Regression":
            Pipeline([
                (
                    "scaler",
                    StandardScaler()
                ),
                (
                    "logistic",
                    LogisticRegression(
                        max_iter=1000,
                        class_weight="balanced",
                        random_state=42
                    )
                )
            ])
    }

    return models


# ============================================================
# 10. FONCTION DE COMPARAISON DES MODELES
# ============================================================

def compare_models(
    X,
    y,
    encoder,
    problem_name
):

    # Séparation des données

    X_train, X_test, y_train, y_test = train_test_split(

        X,

        y,

        test_size=0.2,

        random_state=42,

        stratify=y
    )


    models = create_models()

    results = []

    trained_models = {}


    print("\n")
    print("================================================")
    print("COMPARAISON :", problem_name)
    print("================================================")


    # Boucle sur les modèles

    for name, model in models.items():

        print("\n--------------------------------")
        print(name)
        print("--------------------------------")


        # Entraînement

        model.fit(
            X_train,
            y_train
        )


        # Prédiction

        predictions = model.predict(
            X_test
        )


        # Métriques

        accuracy = accuracy_score(
            y_test,
            predictions
        )


        precision = precision_score(
            y_test,
            predictions,
            average="weighted",
            zero_division=0
        )


        recall = recall_score(
            y_test,
            predictions,
            average="weighted",
            zero_division=0
        )


        f1 = f1_score(
            y_test,
            predictions,
            average="weighted",
            zero_division=0
        )


        # Affichage

        print(
            "Accuracy  :",
            round(accuracy, 4)
        )

        print(
            "Precision :",
            round(precision, 4)
        )

        print(
            "Recall    :",
            round(recall, 4)
        )

        print(
            "F1-score  :",
            round(f1, 4)
        )


        # Rapport détaillé

        print("\nClassification Report :")

        print(
            classification_report(
                y_test,
                predictions,
                target_names=encoder.classes_,
                zero_division=0
            )
        )


        # Matrice de confusion

        print("Confusion Matrix :")

        print(
            confusion_matrix(
                y_test,
                predictions
            )
        )


        # Sauvegarde des résultats

        results.append({

            "Model": name,

            "Accuracy": accuracy,

            "Precision": precision,

            "Recall": recall,

            "F1-score": f1
        })


        trained_models[name] = model


    # ========================================================
    # TABLEAU COMPARATIF
    # ========================================================

    results_df = pd.DataFrame(
        results
    )


    print("\n")
    print("================================================")
    print("TABLEAU COMPARATIF :", problem_name)
    print("================================================")

    print(
        results_df.to_string(
            index=False
        )
    )


    # ========================================================
    # SELECTION DU MODELE
    # ========================================================

    best_index = results_df[
        "F1-score"
    ].idxmax()


    best_model_name = results_df.loc[
        best_index,
        "Model"
    ]


    print("\n================================================")

    print(
        "MODELE RETENU :",
        best_model_name
    )

    print(
        "F1-score :",
        round(
            results_df.loc[
                best_index,
                "F1-score"
            ],
            4
        )
    )

    print("================================================")


    # Récupération du modèle retenu

    best_model = trained_models[
        best_model_name
    ]


    return (
        best_model,
        best_model_name,
        results_df
    )


# ============================================================
# 11. MODELE STATE
# ============================================================

state_encoder = LabelEncoder()

y_state = state_encoder.fit_transform(
    df["state"]
)


(
    state_model,
    state_model_name,
    state_results
) = compare_models(

    X,

    y_state,

    state_encoder,

    "STATE"
)


# ============================================================
# 12. MODELE EXTRACTION
# ============================================================

ext_encoder = LabelEncoder()

y_ext = ext_encoder.fit_transform(
    df["extraction"]
)


(
    ext_model,
    ext_model_name,
    ext_results
) = compare_models(

    X,

    y_ext,

    ext_encoder,

    "EXTRACTION"
)


# ============================================================
# 13. REENTRAINEMENT DES MODELES RETENUS
# ============================================================

print("\n")
print("================================================")
print("REENTRAINEMENT DES MODELES RETENUS")
print("================================================")


state_model.fit(
    X,
    y_state
)


ext_model.fit(
    X,
    y_ext
)


# ============================================================
# 14. SAUVEGARDE DES MODELES
# ============================================================

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

        "vibration_threshold":
            vibration_threshold,

        "activity_threshold":
            activity_threshold

    },

    "models/thresholds.pkl"

)


# ============================================================
# 15. SAUVEGARDE DES RESULTATS DE COMPARAISON
# ============================================================

state_results.to_csv(
    "models/state_comparison.csv",
    index=False
)


ext_results.to_csv(
    "models/extraction_comparison.csv",
    index=False
)


# ============================================================
# 16. AFFICHAGE FINAL
# ============================================================

print("\n")
print("================================================")
print("RESULTATS FINAUX")
print("================================================")


print(
    "\nModèle STATE retenu :",
    state_model_name
)


print(
    "Modèle EXTRACTION retenu :",
    ext_model_name
)


print("\n")


print(
    "Fichier modèle STATE :",
    "models/state_model.pkl"
)


print(
    "Fichier modèle EXTRACTION :",
    "models/extraction_model.pkl"
)


print("\n================================")
print("MODELS SAVED SUCCESSFULLY")
print("================================")