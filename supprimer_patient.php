<?php
session_start();
require_once 'db.php';

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

if (!isset($_GET['id']) || !is_numeric($_GET['id'])) {
    header("Location: lister_patients.php?error=id_invalide");
    exit();
}

$id_patient = intval($_GET['id']);
$id_utilisateur = $_SESSION['user']['id'];

//  On récupère le patient, peu importe qui l'a créé
$stmt = $pdo->prepare("SELECT * FROM patients WHERE id_patient = ?");
$stmt->execute([$id_patient]);
$patient = $stmt->fetch();

if (!$patient) {
    header("Location: lister_patients.php?error=patient_introuvable");
    exit();
}

//  Vérifie l'autorisation : créateur ou médecin "principale"
$isCreator = $patient['id_utilisateur'] == $id_utilisateur;
$isPrincipale = $_SESSION['user']['statut'] === 'principal';

if (!$isCreator && !$isPrincipale) {
    header("Location: lister_patients.php?error=accès_refusé");
    exit();
}

//  Supprimer les données liées d'abord
$pdo->prepare("DELETE FROM bons_examens WHERE id_patient = ?")->execute([$id_patient]);
$pdo->prepare("DELETE FROM observations WHERE id_patient = ?")->execute([$id_patient]);
$pdo->prepare("DELETE FROM ordonnances WHERE id_patient = ?")->execute([$id_patient]);
$pdo->prepare("DELETE FROM consultations WHERE id_patient = ?")->execute([$id_patient]);

//  Supprimer le patient
$pdo->prepare("DELETE FROM patients WHERE id_patient = ?")->execute([$id_patient]);

header("Location: lister_patients.php?success=suppression_réussie");
exit();
