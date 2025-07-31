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

// Récupérer les détails de l'ordonnance avec les infos du patient
$stmt = $pdo->prepare("SELECT o.*, p.nom, p.prenom, p.id_patient, p.date_naissance, p.sexe FROM ordonnances o JOIN patients p ON o.id_patient = p.id_patient WHERE o.id = ? AND p.id_utilisateur = ?");
$stmt->execute([$ordonnance_id, $_SESSION['user']['id']]);
$ordonnance = $stmt->fetch();

if (!$ordonnance) {
    header("Location: lister_patients.php?error=Ordonnance non trouvée");
    exit();
}

$patient_id = $ordonnance['id_patient'];

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $medicaments = $_POST['medicaments'] ?? '';
    $posologie = $_POST['posologie'] ?? '';
    $duree_traitement = $_POST['duree_traitement'] ?? '';
    $notes = $_POST['notes'] ?? '';
    $statut = $_POST['statut'] ?? $ordonnance['statut'];

    if (empty($medicaments)) {
        $error = "Les médicaments sont obligatoires.";
    } else {
        try {
            $stmt = $pdo->prepare("UPDATE ordonnances SET medicaments = ?, posologie = ?, duree_traitement = ?, notes = ?, statut = ? WHERE id = ?");
            $stmt->execute([$medicaments, $posologie, $duree_traitement, $notes, $statut, $ordonnance_id]);

            $message = "Ordonnance mise à jour avec succès !";
            header("refresh:2;url=voir_ordonance.php?id=$ordonnance_id");
        } catch (Exception $e) {
            $error = "Erreur lors de la mise à jour : " . $e->getMessage();
        }
    }
}

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<div class="pc-container">
  <div class="pc-content">
    <div class="page-header">
      <div class="d-flex justify-content-between align-items-center">
        <h4 class="mb-3">Modifier Ordonnance</h4>
        <a href="voir_ordonance.php?id=<?= $ordonnance_id ?>" class="btn btn-secondary">
          <i class="ti ti-arrow-left"></i> Retour
        </a>
      </div>
    </div>

    <?php if ($message): ?>
      <div class="alert alert-success"> <?= htmlspecialchars($message) ?> </div>
    <?php endif; ?>
    <?php if ($error): ?>
      <div class="alert alert-danger"> <?= htmlspecialchars($error) ?> </div>
    <?php endif; ?>

    <form method="POST">
      <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
          <h5 class="card-title mb-0">Patient : <?= htmlspecialchars($ordonnance['nom'] . ' ' . $ordonnance['prenom']) ?></h5>
          <?php if ($ordonnance['statut'] !== 'terminee'): ?>
          <a href="modifier_ordonnance.php?id=<?= $ordonnance['id'] ?>" class="btn btn-primary">
            <i class="ti ti-edit"></i> Modifier
          </a>
          <?php endif; ?>
        </div>
        <div class="card-body">
          <div class="mb-3">
            <label class="form-label">Médicaments prescrits <span class="text-danger">*</span></label>
            <textarea name="medicaments" class="form-control" rows="4" required><?= htmlspecialchars($ordonnance['medicaments']) ?></textarea>
          </div>

          <div class="mb-3">
            <label class="form-label">Posologie</label>
            <textarea name="posologie" class="form-control" rows="3"><?= htmlspecialchars($ordonnance['posologie']) ?></textarea>
          </div>

          <div class="mb-3">
            <label class="form-label">Durée du traitement</label>
            <input type="text" name="duree_traitement" class="form-control" value="<?= htmlspecialchars($ordonnance['duree_traitement']) ?>">
          </div>

          <div class="mb-3">
            <label class="form-label">Notes</label>
            <textarea name="notes" class="form-control" rows="3"><?= htmlspecialchars($ordonnance['notes']) ?></textarea>
          </div>

          <div class="mb-3">
            <label class="form-label">Statut</label>
            <select name="statut" class="form-select">
              <option value="active" <?= $ordonnance['statut'] === 'active' ? 'selected' : '' ?>>Active</option>
              <option value="terminee" <?= $ordonnance['statut'] === 'terminee' ? 'selected' : '' ?>>Terminée</option>
            </select>
          </div>

          <button type="submit" class="btn btn-primary">
            <i class="ti ti-device-floppy"></i> Enregistrer les modifications
          </button>
        </div>
      </div>
    </form>
  </div>
</div>

<?php include 'includes/footer.php'; ?>
