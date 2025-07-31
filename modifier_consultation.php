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

$consultation_id = $_GET['id'];

// Récupérer la consultation et le patient
$stmt = $pdo->prepare("
    SELECT c.*, p.nom, p.prenom, p.sexe, p.date_naissance, p.id_patient 
    FROM consultations c 
    JOIN patients p ON c.id_patient = p.id_patient 
    WHERE c.id = ? AND p.id_utilisateur = ?
");
$stmt->execute([$consultation_id, $_SESSION['user']['id']]);
$consultation = $stmt->fetch();

if (!$consultation) {
    header("Location: lister_patients.php?error=Consultation non trouvée");
    exit();
}

$patient_id = $consultation['id_patient'];
$message = '';
$error = '';

// Traitement du formulaire
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $date_consultation = $_POST['date_consultation'] ?? '';
    $motif = $_POST['motif'] ?? '';
    $diagnostic = $_POST['diagnostic'] ?? '';
    $notes = $_POST['notes'] ?? '';
    $statut = $_POST['statut'] ?? 'terminee';

    if (empty($date_consultation) || empty($motif)) {
        $error = "La date et le motif sont obligatoires.";
    } else {
        try {
            $stmt = $pdo->prepare("UPDATE consultations SET date_consultation = ?, motif = ?, diagnostic = ?, notes = ?, statut = ? WHERE id = ?");
            $stmt->execute([$date_consultation, $motif, $diagnostic, $notes, $statut, $consultation_id]);
            $message = "Consultation modifiée avec succès.";
            header("refresh:2;url=voir_consultation.php?id=$consultation_id");
        } catch (Exception $e) {
            $error = "Erreur lors de la modification : " . $e->getMessage();
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
        <h4 class="mb-3">Modifier Consultation</h4>
        <a href="voir_consultation.php?id=<?= $consultation_id ?>" class="btn btn-secondary">
          <i class="ti ti-arrow-left"></i> Retour
        </a>
      </div>
    </div>

    <!-- Patient -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="card-title mb-0">
          <i class="ti ti-user"></i> Patient
        </h5>
      </div>
      <div class="card-body">
        <strong><?= htmlspecialchars($consultation['nom'] . ' ' . $consultation['prenom']) ?></strong> - 
        <?= htmlspecialchars($consultation['sexe']) ?> - 
        <?= date('d/m/Y', strtotime($consultation['date_naissance'])) ?>
      </div>
    </div>

    <!-- Messages -->
    <?php if ($message): ?>
    <div class="alert alert-success"><?= $message ?></div>
    <?php endif; ?>

    <?php if ($error): ?>
    <div class="alert alert-danger"><?= $error ?></div>
    <?php endif; ?>

    <!-- Formulaire de modification -->
    <div class="card">
      <div class="card-header">
        <h5 class="card-title mb-0"><i class="ti ti-edit"></i> Modifier les détails</h5>
      </div>
      <div class="card-body">
        <form method="POST">
          <div class="row">
            <div class="col-md-6 mb-3">
              <label class="form-label">Date et Heure <span class="text-danger">*</span></label>
              <input type="datetime-local" name="date_consultation" class="form-control" required
                     value="<?= date('Y-m-d\TH:i', strtotime($consultation['date_consultation'])) ?>">
            </div>
            <div class="col-md-6 mb-3">
              <label class="form-label">Statut</label>
              <select name="statut" class="form-select">
                <option value="programmee" <?= $consultation['statut'] === 'programmee' ? 'selected' : '' ?>>Programmée</option>
                <option value="en_cours" <?= $consultation['statut'] === 'en_cours' ? 'selected' : '' ?>>En cours</option>
                <option value="terminee" <?= $consultation['statut'] === 'terminee' ? 'selected' : '' ?>>Terminée</option>
              </select>
            </div>
          </div>

          <div class="mb-3">
            <label class="form-label">Motif <span class="text-danger">*</span></label>
            <textarea name="motif" class="form-control" rows="3" required><?= htmlspecialchars($consultation['motif']) ?></textarea>
          </div>

          <div class="mb-3">
            <label class="form-label">Diagnostic</label>
            <textarea name="diagnostic" class="form-control" rows="3"><?= htmlspecialchars($consultation['diagnostic']) ?></textarea>
          </div>

          <div class="mb-3">
            <label class="form-label">Notes</label>
            <textarea name="notes" class="form-control" rows="3"><?= htmlspecialchars($consultation['notes']) ?></textarea>
          </div>

          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary">
              <i class="ti ti-device-floppy"></i> Enregistrer
            </button>
            <a href="voir_consultation.php?id=<?= $consultation_id ?>" class="btn btn-secondary">
              <i class="ti ti-x"></i> Annuler
            </a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<?php include 'includes/footer.php'; ?>
