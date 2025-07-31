<?php
session_start();
require_once 'includes/db.php'; // Connexion PDO

// Vérifie que la requête est bien POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Récupération et nettoyage des données
    $nom = trim($_POST['nom']);
    $prenom = trim($_POST['prenom']);
    $sexe = trim($_POST['sexe']);
    $date_naissance = trim($_POST['date_naissance']);
    $loisirs = trim($_POST['loisirs']);
    $divers = trim($_POST['divers']);
    $antecedents_medicaux = trim($_POST['antecedents_medicaux']);
    $chirurgicaux = trim($_POST['chirurgicaux']);
    $familiaux = trim($_POST['familiaux']);
    $mentions_particulieres = trim($_POST['mentions_particulieres']);
    $telephone = trim($_POST['telephone']);
    $profession = trim($_POST['profession']);
    $poids = trim($_POST['poids']);
    $taille = trim($_POST['taille']);

    // Vérifie que l'utilisateur est bien un médecin connecté
    if (!isset($_SESSION['user']['id'])) {
        header("Location: login.php");
        exit();
    }

    $id_utilisateur = $_SESSION['user']['id']; // le médecin qui ajoute

    try {
        // Insertion dans la base de données
        $stmt = $pdo->prepare("INSERT INTO patients (
            nom, prenom, sexe, date_naissance, loisirs, divers, 
            antecedents_medicaux, chirurgicaux, familiaux, mentions_particulieres, 
            telephone, profession, poids, taille, id_utilisateur
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        $stmt->execute([
            $nom, $prenom, $sexe, $date_naissance, $loisirs, $divers,
            $antecedents_medicaux, $chirurgicaux, $familiaux, $mentions_particulieres,
            $telephone, $profession, $poids, $taille, $id_utilisateur
        ]);

        header("Location: ajouter_patient.php?success=1");
        exit;

    } catch (PDOException $e) {
        header("Location: ajouter_patient.php?error=" . urlencode($e->getMessage()));
        exit;
    }

} else {
    header("Location: ajouter_patient.php");
    exit;
}
