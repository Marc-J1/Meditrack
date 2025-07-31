<?php
session_start();
require_once 'db.php';

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id_patient = $_POST['id_patient'] ?? null;
    $id_utilisateur = $_SESSION['user']['id'];

    $id_consultation = $_POST['id_consultation'] ?? null;
    $age = $_POST['age'] ?? null;
    $poids = $_POST['poids'] ?? null;
    $service = trim($_POST['service_demandeur'] ?? '');
    $commentaire = trim($_POST['renseignement_clinique'] ?? '');

    if ($id_patient && $service && $commentaire) {
        try {
            $stmt = $pdo->prepare("
                INSERT INTO bons_examens 
                (id_patient, id_utilisateur, id_consultation, age, poids, service_demandeur, renseignement_clinique)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([
                $id_patient,
                $id_utilisateur,
                $id_consultation ?: null,
                $age ?: null,
                $poids ?: null,
                $service,
                $commentaire
            ]);

            header("Location: details_patient.php?id=$id_patient&success=bon_enregistre#examens");
            exit();
        } catch (PDOException $e) {
            error_log("Erreur SQL: " . $e->getMessage());
            header("Location: bon_examen.php?id_patient=$id_patient&error=sql");
            exit();
        }
    } else {
        header("Location: bon_examen.php?id_patient=$id_patient&error=manque_champs");
        exit();
    }
} else {
    header("Location: lister_patients.php");
    exit();
}
