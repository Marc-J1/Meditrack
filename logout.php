<?php
session_start();

require_once 'db.php';                 // $pdo
require_once 'includes/activity_logger.php';

$activityLogger = initActivityLogger($pdo);

$userId   = $_SESSION['user']['id_utilisateur'] ?? null;
$username = $_SESSION['user']['username']       ?? 'inconnu';
$sessionId = session_id();
$ip        = $_SERVER['REMOTE_ADDR']      ?? null;
$userAgent = $_SERVER['HTTP_USER_AGENT']  ?? null;

try {
    if (isset($_SESSION['user'])) {

        // Si pour une raison quelconque l'ID n'est pas en session, on tente de le retrouver
        if (empty($userId) && !empty($username)) {
            $stmtU = $pdo->prepare("SELECT id_utilisateur FROM users WHERE username = ? LIMIT 1");
            $stmtU->execute([$username]);
            $userId = $stmtU->fetchColumn() ?: null;
        }

        // Marquer la session comme fermée
        $stmt = $pdo->prepare("UPDATE user_sessions SET statut_session = 'fermee' WHERE session_id = ?");
        $stmt->execute([$sessionId]);

        // Durée de session (si tu la stockes ailleurs, adapte)
        $sessionStart    = $_SESSION['session_start'] ?? time();
        $sessionDuration = time() - $sessionStart;

        // Insérer l'action "deconnexion" avec id_utilisateur (pour respecter la FK)
        if (!empty($userId)) {
            $stmt = $pdo->prepare("
                INSERT INTO user_activity
                  (id_utilisateur, username, action_type, page_visitee, details_action, adresse_ip, session_id, user_agent, duree_session, date_action)
                VALUES
                  (?,             ?,        'deconnexion', ?,            'Déconnexion effectuée', ?,         ?,          ?,          ?,              NOW())
            ");
            $stmt->execute([
                $userId,
                $username,
                basename($_SERVER['PHP_SELF']),
                $ip,
                $sessionId,
                $userAgent,
                $sessionDuration
            ]);
        } else {
            // Si on n'a vraiment pas d'id_utilisateur, on évite de casser la déconnexion
            // (optionnel) écrire dans un log applicatif
        }
    }
} catch (Exception $e) {
    // On ne bloque pas la déconnexion si le log échoue
    // (optionnel) error_log('Logout log error: '.$e->getMessage());
}

// Nettoyage de la session
$_SESSION = [];
session_destroy();

// Redirection
header("Location: login.php");
exit;
