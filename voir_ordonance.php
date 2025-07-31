<?php
session_start();
require_once 'db.php';

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
    <div class="page-header d-flex justify-content-between align-items-center">
      <h4 class="mb-3">Détails de l'Ordonnance</h4>
      <div>
        <a href="<?= $retour_url ?>" class="btn btn-secondary">
          <i class="ti ti-arrow-left"></i> <?= $retour_text ?>
        </a>

        <?php if ($ordonnance['statut'] === 'active'): ?>
        <a href="modifier_ordonnance.php?id=<?= $ordonnance['id'] ?>" class="btn btn-primary">
          <i class="ti ti-edit"></i> Modifier
        </a>
        <?php endif; ?>
      </div>
    </div>

    <!-- Informations du patient -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="card-title mb-0"><i class="ti ti-user"></i> Informations Patient</h5>
      </div>
      <div class="grid grid-cols-12 gap-4 p-4">
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Nom :</label>
            <p class="form-control-plaintext"><?= htmlspecialchars($ordonnance['nom']) ?></p>
          </div>
        </div>
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Prénom :</label>
            <p class="form-control-plaintext"><?= htmlspecialchars($ordonnance['prenom']) ?></p>
          </div>
        </div>

        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Sexe :</label>
            <p class="form-control-plaintext"><?= htmlspecialchars($ordonnance['sexe']) ?></p>
          </div>
        </div>
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Date de naissance :</label>
            <p class="form-control-plaintext"><?= date('d/m/Y', strtotime($ordonnance['date_naissance'])) ?></p>
          </div>
        </div>

        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Âge :</label>
            <p class="form-control-plaintext"><?= $age ?> ans</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Détails de l'ordonnance -->
    <div class="card mb-4">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="card-title mb-0">
          <i class="ti ti-file-text"></i> Ordonnance du <?= date('d/m/Y', strtotime($ordonnance['date_ordonnance'])) ?>
        </h5>
        <span class="badge bg-<?= $ordonnance['statut'] === 'active' ? 'success' : 'secondary' ?>">
          <?= ucfirst(htmlspecialchars($ordonnance['statut'])) ?>
        </span>
      </div>
      <div class="grid grid-cols-12 gap-4 p-4">
        <!-- Médecin -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Médecin :</label>
            <p class="form-control-plaintext"><?= htmlspecialchars($ordonnance['nom_medecin']) ?></p>
          </div>
        </div>

        <!-- Médicaments -->
        <div class="col-span-12">
          <div class="card p-4">
            <label class="font-semibold">Médicaments prescrits :</label>
            <div class="border rounded bg-light p-3"><?= nl2br(htmlspecialchars($ordonnance['medicaments'])) ?></div>
          </div>
        </div>

        <?php if (!empty($ordonnance['posologie'])): ?>
        <div class="col-span-12">
          <div class="card p-4">
            <label class="font-semibold">Posologie :</label>
            <div class="border rounded bg-light p-3"><?= nl2br(htmlspecialchars($ordonnance['posologie'])) ?></div>
          </div>
        </div>
        <?php endif; ?>

        <?php if (!empty($ordonnance['duree_traitement'])): ?>
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Durée du traitement :</label>
            <p class="form-control-plaintext"><?= htmlspecialchars($ordonnance['duree_traitement']) ?></p>
          </div>
        </div>
        <?php endif; ?>

        <?php if (!empty($ordonnance['notes'])): ?>
        <div class="col-span-12">
          <div class="card p-4">
            <label class="font-semibold">Notes et recommandations :</label>
            <div class="border rounded bg-light p-3"><?= nl2br(htmlspecialchars($ordonnance['notes'])) ?></div>
          </div>
        </div>
        <?php endif; ?>
      </div>
    </div>

    <!-- Actions -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="card-title mb-0"><i class="ti ti-settings"></i> Actions</h5>
      </div>
      <div class="card-body d-flex gap-2 flex-wrap">
        <a href="ordonance_patient.php?id=<?= $ordonnance['id_patient'] ?>" class="btn btn-success">
          <i class="ti ti-plus"></i> Nouvelle ordonnance
        </a>
        <a href="ajouter_observation.php?id_patient=<?= $ordonnance['id_patient'] ?>" class="btn btn-info">
          <i class="ti ti-eye"></i> Nouvelle observation
        </a>
        <a href="generer_ordonnance.php?id=<?= $ordonnance['id'] ?>" class="btn btn-secondary" target="_blank">
          <i class="ti ti-printer"></i> Imprimer
        </a>
      </div>
    </div>

  </div>
</div>

<?php include 'includes/footer.php'; ?>