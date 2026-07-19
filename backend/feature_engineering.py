import pandas as pd


# ==========================================
# 1. Chargement dataset
# ==========================================

df = pd.read_csv(
    "routes/sensors.csv"
)


df.columns = df.columns.str.strip()


print("\n===== Dataset chargé =====")
print(df.head())

print("\nNombre lignes initial :", len(df))



# ==========================================
# 2. Conversion timestamp
# ==========================================

df["timestamp"] = pd.to_datetime(
    df["timestamp"],
    errors="coerce"
)



# ==========================================
# Correction timestamp manquant
# ==========================================

# Vérification

print(
    "\nTimestamp invalides :",
    df["timestamp"].isna().sum()
)



# Remplacer les timestamps invalides
# par une suite temporelle régulière

missing_time = df["timestamp"].isna()


if missing_time.sum() > 0:

    start_time = (
        df["timestamp"]
        .dropna()
        .min()
    )


    new_times = pd.date_range(

        start=start_time,

        periods=missing_time.sum(),

        freq="3s"

    )


    df.loc[
        missing_time,
        "timestamp"
    ] = new_times



# Tri temporel

df = df.sort_values(
    "timestamp"
)



print(
    "\nNombre lignes après correction timestamp :",
    len(df)
)



# ==========================================
# 3. Sélection colonnes capteurs
# ==========================================

df = df[
    [
        "timestamp",
        "weight",
        "temperature",
        "humidity",
        "vibration"
    ]
]



# ==========================================
# 4. Correction valeurs négatives
# ==========================================

sensor_columns = [

    "weight",

    "temperature",

    "humidity",

    "vibration"

]


for col in sensor_columns:

    df.loc[
        df[col] < 0,
        col
    ] = 0



# ==========================================
# 5. Feature Engineering
# ==========================================


df = df.set_index(
    "timestamp"
)



# Feature 1:
# moyenne température 1 heure

df["temp_mean_1h"] = (

    df["temperature"]
    .rolling(
        "1h",
        min_periods=1
    )
    .mean()

)



# Feature 2:
# variation température

df["temp_variation"] = (

    df["temperature"]
    .diff()
    .fillna(0)

)



# Feature 3:
# humidité filtrée

df["humidity_combined"] = (

    0.7 *
    df["humidity"]

    +

    0.3 *
    df["humidity"]
    .rolling(
        5,
        min_periods=1
    )
    .mean()

)



# Feature 4:
# stress thermique

df["thermal_stress"] = (

    abs(
        df["temperature"] - 34.5
    )

)



# Feature 5:
# pic vibration

df["vibration_spike"] = (

    df["vibration"]
    .diff()
    .abs()
    .fillna(0)

)



# Feature 6:
# activité abeilles

df["activity_score"] = (

    df["weight"]
    *
    df["vibration"]

)



# ==========================================
# 6. Retour timestamp
# ==========================================

df = df.reset_index()



# ==========================================
# 7. Sauvegarde
# ==========================================

df.to_csv(
    "enhanced_data.csv",
    index=False
)



# ==========================================
# Résultat
# ==========================================

print("\n================================")
print("Feature Engineering terminé")
print("================================")


print(
    "Nombre lignes :",
    len(df)
)


print(
    "\nColonnes finales :"
)

print(
    df.columns.tolist()
)


print(
    "\nAperçu :"
)

print(
    df.head()
)