
import matplotlib.pyplot as plt
import numpy as np


# ============================================================
# 1. Classification de l'état du système
# ============================================================

# ==========================================
# Les métriques sur l'axe X
# ==========================================

metriques = [
    "Accuracy",
    "Precision",
    "Recall",
    "F1-score"
]

# ==========================================
# Résultats des quatre modèles
# ==========================================

random_forest = [
    95.80,   # Accuracy
    95.81,   # Precision
    95.80,   # Recall
    95.78    # F1-score
]

decision_tree = [
    93.70,
    94.06,
    93.70,
    93.63
]

knn = [
    93.44,
    93.44,
    93.44,
    93.42
]

logistic_regression = [
    88.71,
    88.71,
    88.71,
    88.65
]

# ==========================================
# Position des métriques
# ==========================================

x = np.arange(len(metriques))

# Largeur des barres
largeur = 0.18

# ==========================================
# Création du graphique
# ==========================================

plt.figure(figsize=(12, 7))

# Random Forest
bar1 = plt.bar(
    x - 1.5 * largeur,
    random_forest,
    largeur,
    color="blue",
    label="Random Forest"
)

# Decision Tree
bar2 = plt.bar(
    x - 0.5 * largeur,
    decision_tree,
    largeur,
    color="green",
    label="Decision Tree"
)

# KNN
bar3 = plt.bar(
    x + 0.5 * largeur,
    knn,
    largeur,
    color="orange",
    label="KNN"
)

# Logistic Regression
bar4 = plt.bar(
    x + 1.5 * largeur,
    logistic_regression,
    largeur,
    color="yellow",
    edgecolor="black",
    label="Logistic Regression"
)

# ==========================================
# Affichage des valeurs
# ==========================================

for barres in [bar1, bar2, bar3, bar4]:

    for barre in barres:

        valeur = barre.get_height()

        plt.text(
            barre.get_x() + barre.get_width() / 2,
            valeur + 0.15,
            f"{valeur:.2f}%",
            ha="center",
            va="bottom",
            fontsize=8
        )

# ==========================================
# Titre et axes
# ==========================================

plt.title(
    "Comparaison des performances des modèles "
    "pour la classification de l'état du système",
    fontsize=15
)

plt.xlabel(
    "Métriques",
    fontsize=12
)

plt.ylabel(
    "Performance (%)",
    fontsize=12
)

plt.xticks(
    x,
    metriques,
    fontsize=11
)

# ==========================================
# Limites de l'axe Y
# ==========================================

plt.ylim(80, 100)

# ==========================================
# Légende
# ==========================================

plt.legend(
    fontsize=10
)

# ==========================================
# Grille horizontale
# ==========================================

plt.grid(
    axis="y",
    linestyle="--",
    alpha=0.3
)

# ==========================================
# Ajustement
# ==========================================

plt.tight_layout()

# ==========================================
# Sauvegarde
# ==========================================

plt.savefig(
    "comparaison_modeles_etat.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()


# ============================================================
# 2. Classification des conditions d'extraction
# ============================================================

# ==========================================
# Résultats des quatre modèles
# ==========================================

random_forest = [
    94.49,   # Accuracy
    94.50,   # Precision
    94.49,   # Recall
    94.48    # F1-score
]

decision_tree = [
    93.44,
    93.57,
    93.44,
    93.45
]

knn = [
    91.86,
    91.87,
    91.86,
    91.85
]

logistic_regression = [
    89.24,
    89.27,
    89.24,
    89.25
]

# ==========================================
# Position des métriques
# ==========================================

x = np.arange(len(metriques))

# ==========================================
# Création du graphique
# ==========================================

plt.figure(figsize=(12, 7))

# Random Forest
bar1 = plt.bar(
    x - 1.5 * largeur,
    random_forest,
    largeur,
    color="blue",
    label="Random Forest"
)

# Decision Tree
bar2 = plt.bar(
    x - 0.5 * largeur,
    decision_tree,
    largeur,
    color="green",
    label="Decision Tree"
)

# KNN
bar3 = plt.bar(
    x + 0.5 * largeur,
    knn,
    largeur,
    color="orange",
    label="KNN"
)

# Logistic Regression
bar4 = plt.bar(
    x + 1.5 * largeur,
    logistic_regression,
    largeur,
    color="yellow",
    edgecolor="black",
    label="Logistic Regression"
)

# ==========================================
# Affichage des valeurs
# ==========================================

for barres in [bar1, bar2, bar3, bar4]:

    for barre in barres:

        valeur = barre.get_height()

        plt.text(
            barre.get_x() + barre.get_width() / 2,
            valeur + 0.15,
            f"{valeur:.2f}%",
            ha="center",
            va="bottom",
            fontsize=8
        )

# ==========================================
# Titre et axes
# ==========================================

plt.title(
    "Comparaison des performances des modèles "
    "pour la classification des conditions d'extraction",
    fontsize=15
)

plt.xlabel(
    "Métriques",
    fontsize=12
)

plt.ylabel(
    "Performance (%)",
    fontsize=12
)

plt.xticks(
    x,
    metriques,
    fontsize=11
)

# ==========================================
# Limites de l'axe Y
# ==========================================

plt.ylim(80, 100)

# ==========================================
# Légende
# ==========================================

plt.legend(
    fontsize=10
)

# ==========================================
# Grille horizontale
# ==========================================

plt.grid(
    axis="y",
    linestyle="--",
    alpha=0.3
)

# ==========================================
# Ajustement
# ==========================================

plt.tight_layout()

# ==========================================
# Sauvegarde
# ==========================================

plt.savefig(
    "comparaison_modeles_extraction.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()
