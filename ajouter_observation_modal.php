<?php
session_start();
require_once 'db.php';

if (!isset($_SESSION['user'])) {
    header("Location: login.php");
    exit();
}

// Vérifie que les champs nécessaires sont fournis
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id_patient = isset($_POST['id_patient']) ? intval($_POST['id_patient']) : 0;
    $type = trim($_POST['type'] ?? '');
    $contenu = trim($_POST['contenu'] ?? '');
    $id_utilisateur = $_SESSION['user']['id'];

    if (!$id_patient || !$type || !$contenu) {
        header("Location: observations.php?id=$id_patient&error=Champs manquants");
        exit();
    }

    try {
        $stmt = $pdo->prepare("INSERT INTO observations (id_patient, id_utilisateur, type_observation, contenu, date_observation) VALUES (?, ?, ?, ?, NOW())");
        $stmt->execute([$id_patient, $id_utilisateur, $type, $contenu]);

        header("Location: observations.php?id=$id_patient&success=Observation ajoutée");
        exit();
    } catch (PDOException $e) {
        header("Location: observations.php?id=$id_patient&error=" . urlencode("Erreur : " . $e->getMessage()));
        exit();
    }
} else {
    header("Location: observations.php");
    exit();
}