<?php
session_start();
require_once 'db.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'Accès a la suppression patient');

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

// 🔍 Récupérer le patient AVANT suppression pour l'historique
$stmt = $pdo->prepare("SELECT * FROM patients WHERE id_patient = ?");
$stmt->execute([$id_patient]);
$patient = $stmt->fetch();

if (!$patient) {
    header("Location: lister_patients.php?error=patient_introuvable");
    exit();
}

// 🔒 Vérifier l'autorisation : créateur ou médecin "principal"
$isCreator = $patient['id_utilisateur'] == $id_utilisateur;
$isPrincipal = $_SESSION['user']['statut'] === 'principal';

if (!$isCreator && !$isPrincipal) {
    header("Location: lister_patients.php?error=accès_refusé");
    exit();
}

// 📝 AJOUT : Enregistrer l'action de suppression AVANT la suppression
$donnees_avant = [
    'nom' => $patient['nom'],
    'prenom' => $patient['prenom'],
    'sexe' => $patient['sexe'],
    'date_naissance' => $patient['date_naissance'],
    'telephone' => $patient['telephone'],
    'profession' => $patient['profession'],
    'poids' => $patient['poids'],
    'taille' => $patient['taille'],
    'loisirs' => $patient['loisirs'],
    'divers' => $patient['divers'],
    'antecedents_medicaux' => $patient['antecedents_medicaux'],
    'chirurgicaux' => $patient['chirurgicaux'],
    'familiaux' => $patient['familiaux'],
    'mentions_particulieres' => $patient['mentions_particulieres']
];


logPatientAction('suppression', $id_patient, $patient['nom'] . ' ' . $patient['prenom'], 'Patient est entrain d\'etre supprimer', $donnees_avant);


// 🗑️ Supprimer les données liées d'abord
$pdo->prepare("DELETE FROM bons_examens WHERE id_patient = ?")->execute([$id_patient]);
$pdo->prepare("DELETE FROM observations WHERE id_patient = ?")->execute([$id_patient]);
$pdo->prepare("DELETE FROM ordonnances WHERE id_patient = ?")->execute([$id_patient]);
$pdo->prepare("DELETE FROM consultations WHERE id_patient = ?")->execute([$id_patient]);

// 🗑️ Supprimer le patient
$pdo->prepare("DELETE FROM patients WHERE id_patient = ?")->execute([$id_patient]);
logPatientAction('suppression', $id_patient, $patient['nom'] . ' ' . $patient['prenom'], 'Patient supprimé avec succès');


header("Location: lister_patients.php?success=suppression");

exit();
?>