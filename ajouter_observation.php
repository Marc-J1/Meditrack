<?php
session_start();
require_once 'db.php';
include 'includes/auto_track.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'Accès à ajouter observation');

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

if (!isset($_GET['id_patient'])) {
    header("Location: lister_patients.php");
    exit();
}

$id_patient = $_GET['id_patient'];
$id_utilisateur = $_SESSION['user']['id'] ?? null;
$id_consultation = $_GET['id_consultation'] ?? null;

$errors = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $type_observation = $_POST['type_observation'] ?? 'Suivi';
    $contenu = trim($_POST['contenu'] ?? '');

    if (empty($contenu)) {
        $errors[] = "Le contenu de l'observation est requis.";
    }

    if (empty($errors)) {
        try {
            $stmt = $pdo->prepare("
                INSERT INTO observations (id_patient, id_utilisateur, id_consultation, type_observation, contenu) 
                VALUES (?, ?, ?, ?, ?)
            ");
            $stmt->execute([
                $id_patient,
                $id_utilisateur,
                $id_consultation ?: null,
                $type_observation,
                $contenu
            ]);

            if ($id_consultation) {
                header("Location: voir_consultation.php?id=$id_consultation&success=observation");
            } else {
                header("Location: details_patient.php?id=$id_patient&success=observation");
            }
            exit();

        } catch (PDOException $e) {
            $errors[] = "Erreur lors de l'enregistrement : " . $e->getMessage();
        }
    }
}
?>

<?php include 'includes/header.php'; ?>
<?php include 'includes/sidebar-medecin.php'; ?>

<!-- SweetAlert2 pour le toast -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<?php if (isset($_GET['success']) && $_GET['success'] === 'observation'): ?>
<script>
document.addEventListener('DOMContentLoaded', function () {
  Swal.fire({
    toast: true,
    position: 'top-end',
    icon: 'success',
    title: "Observation ajoutée avec succès",
    showConfirmButton: false,
    timer: 3000,
    timerProgressBar: true,
    background: '#333',
    color: '#fff'
  });
});
</script>
<?php endif; ?>

<div class="pc-container">
  <div class="pc-content">
    <div class="page-header">
      <h4 class="mb-3">Ajouter une Observation</h4>
      <a href="details_patient.php?id=<?= $id_patient ?>" class="btn btn-secondary">&larr; Retour au patient</a>
    </div>

    <div class="card">
      <div class="card-body">
        <?php if (!empty($errors)): ?>
          <div class="alert alert-danger">
            <ul class="mb-0">
              <?php foreach ($errors as $error): ?>
                <li><?= htmlspecialchars($error) ?></li>
              <?php endforeach; ?>
            </ul>
          </div>
        <?php endif; ?>

        <form method="POST">
          <div class="mb-3">
            <label class="form-label fw-bold">Type d'observation</label>
            <select name="type_observation" class="form-select">
              <option value="Suivi">Suivi</option>
              <option value="Diagnostic">Diagnostic</option>
              <option value="Note">Note</option>
            </select>
          </div>

          <div class="mb-3">
            <label class="form-label fw-bold">Contenu</label>
            <textarea name="contenu" class="form-control" rows="5" placeholder="Détail de l'observation..."><?= htmlspecialchars($_POST['contenu'] ?? '') ?></textarea>
          </div>

          <div class="col-span-12 text-end">
            <button type="submit" class="btn btn-success">Enregistrer</button>
            <a href="details_patient.php?id=<?= $id_patient ?>" class="btn btn-secondary">Annuler</a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<?php include 'includes/footer.php'; ?>
