<?php
session_start();
require_once 'db.php';

// Vérification que l'utilisateur est connecté
if (!isset($_SESSION['user'])) {
    header("Location: login.php");
    exit();
}

// Sécurisation des entrées
$email = trim($_POST['email'] ?? '');
$destinataire = trim($_POST['destinataire'] ?? '');
$sujet = trim($_POST['sujet'] ?? '');
$message = trim($_POST['message'] ?? '');

if (empty($email) || empty($destinataire) || empty($sujet) || empty($message)) {
    header("Location: support.php?error=1");
    exit();
}

// Vérifie si le destinataire existe
$stmt = $pdo->prepare("SELECT * FROM users WHERE mail = ?");
$stmt->execute([$destinataire]);
$dest_user = $stmt->fetch();

if (!$dest_user) {
    header("Location: support.php?error=1");
    exit();
}

// ✅ Insertion avec les bons noms de colonnes
$stmt = $pdo->prepare("INSERT INTO support_messages (email, destinataire, sujet, message, date_envoi)
                       VALUES (?, ?, ?, ?, NOW())");
$success = $stmt->execute([$email, $destinataire, $sujet, $message]);

if ($success) {
    header("Location: support.php?success=1");
    exit();
} else {
    header("Location: support.php?error=1");
    exit();
}
