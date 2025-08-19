<?php
session_start();
include 'includes/auto_track.php';
require_once 'db.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'Est entrer dans la page modifier un patient');

if (!isset($_SESSION['user'])) {
    header("Location: login.php");
    exit();
}

if (!isset($_GET['id'])) {
    header("Location: lister_patients.php");
    exit();
}

$id_bon = $_GET['id'];

$stmt = $pdo->prepare("SELECT * FROM bons_examens WHERE id = ?");
$stmt->execute([$id_bon]);
$bon = $stmt->fetch();

if (!$bon) {
    echo "Bon d'examen introuvable.";
    exit();
}

// Traitement du formulaire de modification
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $service_demandeur = $_POST['service_demandeur'] ?? '';
    $renseignement_clinique = $_POST['renseignement_clinique'] ?? '';

    if (!empty($service_demandeur) && !empty($renseignement_clinique)) {
        $stmt = $pdo->prepare("UPDATE bons_examens SET service_demandeur = ?, renseignement_clinique = ? WHERE id = ?");
        $stmt->execute([$service_demandeur, $renseignement_clinique, $id_bon]);

        header("Location: voir_bon_examen.php?id=$id_bon");
        exit();
    } else {
        $error = "Tous les champs sont obligatoires.";
    }
}

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<div class="pc-container">
  <div class="pc-content">
    <div class="page-header d-flex justify-content-between align-items-center">
      <h4 class="mb-0">Modifier le Bon d'examen</h4>
      <a href="voir_bon_examen.php?id=<?= $id_bon ?>" class="btn btn-secondary">
        &larr; Annuler
      </a>
    </div>

    <div class="card mt-4">
      <div class="card-header">
        <h5 class="card-title mb-0"><i class="ti ti-edit"></i> Formulaire de modification</h5>
      </div>
      <div class="card-body">
        <?php if (!empty($error)): ?>
          <div class="alert alert-danger"> <?= htmlspecialchars($error) ?> </div>
        <?php endif; ?>

        <form method="POST">
          <div class="mb-3">
            <label class="form-label">Service Demandeur</label>
            <textarea name="service_demandeur" class="form-control" rows="3" required><?= htmlspecialchars($bon['service_demandeur']) ?></textarea>
          </div>

          <div class="mb-3">
            <label class="form-label">Renseignement Clinique</label>
            <textarea name="renseignement_clinique" class="form-control" rows="4" required><?= htmlspecialchars($bon['renseignement_clinique']) ?></textarea>
          </div>

          <button type="submit" class="btn btn-primary">
            <i class="ti ti-device-floppy"></i> Enregistrer les modifications
          </button>
        </form>
      </div>
    </div>
  </div>
</div>

<?php include 'includes/footer.php'; ?>
