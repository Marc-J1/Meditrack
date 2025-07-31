<?php
session_start();
require_once 'db.php';

if (!isset($_SESSION['user'])) {
    header("Location: login.php");
    exit();
}

if (!isset($_GET['id'])) {
    header("Location: lister_patients.php");
    exit();
}

$id_bon = $_GET['id'];

$stmt = $pdo->prepare("
    SELECT b.*, p.nom, p.prenom, p.date_naissance, p.poids, u.username AS medecin
    FROM bons_examens b
    JOIN patients p ON b.id_patient = p.id_patient
    LEFT JOIN users u ON b.id_utilisateur = u.id_utilisateur
    WHERE b.id = ?
");
$stmt->execute([$id_bon]);
$bon = $stmt->fetch();

if (!$bon) {
    echo "Bon d'examen introuvable.";
    exit();
}
$from_consultation = isset($_GET['from_consultation']) ? $_GET['from_consultation'] : null;

if ($from_consultation) {
    $retour_url = "voir_consultation.php?id=" . $from_consultation;
    $retour_text = "Retour à la consultation";
} else {
    $retour_url = "details_patient.php?id=" . $bon['id_patient'] . "#examens";
    $retour_text = "Retour au patient";
}

// Calcul de l'âge
$birthDate = new DateTime($bon['date_naissance']);
$today = new DateTime();
$age = $today->diff($birthDate)->y;

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<div class="pc-container">
  <div class="pc-content">
    <div class="page-header d-flex justify-content-between align-items-center">
      <h4 class="mb-0">Détail du Bon d'examen</h4>
      <div class="d-flex gap-2">
        <a href="<?= $retour_url ?>" class="btn btn-secondary">
  &larr; <?= $retour_text ?>
</a>

        <a href="generer_bon_examen.php?id=<?= $bon['id'] ?>" class="btn btn-primary" target="_blank">
          <i class="ti ti-printer"></i> Imprimer le bon
        </a>
        <a href="modifier_bon_examen.php?id=<?= $bon['id'] ?>" class="btn btn-warning">
          <i class="ti ti-edit"></i> Modifier
        </a>
      </div>
    </div>

    <!-- Infos Patient -->
    <!-- Informations du patient -->
<div class="card mb-4">
  <div class="card-header">
    <h5 class="card-title mb-0">
      <i class="ti ti-user"></i> Informations du patient
    </h5>
  </div>

  <div class="grid grid-cols-12 gap-4 p-4">
    <!-- Ligne 1 : Nom / Prénom -->
    <div class="col-span-12 md:col-span-6">
      <div class="card p-4">
        <label class="font-semibold">Nom :</label>
        <p class="form-control-plaintext"><?= htmlspecialchars($bon['nom']) ?></p>
      </div>
    </div>
    <div class="col-span-12 md:col-span-6">
      <div class="card p-4">
        <label class="font-semibold">Prénom :</label>
        <p class="form-control-plaintext"><?= htmlspecialchars($bon['prenom']) ?></p>
      </div>
    </div>

    <!-- Ligne 2 : Date de naissance / Âge -->
    <div class="col-span-12">
      <div class="flex flex-col md:flex-row gap-4">
        <div class="flex-1 card p-4">
          <label class="font-semibold">Date de naissance :</label>
          <p class="form-control-plaintext"><?= date('d/m/Y', strtotime($bon['date_naissance'])) ?></p>
        </div>

        <div class="flex-1 card p-4">
          <label class="font-semibold">Âge :</label>
          <p class="form-control-plaintext"><?= $age ?> ans</p>
        </div>

        <div class="flex-1 card p-4">
          <label class="font-semibold">Poids :</label>
          <p class="form-control-plaintext"><?= htmlspecialchars($bon['poids']) ?> kg</p>
        </div>
      </div>
    </div>
  </div>
</div>


    <!-- Détails du Bon -->
    <!-- Détails du Bon d'examen -->
<div class="card mb-4">
  <div class="card-header">
    <h5 class="card-title mb-0">
      <i class="ti ti-vial"></i> Détails du Bon d'examen
    </h5>
  </div>

  <div class="grid grid-cols-12 gap-4 p-4">
    <!-- Service demandeur -->
    <div class="col-span-12 md:col-span-6">
      <div class="card p-4">
        <label class="font-semibold">Service demandeur :</label>
        <p class="form-control-plaintext"><?= nl2br(htmlspecialchars($bon['service_demandeur'])) ?></p>
      </div>
    </div>

    <!-- Renseignement clinique -->
    <div class="col-span-12 md:col-span-6">
      <div class="card p-4">
        <label class="font-semibold">Renseignement clinique :</label>
        <p class="form-control-plaintext"><?= nl2br(htmlspecialchars($bon['renseignement_clinique'])) ?></p>
      </div>
    </div>

    <!-- Médecin prescripteur -->
    <div class="col-span-12 md:col-span-6">
      <div class="card p-4">
        <label class="font-semibold">Médecin :</label>
        <p class="form-control-plaintext"><?= htmlspecialchars($bon['medecin']) ?></p>
      </div>
    </div>

    <!-- Date de création -->
    <div class="col-span-12 md:col-span-6">
      <div class="card p-4">
        <label class="font-semibold">Date de création :</label>
        <p class="form-control-plaintext"><?= date('d/m/Y H:i', strtotime($bon['date_creation'])) ?></p>
      </div>
    </div>
  </div>
</div>


<?php include 'includes/footer.php'; ?>
