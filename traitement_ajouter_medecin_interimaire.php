<?php
session_start();
require_once 'db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Récupération et nettoyage
    $nom = trim($_POST['nom']);
    $email = trim($_POST['email']);
    $mot_de_passe = trim($_POST['mot_de_passe']);
    $specialite = trim($_POST['specialite']);
    $telephone = trim($_POST['telephone']);
    $adresse = trim($_POST['adresse']);
    $statut = $_POST['statut'] ?? 'interimaire';

    // Validation
    if (empty($nom) || empty($email) || empty($mot_de_passe)) {
        header("Location: ajouter_medecin_interimaire.php?error=Champs obligatoires manquants");
        exit();
    }

    // Vérifie si l'email existe déjà
    $check = $pdo->prepare("SELECT id_medecin FROM medecins WHERE email = ?");
    $check->execute([$email]);
    if ($check->fetch()) {
        header("Location: ajouter_medecin_interimaire.php?error=Email déjà utilisé");
        exit();
    }

    // Hash du mot de passe
    $hashedPassword = password_hash($mot_de_passe, PASSWORD_DEFAULT);

    // Insertion
    try {
        $insert = $pdo->prepare("
            INSERT INTO medecins (nom_complet, email, mot_de_passe, specialite, telephone, adresse, statut, date_creation)
            VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
        ");
        $insert->execute([
            $nom, $email, $hashedPassword, $specialite, $telephone, $adresse, $statut
        ]);

        header("Location: ajouter_medecin_interimaire.php?success=1");
        exit();
    } catch (Exception $e) {
        header("Location: ajouter_medecin_interimaire.php?error=Erreur lors de l'ajout");
        exit();
    }
} else {
    header("Location: ajouter_medecin_interimaire.php");
    exit();
}
