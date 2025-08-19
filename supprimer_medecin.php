<?php
session_start();
//include 'includes/auto_track.php';
require_once 'db.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
//logPageVisit(basename($_SERVER['PHP_SELF']), 'Supprimer un medecin');
logUserManagementAction(
    'suppression',
    $medecin['id_utilisateur'],
    $medecin['username'],
    "Suppression du médecin ID {$medecin['id_utilisateur']} : {$medecin['username']}",
    $donnees_avant,
    null,
    $_SESSION['user']['username'] ?? 'system' // <-- ajoute ceci
);


// Vérifie que l'utilisateur est bien un admin
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'admin') {
    header("Location: login.php");
    exit();
}

// Vérifie que l'ID est bien présent et valide
if (!isset($_GET['id']) || !is_numeric($_GET['id'])) {
    header("Location: liste_medecins.php?error=ID de médecin invalide.");
    exit();
}

$id_medecin = intval($_GET['id']);

// Vérifie que l'utilisateur est bien un médecin existant
$stmt = $pdo->prepare("
    SELECT * FROM users 
    WHERE id_utilisateur = ? 
    AND role = 'medecin' 
    AND statut IN ('principal', 'interimaire')
");
$stmt->execute([$id_medecin]);
$medecin = $stmt->fetch();

if (!$medecin) {
    header("Location: liste_medecins.php?error=Médecin introuvable ou non valide.");
    exit();
}

// 🔍 Journaliser avant suppression
$donnees_avant = [
    'username' => $medecin['username'],
    'role' => $medecin['role'],
    'statut' => $medecin['statut'],
    'mail' => $medecin['mail'],
    'photo' => $medecin['photo']
];

logUserManagementAction(
    'suppression',
    $medecin['id_utilisateur'],
    $medecin['username'],
    "Suppression du médecin ID {$medecin['id_utilisateur']} : {$medecin['username']}",
    $donnees_avant,
    null
);

// Suppression du médecin
$delete = $pdo->prepare("DELETE FROM users WHERE id_utilisateur = ?");
$success = $delete->execute([$id_medecin]);

if ($success) {
    header("Location: liste_medecins.php?success=Médecin supprimé avec succès.");
} else {
    header("Location: liste_medecins.php?error=Erreur lors de la suppression.");
}
exit();
