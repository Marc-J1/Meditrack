<?php
session_start();
require_once 'db.php'; // Connexion à la base de données avec PDO

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email']);
    $motdepasse = trim($_POST['password']);

    if (empty($email) || empty($motdepasse)) {
        $_SESSION['login_error'] = "Veuillez remplir tous les champs.";
        header("Location: login.php");
        exit;
    }

    // 🔍 Vérifie dans la table USERS
    $stmt = $pdo->prepare("SELECT * FROM users WHERE mail = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if ($user && ($user['password'] === $motdepasse || password_verify($motdepasse, $user['password']))) {
        // ✅ Mettre toutes les infos nécessaires en session
        $_SESSION['user'] = [
            'id' => $user['id_utilisateur'],
            'username' => $user['username'],
            'role' => $user['role'],             // ex: "medecin" ou "admin"
            'statut' => $user['statut'] ?? ''    // ex: "principale" ou "interimaire"
        ];

        // 🔀 Redirection selon le rôle
        if ($user['role'] === 'admin') {
            header("Location: dashboard_admin.php");
        } elseif ($user['role'] === 'medecin') {
            header("Location: dashboard_medecin.php");
        } else {
            $_SESSION['login_error'] = "Rôle non reconnu.";
            header("Location: login.php");
        }
        exit;
    }

    // ❌ Utilisateur ou mot de passe incorrect
    $_SESSION['login_error'] = "Identifiants invalides.";
    header("Location: login.php");
    exit;
} else {
    $_SESSION['login_error'] = "Accès interdit.";
    header("Location: login.php");
    exit;
}
