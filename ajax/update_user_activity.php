<?php
session_start();
require_once '../db.php';
require_once '../includes/activity_logger.php';

// Vérification de l'utilisateur connecté
if (!isset($_SESSION['user'])) {
    http_response_code(401);
    exit(json_encode(['error' => 'Non authentifié']));
}

$action = $_POST['action'] ?? '';

// Initialiser le logger
$activityLogger = initActivityLogger($pdo);

if ($action === 'ping') {
    // Mise à jour de l'activité (heartbeat)
    $result = updateUserActivity();
    
    if ($result) {
        echo json_encode(['status' => 'success', 'message' => 'Activité mise à jour']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Erreur lors de la mise à jour']);
    }
} else {
    http_response_code(400);
    echo json_encode(['error' => 'Action non supportée']);
}
?>