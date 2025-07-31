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

$patient_id = $_GET['id'];
$id_consultation = isset($_GET['id_consultation']) ? $_GET['id_consultation'] : null;


// Vérifier que le patient existe et appartient au médecin
$stmt = $pdo->prepare("SELECT * FROM patients WHERE id_patient = ?");
$stmt->execute([$patient_id]);

$patient = $stmt->fetch();

if (!$patient) {
    header("Location: lister_patients.php?error=Patient non trouvé");
    exit();
}

// Traitement du formulaire
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $medicaments = trim($_POST['medicaments']);
    $posologie = trim($_POST['posologie']);
    $duree_traitement = trim($_POST['duree_traitement']);
    $notes = trim($_POST['notes']);
    $statut = $_POST['statut'] ?? 'active';
    
    $errors = [];
    
    if (empty($medicaments)) {
        $errors[] = "Les médicaments sont obligatoires";
    }
    
    if (empty($errors)) {
        try {
           $stmt = $pdo->prepare("
    INSERT INTO ordonnances (id_patient, id_utilisateur, date_ordonnance, medicaments, posologie, duree_traitement, notes, statut, id_consultation) 
    VALUES (?, ?, NOW(), ?, ?, ?, ?, ?, ?)
");
$stmt->execute([
    $patient_id,
    $_SESSION['user']['id'], // médecin connecté
    $medicaments,
    $posologie,
    $duree_traitement,
    $notes,
    $statut,
    $id_consultation
]);


            $ordonnance_id = $pdo->lastInsertId();
           if ($id_consultation) {
    header("Location: voir_consultation.php?id=$id_consultation&success=ordonnance");
} else {
    header("Location: voir_ordonance.php?id=$ordonnance_id&success=Ordonnance créée avec succès");
}

            exit();
        } catch (Exception $e) {
            $errors[] = "Erreur lors de la création de l'ordonnance";
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
        <h4 class="mb-3">Nouvelle Ordonnance</h4>
        <a href="details_patient.php?id=<?= $patient_id ?>" class="btn btn-secondary">
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
        <h6><?= htmlspecialchars($patient['nom'] . ' ' . $patient['prenom']) ?></h6>
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
          <div class="row">
            <div class="col-md-12">
              <div class="mb-3">
                <label class="form-label fw-bold">Médicaments prescrits <span class="text-danger">*</span></label>
                <textarea name="medicaments" class="form-control" rows="5" required 
                          placeholder="Exemple:&#10;- Paracétamol 500mg&#10;- Ibuprofène 400mg&#10;- Amoxicilline 500mg"><?= htmlspecialchars($_POST['medicaments'] ?? '') ?></textarea>
                <small class="form-text text-muted">Listez les médicaments avec leurs dosages</small>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-md-12">
              <div class="mb-3">
                <label class="form-label fw-bold">Posologie</label>
                <textarea name="posologie" class="form-control" rows="4" 
                          placeholder="Exemple:&#10;- Paracétamol: 1 comprimé 3 fois par jour après les repas&#10;- Ibuprofène: 1 comprimé matin et soir&#10;- Amoxicilline: 1 gélule toutes les 8 heures"><?= htmlspecialchars($_POST['posologie'] ?? '') ?></textarea>
                <small class="form-text text-muted">Précisez la fréquence et les modalités de prise</small>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Durée du traitement</label>
                <input type="text" name="duree_traitement" class="form-control" 
                       value="<?= htmlspecialchars($_POST['duree_traitement'] ?? '') ?>"
                       placeholder="Ex: 7 jours, 2 semaines, 1 mois">
              </div>
            </div>
            <div class="col-md-6">
              <div class="mb-3">
                <label class="form-label fw-bold">Statut</label>
                <select name="statut" class="form-select">
                  <option value="active" <?= ($_POST['statut'] ?? 'active') === 'active' ? 'selected' : '' ?>>Active</option>
                 
                  <option value="terminee" <?= ($_POST['statut'] ?? '') === 'terminee' ? 'selected' : '' ?>>Terminée</option>
                </select>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-md-12">
              <div class="mb-3">
                <label class="form-label fw-bold">Notes et recommandations</label>
                <textarea name="notes" class="form-control" rows="3" 
                          placeholder="Recommandations particulières, effets secondaires à surveiller, etc."><?= htmlspecialchars($_POST['notes'] ?? '') ?></textarea>
              </div>
            </div>
          </div>

          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary">
              <i class="ti ti-device-floppy"></i> Créer l'ordonnance
            </button>
            <a href="details_patient.php?id=<?= $patient_id ?>" class="btn btn-secondary">
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
  .form-label.fw-bold {
    color: #495057;
  }
  
  .text-danger {
    color: #dc3545 !important;
  }
  
  .form-text {
    font-size: 0.875rem;
    color: #6c757d;
  }
  
  .alert {
    border-radius: 0.5rem;
  }
</style>