<?php
session_start();
require_once 'db.php';

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'admin') {
    header("Location: login.php");
    exit();
}

if (!isset($_GET['id']) || !is_numeric($_GET['id'])) {
    header("Location: liste_medecins.php?error=ID de médecin invalide.");
    exit();
}

$id_medecin = intval($_GET['id']);

// Vérifier que le médecin existe
$stmt = $pdo->prepare("SELECT * FROM medecins WHERE id_medecin = ?");
$stmt->execute([$id_medecin]);
$medecin = $stmt->fetch();

if (!$medecin) {
    header("Location: liste_medecins.php?error=Médecin introuvable.");
    exit();
}

// Suppression
$delete = $pdo->prepare("DELETE FROM medecins WHERE id_medecin = ?");
$success = $delete->execute([$id_medecin]);

if ($success) {
    header("Location: liste_medecins.php?success=Médecin supprimé avec succès.");
} else {
    header("Location: liste_medecins.php?error=Erreur lors de la suppression.");
}
exit();
