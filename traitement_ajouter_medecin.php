<?php 
session_start();
require_once 'db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Récupération des champs du formulaire
    $nom = trim($_POST['nom']);
    $password = trim($_POST['password']);
    $phone_number = trim($_POST['phone_number']);
    $address = trim($_POST['address']);
    $mail = trim($_POST['mail']);
    $statut = $_POST['statut'] ?? 'interimaire';

    // Validation : certains champs obligatoires
    if (empty($nom) || empty($mail) || empty($password)) {
        header("Location: ajouter_medecin.php?error=Champs requis manquants");
        exit();
    }

    // Vérifier si l'email existe déjà
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE mail = ?");
    $stmt->execute([$mail]);
    if ($stmt->fetchColumn() > 0) {
        header("Location: ajouter_medecin.php?error=Email déjà utilisé");
        exit();
    }

    // Insertion SANS hash du mot de passe
    try {
        $insert = $pdo->prepare("
            INSERT INTO users (username, password, phone_number, address, mail, role, statut, date_creation)
            VALUES (?, ?, ?, ?, ?, 'medecin', ?, NOW())
        ");
        $insert->execute([
            $nom, $password, $phone_number, $address, $mail, $statut
        ]);

        header("Location: ajouter_medecin.php?success=1");
        exit();
    } catch (Exception $e) {
        header("Location: ajouter_medecin.php?error=Erreur lors de l'ajout");
        exit();
    }
} else {
    header("Location: ajouter_medecin.php");
    exit();
}
