<?php
session_start();
include 'includes/auto_track.php';
require_once 'db.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'Consulte une ordonnance');

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

if (!isset($_GET['id'])) {
    header("Location: lister_patients.php");
    exit();
}

$ordonnance_id = $_GET['id'];

// Vérifier si on vient d'une consultation spécifique
$from_consultation = isset($_GET['from_consultation']) ? $_GET['from_consultation'] : null;

$stmt = $pdo->prepare("
    SELECT o.*, p.nom, p.prenom, p.id_patient, p.date_naissance, p.sexe, u.username AS nom_medecin
    FROM ordonnances o 
    JOIN patients p ON o.id_patient = p.id_patient 
    JOIN users u ON o.id_utilisateur = u.id_utilisateur
    WHERE o.id = ? AND o.id_utilisateur = ?
");
$stmt->execute([$ordonnance_id, $_SESSION['user']['id']]);
$ordonnance = $stmt->fetch();

if (!$ordonnance) {
    header("Location: lister_patients.php?error=Ordonnance non trouvée");
    exit();
}

// Définir l'URL et le texte du bouton retour
if ($from_consultation) {
    $retour_url = "voir_consultation.php?id=" . $from_consultation;
    $retour_text = "Retour à la consultation";
} else {
    $retour_url = "details_patient.php?id=" . $ordonnance['id_patient'];
    $retour_text = "Retour au patient";
}

$date_naissance = new DateTime($ordonnance['date_naissance']);
$age = (new DateTime())->diff($date_naissance)->y;

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<div class="pc-container">
  <div class="pc-content">
    <!-- Titre + boutons -->
    <div class="page-header d-flex justify-content-between align-items-center">
      <h4 class="mb-3">Détails de l'Ordonnance</h4>
      <div class="d-flex gap-2">
        <a href="<?= htmlspecialchars($retour_url) ?>" class="btn btn-secondary">
          <i class="ti ti-arrow-left"></i> <?= htmlspecialchars($retour_text) ?>
        </a>

        <?php if ($ordonnance['statut'] === 'active'): ?>
          <a href="modifier_ordonnance.php?id=<?= htmlspecialchars($ordonnance['id']) ?>" class="btn btn-primary">
            <i class="ti ti-edit"></i> Modifier
          </a>
        <?php endif; ?>

        <a href="generer_ordonnance.php?id=<?= htmlspecialchars($ordonnance['id']) ?>" class="btn btn-secondary" target="_blank">
          <i class="ti ti-printer"></i> Imprimer
        </a>
      </div>
    </div>

    <!-- Informations du patient : cartes en ligne -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="card-title mb-0"><i class="ti ti-user"></i> Informations Patient</h5>
      </div>

      <div class="card-body">
        <div class="row g-3 align-items-stretch">
          <div class="col-md-3">
            <div class="card h-100 p-3">
              <div class="text-muted small">Nom complet</div>
              <?php
                $civilite = (strtoupper(trim((string)$ordonnance['sexe'])) === 'F') ? 'Mme' : 'Ms';
                $nom_complet = $civilite . ' ' . $ordonnance['nom'] . ' ' . $ordonnance['prenom'];
              ?>
              <div class="fw-semibold"><?= htmlspecialchars($nom_complet) ?></div>
            </div>
          </div>

          <div class="col-md-2">
            <div class="card h-100 p-3">
              <div class="text-muted small">Sexe</div>
              <div class="fw-semibold"><?= htmlspecialchars($ordonnance['sexe']) ?></div>
            </div>
          </div>

          <div class="col-md-3">
            <div class="card h-100 p-3">
              <div class="text-muted small">Date de naissance</div>
              <div class="fw-semibold"><?= date('d/m/Y', strtotime($ordonnance['date_naissance'])) ?></div>
            </div>
          </div>

          <div class="col-md-2">
            <div class="card h-100 p-3">
              <div class="text-muted small">Âge</div>
              <div class="fw-semibold"><?= htmlspecialchars($age) ?> ans</div>
            </div>
          </div>

          <div class="col-md-2">
            <div class="card h-100 p-3">
              <div class="text-muted small">Médecin</div>
              <div class="fw-semibold"><?= htmlspecialchars($ordonnance['nom_medecin']) ?></div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Détails de l'ordonnance : structure soignée -->
    <div class="card mb-4">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="card-title mb-0">
          <i class="ti ti-file-text"></i> Ordonnance du <?= date('d/m/Y', strtotime($ordonnance['date_ordonnance'])) ?>
        </h5>
        <span class="badge bg-<?= $ordonnance['statut'] === 'active' ? 'success' : 'secondary' ?>">
          <?= ucfirst(htmlspecialchars($ordonnance['statut'])) ?>
        </span>
      </div>

      <div class="card-body">
        <div class="row g-3">
          <!-- (Durée/Medicaments/Posologie non utilisés désormais : on ne les affiche pas) -->

          <!-- ✅ Ordonnance (notes) -->
          <?php if (!empty($ordonnance['notes'])): ?>
          <div class="col-12">
            <div class="card p-3">
              <div class="text-muted small mb-2">Ordonnance</div>
              <div class="border rounded bg-light p-3"><?= nl2br(htmlspecialchars($ordonnance['notes'])) ?></div>
            </div>
          </div>
          <?php endif; ?>
        </div>
      </div>
    </div>

    <!-- (Section Actions supprimée comme demandé) -->
  </div>
</div>

<?php include 'includes/footer.php'; ?>
