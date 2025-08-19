<?php 
session_start();
require_once 'db.php';
include 'includes/auto_track.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'A été sur la page bon d\'examen');

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

if (!isset($_GET['id_patient'])) {
    header("Location: lister_patients.php");
    exit();
}

$id_patient = $_GET['id_patient'];

// Récupérer les infos du patient
$stmt = $pdo->prepare("SELECT * FROM patients WHERE id_patient = ?");
$stmt->execute([$id_patient]);
$patient = $stmt->fetch();

if (!$patient) {
    echo "Patient non trouvé.";
    exit();
}

// Calculer l'âge
$birthDate = new DateTime($patient['date_naissance']);
$today = new DateTime();
$age = $today->diff($birthDate)->y;

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<!-- SweetAlert2 pour le toast -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<?php if (isset($_GET['success']) && $_GET['success'] === 'bon_examen'): ?>
<script>
document.addEventListener('DOMContentLoaded', function () {
  Swal.fire({
    toast: true,
    position: 'top-end', // ✅ en haut à droite
    icon: 'success',
    title: "Bon d'examen créé avec succès",
    showConfirmButton: false,
    timer: 3000,
    timerProgressBar: true
  });
});
</script>
<?php endif; ?>

<div class="pc-container">
  <div class="pc-content">
    <div class="page-header d-flex justify-content-between align-items-center">
      <h4 class="mb-0">Bon d'examen</h4>
      <a href="details_patient.php?id=<?= $id_patient ?>#actions" class="btn btn-secondary">
        &larr; Retour aux actions
      </a>
    </div>

    <!-- Informations du patient -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="card-title mb-0">
          <i class="ti ti-user"></i> Informations du patient
        </h5>
      </div>

      <div class="grid grid-cols-12 gap-4 p-4">
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Nom :</label>
            <p class="form-control-plaintext"><?= htmlspecialchars($patient['nom']) ?></p>
          </div>
        </div>

        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Prénom :</label>
            <p class="form-control-plaintext"><?= htmlspecialchars($patient['prenom']) ?></p>
          </div>
        </div>

        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Âge :</label>
            <p class="form-control-plaintext"><?= $age ?> ans</p>
          </div>
        </div>

        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Poids :</label>
            <p class="form-control-plaintext"><?= !empty($patient['poids']) ? htmlspecialchars($patient['poids']) . ' kg' : 'Non renseigné' ?></p>
          </div>
        </div>
      </div>
    </div>

    <!-- Formulaire Bon d'examen -->
    <div class="card mt-4">
      <div class="card-header">
        <h5 class="card-title mb-0"><i class="ti ti-notebook"></i> Remplir le bon d'examen</h5>
      </div>
      <div class="card-body">
        <form action="enregistrer_bon_examen.php" method="POST">
          <input type="hidden" name="id_patient" value="<?= $id_patient ?>">
          <input type="hidden" name="age" value="<?= $age ?>">
          <input type="hidden" name="poids" value="<?= htmlspecialchars($patient['poids']) ?>">

          <?php if (isset($_GET['id_consultation'])): ?>
            <input type="hidden" name="id_consultation" value="<?= $_GET['id_consultation'] ?>">
          <?php endif; ?>

          <div class="mb-3">
            <label class="form-label fw-semibold">Service demandeur</label>
            <input type="text" name="service_demandeur" class="form-control" placeholder="Ex: Médecine interne">
          </div>

          <div class="mb-3">
            <label class="form-label fw-semibold">Examen</label>
            <textarea name="renseignement_clinique" class="form-control" rows="4" placeholder="Exemples : Fièvre persistante, suspicion de tuberculose..." required></textarea>
          </div>

          <button type="submit" class="btn btn-primary">
            <i class="ti ti-device-floppy"></i> Enregistrer le bon d'examen
          </button>
        </form>
      </div>
    </div>
  </div>
</div>

<?php include 'includes/footer.php'; ?>
