<?php
session_start();
include 'includes/auto_track.php';
require_once 'db.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

if (!isset($_GET['id'])) {
    header("Location: lister_patients.php");
    exit();
}

$observation_id = $_GET['id'];

// Récupérer les détails de l'observation avec les infos du patient
$stmt = $pdo->prepare("
    SELECT o.*, p.nom, p.prenom, p.id_patient 
    FROM observations o 
    JOIN patients p ON o.id_patient = p.id_patient 
    WHERE o.id = ? AND p.id_utilisateur = ?
");
$stmt->execute([$observation_id, $_SESSION['user']['id']]);
$observation = $stmt->fetch();

if (!$observation) {
    header("Location: lister_patients.php?error=Observation non trouvée");
    exit();
}
// Vérifier si on vient d'une consultation spécifique
$from_consultation = isset($_GET['from_consultation']) ? $_GET['from_consultation'] : null;

// Définir l'URL et le texte du bouton retour
if ($from_consultation) {
    $retour_url = "voir_consultation.php?id=" . $from_consultation;
    $retour_text = "Retour à la consultation";
} else {
    $retour_url = "details_patient.php?id=" . $observation['id_patient'];
    $retour_text = "Retour au patient";
}



include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<div class="pc-container">
  <div class="pc-content">
    <div class="page-header">
      <div class="d-flex justify-content-between align-items-center">
        <h4 class="mb-3">Détails de l'Observation</h4>
        <div>
        <a href="<?= $retour_url ?>" class="btn btn-secondary">
  <i class="ti ti-arrow-left"></i> <?= $retour_text ?>
</a>
<!--- <a href="modifier_observation.php?id=<?= $observation['id'] ?>" class="btn btn-warning">
  <i class="ti ti-edit"></i> Modifier
</a>--->


          
          
        </div>
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
        <h6><?= htmlspecialchars($observation['nom'] . ' ' . $observation['prenom']) ?></h6>
        <small class="text-muted">ID Patient: <?= $observation['id_patient'] ?></small>
      </div>
    </div>

    <!-- Détails de l'observation -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="card-title mb-0">
          <i class="ti ti-calendar"></i> Observation du <?= date('d/m/Y à H:i', strtotime($observation['date_observation'])) ?>
        </h5>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-12">
            <div class="mb-4">
              <label class="form-label fw-bold">Observation :</label>
              <div class="border rounded p-3 bg-light">
                <?= nl2br(htmlspecialchars($observation['contenu'])) ?>
              </div>
            </div>
          </div>
        </div>

        <?php if (!empty($observation['diagnostic'])): ?>
        <div class="row">
          <div class="col-md-12">
            <div class="mb-4">
              <label class="form-label fw-bold">Diagnostic :</label>
              <div class="border rounded p-3 bg-light">
                <?= nl2br(htmlspecialchars($observation['diagnostic'])) ?>
              </div>
            </div>
          </div>
        </div>
        <?php endif; ?>

        <!-- Signes vitaux -->
        <div class="row">
          <?php if (!empty($observation['temperature'])): ?>
          <div class="col-md-3">
            <div class="mb-3">
              <label class="form-label fw-bold">Température :</label>
              <p class="form-control-plaintext"><?= $observation['temperature'] ?>°C</p>
            </div>
          </div>
          <?php endif; ?>

          <?php if (!empty($observation['pression_arterielle'])): ?>
          <div class="col-md-3">
            <div class="mb-3">
              <label class="form-label fw-bold">Pression Artérielle :</label>
              <p class="form-control-plaintext"><?= htmlspecialchars($observation['pression_arterielle']) ?></p>
            </div>
          </div>
          <?php endif; ?>

          <?php if (!empty($observation['poids'])): ?>
          <div class="col-md-3">
            <div class="mb-3">
              <label class="form-label fw-bold">Poids :</label>
              <p class="form-control-plaintext"><?= $observation['poids'] ?> kg</p>
            </div>
          </div>
          <?php endif; ?>

          <?php if (!empty($observation['taille'])): ?>
          <div class="col-md-3">
            <div class="mb-3">
              <label class="form-label fw-bold">Taille :</label>
              <p class="form-control-plaintext"><?= $observation['taille'] ?> cm</p>
            </div>
          </div>
          <?php endif; ?>
        </div>

        <?php if (!empty($observation['notes'])): ?>
        <div class="row">
          <div class="col-md-12">
            <div class="mb-3">
              <label class="form-label fw-bold">Notes supplémentaires :</label>
              <div class="border rounded p-3 bg-light">
                <?= nl2br(htmlspecialchars($observation['notes'])) ?>
              </div>
            </div>
          </div>
        </div>
        <?php endif; ?>
      </div>
    </div>

    <!-- Actions -->
    <div class="card">
      <div class="card-header">
        <h5 class="card-title mb-0">
          <i class="ti ti-settings"></i> Actions
        </h5>
      </div>
      <div class="card-body">
        <div class="d-flex gap-2 flex-wrap">
         
          <a href="ajouter_observation.php?id_patient=<?= $observation['id_patient'] ?>" class="btn btn-success">
            <i class="ti ti-plus"></i> Ajouter observation
          </a>
       


          <a href="ordonance_patient.php?id=<?= $observation['id_patient'] ?>" class="btn btn-info">
            <i class="ti ti-file-text"></i> Créer une ordonnance
          </a>
          
        </div>
      </div>
    </div>

  </div>
</div>

<?php include 'includes/footer.php'; ?>

<style>
  .form-control-plaintext {
    margin-bottom: 0;
    border-bottom: 1px solid #e9ecef;
    padding-bottom: 0.5rem;
  }
  
  .bg-light {
    background-color: #f8f9fa !important;
  }
</style>