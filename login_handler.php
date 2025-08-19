<?php 
session_start();
require_once 'db.php'; // connexion PDO d'abord

// Inclure le tracking APRÈS que la session et la BDD soient prêtes
include 'includes/auto_track.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $_SESSION['login_error'] = "Accès interdit.";
    header("Location: login.php");
    exit;
}

$identifiant = trim($_POST['identifiant'] ?? '');
$motdepasse  = trim($_POST['password'] ?? '');

if ($identifiant === '' || $motdepasse === '') {
    $_SESSION['login_error'] = "Veuillez remplir tous les champs.";
    header("Location: login.php");
    exit;
}

// Recherche par identifiant
$stmt = $pdo->prepare("SELECT * FROM users WHERE identifiant = ? LIMIT 1");
$stmt->execute([$identifiant]);
$user = $stmt->fetch();

$auth_ok = false;
if ($user) {
    // Vérification du mot de passe (clair ou hashé)
    if ($user['password'] === $motdepasse || password_verify($motdepasse, $user['password'])) {
        $auth_ok = true;
    }
}

if (!$auth_ok) {
    $_SESSION['login_error'] = "Identifiants invalides.";
    header("Location: login.php");
    exit;
}

// Authentification réussie → création session utilisateur
$_SESSION['user'] = [
    'id'      => $user['id_utilisateur'],
    'username'=> $user['username'],
    'role'    => $user['role'],
    'statut'  => $user['statut'] ?? '',
];

// 🆕 Message de bienvenue (toast à l'arrivée sur le dashboard)
$_SESSION['welcome_message'] = "Bienvenue dans votre dashboard " . ($user['username'] ?? '');

// Forcer changement mot de passe si demandé
if (!empty($user['must_change_password']) && (int)$user['must_change_password'] === 1) {
    header("Location: changer_mot_de_passe.php?force=1");
    exit;
}

// Créer un ID de session unique
$session_id = bin2hex(random_bytes(16));
$_SESSION['session_id']    = $session_id;
$_SESSION['session_start'] = time();

// Vérifier collision éventuelle
$check = $pdo->prepare("SELECT COUNT(*) FROM user_sessions WHERE session_id = ?");
$check->execute([$session_id]);
if ((int)$check->fetchColumn() > 0) {
    $session_id = bin2hex(random_bytes(16));
    $_SESSION['session_id'] = $session_id;
}

// Enregistrer la session en BDD
$insert = $pdo->prepare("
    INSERT INTO user_sessions (id_utilisateur, username, session_id, adresse_ip, user_agent, statut_session)
    VALUES (?, ?, ?, ?, ?, 'active')
");
$insert->execute([
    $user['id_utilisateur'],
    $user['username'],
    $session_id,
    $_SERVER['REMOTE_ADDR'] ?? '',
    $_SERVER['HTTP_USER_AGENT'] ?? ''
]);

// Log dans l'historique avec auto_track
logPageVisit(basename($_SERVER['PHP_SELF']), 'Connexion réussie');
logLogin($user);

// Redirection selon le rôle
if ($user['role'] === 'admin') {
    header("Location: dashboard_admin.php");
    exit;
}
if ($user['role'] === 'medecin') {
    header("Location: dashboard_medecin.php");
    exit;
}

// Rôle inconnu
$_SESSION['login_error'] = "Rôle non reconnu.";
header("Location: login.php");
exit;
