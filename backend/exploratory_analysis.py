import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


# ==============================
# 1. Chargement dataset
# ==============================

df = pd.read_csv("routes/sensors.csv")


# ==============================
# 2. Aperçu des données
# ==============================

print("\n===== Aperçu des données =====")
print(df.head())



# ==============================
# 3. Informations générales
# ==============================

print("\n===== Informations dataset =====")
print(df.info())



# ==============================
# 4. Statistiques descriptives
# ==============================

print("\n===== Statistiques =====")
print(df.describe())



# ==============================
# 5. Conversion timestamp
# ==============================

df["timestamp"] = pd.to_datetime(
    df["timestamp"],
    errors="coerce"
)


print("\n===== Type après conversion =====")
print(df.dtypes)



# ==============================
# 6. Valeurs manquantes
# ==============================

print("\n===== Valeurs manquantes =====")
print(df.isnull().sum())



# ==============================
# 7. Doublons
# ==============================

print("\n===== Doublons =====")
print(df.duplicated().sum())



# ==============================
# 8. Valeurs impossibles
# ==============================

print("\n===== Valeurs impossibles =====")


print(
    "Poids négatif :",
    len(df[df["weight"] < 0])
)


print(
    "Température nulle :",
    len(df[df["temperature"] <= 0])
)


print(
    "Humidité nulle :",
    len(df[df["humidity"] <= 0])
)



# ==============================
# 9. Variables étudiées
# ==============================

variables = [
    "weight",
    "temperature",
    "humidity",
    "vibration"
]



# ==============================
# 10. Détection valeurs aberrantes IQR
# ==============================

print("\n===== Valeurs aberrantes =====")


for col in variables:


    Q1 = df[col].quantile(0.25)

    Q3 = df[col].quantile(0.75)

    IQR = Q3 - Q1


    lower = Q1 - 1.5 * IQR

    upper = Q3 + 1.5 * IQR


    outliers = df[
        (df[col] < lower) |
        (df[col] > upper)
    ]


    print(
        col,
        ":",
        len(outliers),
        "valeurs aberrantes"
    )



# ==============================
# 11. Boxplot valeurs aberrantes
# ==============================


for col in variables:


    plt.figure(figsize=(6,4))


    sns.boxplot(
        y=df[col]
    )


    plt.title(
        "Boxplot - Détection des valeurs aberrantes : "
        + col
    )


    plt.ylabel(col)


    plt.grid(True)


    plt.show()



# ==============================
# 12. Distribution des variables
# ==============================


for col in variables:


    plt.figure(figsize=(6,4))


    sns.histplot(
        df[col],
        kde=True
    )


    plt.title(
        "Distribution de " + col
    )


    plt.xlabel(col)

    plt.ylabel(
        "Fréquence"
    )


    plt.show()



# ==============================
# 13. Corrélation entre capteurs
# ==============================


plt.figure(figsize=(8,6))


sns.heatmap(
    df[variables].corr(),
    annot=True,
    cmap="coolwarm"
)


plt.title(
    "Matrice de corrélation des capteurs"
)


plt.show()



# ==============================
# 14. Evolution temporelle
# ==============================


for col in variables:


    plt.figure(figsize=(10,4))


    plt.plot(
        df["timestamp"],
        df[col]
    )


    plt.title(
        "Evolution temporelle de " + col
    )


    plt.xlabel(
        "Temps"
    )


    plt.ylabel(
        col
    )


    plt.xticks(
        rotation=45
    )


    plt.show()