// Projet réalisé par KABORE Jean Bosco,
// élève-ingénieur en génie des télécommunications 2

import 'package:flutter/material.dart';

// POINT D’ENTRÉE
void main() {
  runApp(const ApplicationCalculatrice());
}

// APPLICATION
class ApplicationCalculatrice extends StatelessWidget {
  const ApplicationCalculatrice({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PageCalculatrice(),
    );
  }
}

// PAGE CALCULATRICE
class PageCalculatrice extends StatefulWidget {
  const PageCalculatrice({super.key});

  @override
  State<PageCalculatrice> createState() => _EtatCalculatrice();
}

class _EtatCalculatrice extends State<PageCalculatrice> {
  String affichage = "0";
  String expressionAffichee = "";
  bool erreur = false;
  bool estPourcentage = false;

  double? resultatCourant;
  String? dernierOperateur;
  bool nouveauNombre = true;
  bool vientDEvaluer = false;

  // FORMATAGE DES NOMBRES SAISIS
  String formaterNombreSaisi(String valeur) {
    double n = double.parse(valeur);
    return (n == n.roundToDouble())
        ? n.toStringAsFixed(1)
        : n.toString();
  }

  // FORMATAGE DU RÉSULTAT
  String formaterResultat(double valeur) {
    return (valeur == valeur.roundToDouble())
        ? valeur.toInt().toString()
        : valeur.toString();
  }

  // CALCUL AVEC GESTION D’ERREUR
  double? calculer(double a, double b, String operateur) {
    switch (operateur) {
      case "+":
        return a + b;
      case "-":
        return a - b;
      case "×":
        return a * b;
      case "÷":
        if (b == 0) {
          erreur = true;
          affichage = "Erreur";
          expressionAffichee = "";
          return null;
        }
        return a / b;
      default:
        return b;
    }
  }

  // GESTION DES BOUTONS
  void appuyerBouton(String valeur) {
    setState(() {
      if (erreur && valeur != "C") return;

      if (valeur == "C") {
        affichage = "0";
        expressionAffichee = "";
        resultatCourant = null;
        dernierOperateur = null;
        nouveauNombre = true;
        vientDEvaluer = false;
        erreur = false;
        estPourcentage = false;
        return;
      }

      if (vientDEvaluer && RegExp(r'[0-9]').hasMatch(valeur)) {
        affichage = "0";
        expressionAffichee = "";
        resultatCourant = null;
        dernierOperateur = null;
        nouveauNombre = true;
        vientDEvaluer = false;
      }

      // CHIFFRES
      if (RegExp(r'[0-9]').hasMatch(valeur)) {
        affichage = nouveauNombre ? valeur : affichage + valeur;
        nouveauNombre = false;
      }

      // POINT DÉCIMAL
      else if (valeur == ".") {
        if (!affichage.contains(".")) {
          affichage += ".";
          nouveauNombre = false;
        }
      }

      // OPÉRATEURS
      else if (["+", "-", "×", "÷"].contains(valeur)) {
        double valeurNumerique =
        double.parse(affichage.replaceAll("%", ""));
        if (estPourcentage) valeurNumerique /= 100;
        estPourcentage = false;

        if (resultatCourant == null) {
          resultatCourant = valeurNumerique;
        } else if (dernierOperateur != null) {
          final res = calculer(
              resultatCourant!, valeurNumerique, dernierOperateur!);
          if (res == null) return;
          resultatCourant = res;
        }

        dernierOperateur = valeur;
        expressionAffichee =
        "${formaterNombreSaisi(resultatCourant.toString())} $valeur";
        affichage = formaterNombreSaisi(resultatCourant.toString());
        nouveauNombre = true;
        vientDEvaluer = false;
      }

      // ÉGAL
      else if (valeur == "=") {
        if (dernierOperateur == null && estPourcentage) {
          double res =
              double.parse(affichage.replaceAll("%", "")) / 100;
          affichage = formaterResultat(res);
          estPourcentage = false;
          vientDEvaluer = true;
          nouveauNombre = true;
          return;
        }

        if (dernierOperateur != null) {
          double valeurNumerique =
          double.parse(affichage.replaceAll("%", ""));
          if (estPourcentage) valeurNumerique /= 100;
          estPourcentage = false;

          final res = calculer(
              resultatCourant!, valeurNumerique, dernierOperateur!);
          if (res == null) return;

          expressionAffichee =
          "${formaterNombreSaisi(resultatCourant.toString())} "
              "$dernierOperateur "
              "${formaterNombreSaisi(valeurNumerique.toString())} =";
          affichage = formaterResultat(res);

          resultatCourant = res;
          dernierOperateur = null;
          nouveauNombre = true;
          vientDEvaluer = true;
        }
      }

      // POURCENTAGE
      else if (valeur == "%") {
        if (!affichage.endsWith("%")) {
          affichage += "%";
          estPourcentage = true;
          nouveauNombre = true;
        }
      }

      // SIGNE
      else if (valeur == "+/-" && affichage != "0") {
        affichage = affichage.startsWith("-")
            ? affichage.substring(1)
            : "-$affichage";
      }
    });
  }

  static const double tailleBouton = 70;
  static const double espacement = 12;

  Widget boutonCirculaire(String texte,
      {Color couleur = const Color(0xFF333333)}) {
    return GestureDetector(
      onTap: () => appuyerBouton(texte),
      child: Container(
        width: tailleBouton,
        height: tailleBouton,
        margin: const EdgeInsets.only(bottom: espacement),
        decoration:
        BoxDecoration(shape: BoxShape.circle, color: couleur),
        child: Center(
          child: Text(
            texte,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget boutonEgal() {
    return GestureDetector(
      onTap: () => appuyerBouton("="),
      child: Container(
        width: tailleBouton,
        height: tailleBouton * 2 + espacement,
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(tailleBouton / 2),
        ),
        child: const Center(
          child: Text("=",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(expressionAffichee,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 18)),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        affichage,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 60),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(children: [
                    boutonCirculaire("C"),
                    boutonCirculaire("7"),
                    boutonCirculaire("4"),
                    boutonCirculaire("1"),
                    boutonCirculaire("+/-"),
                  ]),
                  const SizedBox(width: espacement),
                  Column(children: [
                    boutonCirculaire("%"),
                    boutonCirculaire("8"),
                    boutonCirculaire("5"),
                    boutonCirculaire("2"),
                    boutonCirculaire("0"),
                  ]),
                  const SizedBox(width: espacement),
                  Column(children: [
                    boutonCirculaire("÷", couleur: Colors.orange),
                    boutonCirculaire("9"),
                    boutonCirculaire("6"),
                    boutonCirculaire("3"),
                    boutonCirculaire("."),
                  ]),
                  const SizedBox(width: espacement),
                  Column(children: [
                    boutonCirculaire("×", couleur: Colors.orange),
                    boutonCirculaire("-", couleur: Colors.orange),
                    boutonCirculaire("+", couleur: Colors.orange),
                    boutonEgal(),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*
  Application de calculatrice développée avec Flutter.

  1) FONCTIONNEMENT GÉNÉRAL DE L’APPLICATION

  Cette application permet d’effectuer des calculs arithmétiques de base
  (+, -, ×, ÷) à l’aide d’une interface graphique composée de boutons
  circulaires, similaire à une calculatrice classique.

  - L’utilisateur saisit les nombres via les boutons numériques.
  - Lorsqu’un opérateur est sélectionné, le calcul intermédiaire est
    automatiquement effectué si une opération précédente existe.
  - Il est possible d’enchaîner plusieurs opérations sans appuyer sur "=".
  - Le bouton "=" permet d’afficher le résultat final du calcul.
  - Après l’évaluation finale, la saisie d’un nouveau nombre démarre
    automatiquement un nouveau calcul.
  - Les erreurs (ex : division par zéro) sont détectées et bloquent
    toute action sauf la remise à zéro avec le bouton "C".
  - L’état de l’application est géré dynamiquement à l’aide d’un
    StatefulWidget et mis à jour avec setState().

  2) RÔLE DES PRINCIPALES FONCTIONS ET VARIABLES

  - main() : Point d’entrée de l’application. Lance l’exécution Flutter
    avec runApp().

  - CalculatorApp : Widget principal de type StatelessWidget qui initialise
    l’application via MaterialApp.

  - CalculatorPage : Page principale contenant l’interface graphique et la logique
    complète de la calculatrice.

  - press(String v) : Fonction centrale de l’application. Elle gère toutes les actions
    liées aux boutons (chiffres, opérateurs, égal, pourcentage, signe,
    remise à zéro). Elle met à jour l’affichage et l’état interne
    selon la valeur du bouton pressé.

  - calculate(double a, double b, String op) : Effectue les opérations arithmétiques de base entre deux nombres.
    Cette fonction gère également les erreurs, notamment la division
    par zéro.

  - formatInputNumber(String value) : Formate les nombres saisis par l’utilisateur afin d’améliorer
    l’affichage (ex : 2 → 2.0).

  - formatResultNumber(double value) : Formate le résultat final pour éviter l’affichage inutile
    des décimales (ex : 5.0 → 5).

  - build(BuildContext context) : Construit l’interface graphique de l’application, incluant
    l’écran d’affichage et l’ensemble des boutons.

  3) CHOIX D’IMPLÉMENTATION DU BOUTON %

  Le symbole % peut représenter soit un opérateur modulo, soit un
  pourcentage. Dans cette application, le bouton % a été implémenté
  comme un pourcentage.
  Concrètement, lorsqu’il est pressé, la valeur affichée est divisée
  par 100. Ce choix correspond au comportement des calculatrices
  classiques et permet une utilisation plus intuitive pour les
  calculs quotidiens.
*/