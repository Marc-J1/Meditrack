<?php
session_start();
include 'includes/auto_track.php';
require_once 'db.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'A Crée sur la page bon d\'examen');

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id_patient      = $_POST['id_patient'] ?? null;
    $id_utilisateur  = $_SESSION['user']['id'];

    $id_consultation = $_POST['id_consultation'] ?? null;
    $age             = $_POST['age'] ?? null;
    $poids           = $_POST['poids'] ?? null;
    $service         = trim($_POST['service_demandeur'] ?? '');
    $commentaire     = trim($_POST['renseignement_clinique'] ?? '');

    // ✅ On ne vérifie plus $service, il peut être vide
    if ($id_patient && $commentaire) {
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
                !empty($service) ? $service : null, // si vide → NULL
                $commentaire
            ]);

            // ✅ Redirection alignée sur la logique "ordonnance"
            $bon_id = $pdo->lastInsertId();

            if (!empty($id_consultation)) {
                // Si créé depuis une consultation → retour consultation avec toast
                header("Location: voir_consultation.php?id=" . (int)$id_consultation . "&success=bon_examen");
            } else {
                // Sinon → page du bon d'examen avec toast
                header("Location: voir_bon_examen.php?id=" . (int)$bon_id . "&success=1");
            }
            exit();
        } catch (PDOException $e) {
            error_log("Erreur SQL: " . $e->getMessage());

            if (!empty($id_consultation)) {
                header("Location: voir_consultation.php?id=" . (int)$id_consultation . "&error=" . urlencode("Erreur lors de la création du bon d'examen"));
            } else {
                header("Location: bon_examen.php?id_patient=" . (int)$id_patient . "&error=sql");
            }
            exit();
        }
    } else {
        header("Location: bon_examen.php?id_patient=" . (int)$id_patient . "&error=manque_champs");
        exit();
    }
} else {
    header("Location: lister_patients.php");
    exit();
}
