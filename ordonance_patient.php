<?php
session_start();

require_once 'db.php';
include 'includes/auto_track.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'A accedé a la creation d\'ordonnance');

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

if (!isset($_GET['id'])) {
    header("Location: lister_patients.php");
    exit();
}

$patient_id = $_GET['id'];
$id_consultation = isset($_GET['id_consultation']) ? $_GET['id_consultation'] : null;

// Vérifier que le patient existe
$stmt = $pdo->prepare("SELECT * FROM patients WHERE id_patient = ?");
$stmt->execute([$patient_id]);
$patient = $stmt->fetch();

if (!$patient) {
    header("Location: lister_patients.php?error=Patient non trouvé");
    exit();
}

// ----- Traitement du formulaire -----
$errors = [];
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // ✅ Tout est saisi dans "notes" désormais
    $notes  = trim($_POST['notes'] ?? '');
    $statut = $_POST['statut'] ?? 'active';

    if ($notes === '') {
        $errors[] = "L’ordonnance ne peut pas être vide.";
    }

    if (empty($errors)) {
        try {
            $stmt = $pdo->prepare("
                INSERT INTO ordonnances (
                    id_patient, id_utilisateur, date_ordonnance, medicaments, posologie, duree_traitement, notes, statut, id_consultation
                ) VALUES (?, ?, NOW(), ?, ?, ?, ?, ?, ?)
            ");
            // Les anciens champs deviennent vides (compatibilité BDD)
            $stmt->execute([
                $patient_id,
                $_SESSION['user']['id'],
                '',         // medicaments (vide)
                '',         // posologie (vide)
                '',         // duree_traitement (vide)
                $notes,     // ✅ toute l'ordonnance dans notes
                $statut,
                $id_consultation
            ]);

            $ordonnance_id = $pdo->lastInsertId();
            $patient_nom = $patient['nom'] . ' ' . $patient['prenom'];
            // Log simplifié
            logCreation('ordonnance.php', "Ordonnance créée pour $patient_nom (ID ordonnance: $ordonnance_id)");

            // ✅ Redirection :
            // - depuis une consultation -> retour consultation avec toast
            // - sinon -> page de l'ordonnance avec toast
            if ($id_consultation) {
                header("Location: voir_consultation.php?id=" . urlencode($id_consultation) . "&success=ordonnance");
            } else {
                header("Location: voir_ordonance.php?id=" . urlencode($ordonnance_id) . "&success=1");
            }
            exit();
        } catch (Exception $e) {
            header("Location: creer_ordonnance.php?id=" . urlencode($patient_id) . "&error=1");
            exit();
        }
    } else {
        header("Location: creer_ordonnance.php?id=" . urlencode($patient_id) . "&error=1");
        exit();
    }
}

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<!-- Toast SweetAlert uniquement si erreur sur cette page -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<?php if (isset($_GET['error']) && $_GET['error'] == 1): ?>
<script>
document.addEventListener('DOMContentLoaded', function () {
  Swal.fire({
    toast: true,
    position: 'top-end',
    icon: 'error',
    title: "Erreur lors de la création de l’ordonnance",
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
      <div class="d-flex justify-content-between align-items-center">
        <h4 class="mb-3">Nouvelle Ordonnance</h4>
        <a href="details_patient.php?id=<?= htmlspecialchars($patient_id) ?>" class="btn btn-secondary">
          <i class="ti ti-arrow-left"></i> Retour au patient
        </a>
      </div>
    </div>

    <!-- Informations du patient -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="card-title mb-0">
          <i class="ti ti-user"></i> Patient
        </h5>
      </div>
      <div class="card-body">
        <?php
          $civilite = (strtoupper(trim((string)$patient['sexe'])) === 'F') ? 'Mme' : 'Ms';
          $nom_complet = $civilite . ' ' . $patient['nom'] . ' ' . $patient['prenom'];
        ?>
        <h6><?= htmlspecialchars($nom_complet) ?></h6>
        <small class="text-muted">
          <?= htmlspecialchars($patient['sexe']) ?> -
          <?= date('d/m/Y', strtotime($patient['date_naissance'])) ?>
        </small>
      </div>
    </div>

    <!-- Formulaire de création -->
    <div class="card">
      <div class="card-header">
        <h5 class="card-title mb-0">
          <i class="ti ti-file-text"></i> Détails de l'ordonnance
        </h5>
      </div>
      <div class="card-body">

        <form method="POST" id="form-ordonnance">
          <!-- ✅ Un seul champ : notes (ordonnance complète) -->
          <div class="row">
            <div class="col-md-12">
              <div class="mb-3">
                <label class="form-label fw-bold">Notes (ordonnance complète) <span class="text-danger">*</span></label>
                <textarea name="notes" class="form-control" rows="10" required
                  placeholder="Exemples :
Paracétamol 500mg — 1 cp 3x/j pendant 7 jours
Ibuprofène 400mg — 1 cp matin et soir
Recommandations : éviter l’alcool, boire beaucoup d’eau"><?= htmlspecialchars($_POST['notes'] ?? '') ?></textarea>
              </div>
            </div>
          </div>

          <!-- Statut -->
          <div class="row">
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Statut</label>
                <select name="statut" class="form-select">
                  <option value="active"   <?= ($_POST['statut'] ?? 'active') === 'active' ? 'selected' : '' ?>>Active</option>
                  <option value="terminee" <?= ($_POST['statut'] ?? '') === 'terminee' ? 'selected' : '' ?>>Terminée</option>
                </select>
              </div>
            </div>
          </div>

          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary">
              <i class="ti ti-device-floppy"></i> Créer l'ordonnance
            </button>
            <a href="details_patient.php?id=<?= htmlspecialchars($patient_id) ?>" class="btn btn-secondary">
              <i class="ti ti-x"></i> Annuler
            </a>
          </div>
        </form>
      </div>
    </div>

  </div>
</div>

<?php include 'includes/footer.php'; ?>

<style>
  .form-label.fw-bold { color: #495057; }
  .text-danger { color: #dc3545 !important; }
  .form-text { font-size: 0.875rem; color: #6c757d; }
  .alert { border-radius: 0.5rem; }
</style>
