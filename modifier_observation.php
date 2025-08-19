<?php
session_start();
include 'includes/auto_track.php';
require_once 'db.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'Est entrer dans la page modifier observation');

// Vérification de l'authentification et du rôle
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

// Vérification de l'ID d'observation
if (!isset($_GET['id']) || !is_numeric($_GET['id'])) {
    header("Location: lister_patients.php?error=ID d'observation invalide");
    exit();
}

$observation_id = (int)$_GET['id'];

try {
    // Récupération de l'observation avec informations du patient
    $stmt = $pdo->prepare("
        SELECT o.*, p.nom, p.prenom, p.id_patient 
        FROM observations o 
        JOIN patients p ON o.id_patient = p.id_patient 
        WHERE o.id = ? AND o.id_utilisateur = ?
    ");
    $stmt->execute([$observation_id, $_SESSION['user']['id']]);
    
    $observation = $stmt->fetch();
    
    if (!$observation) {
        header("Location: lister_patients.php?error=Observation non trouvée ou accès non autorisé");
        exit();
    }
    
} catch (PDOException $e) {
    error_log("Erreur base de données : " . $e->getMessage());
    header("Location: lister_patients.php?error=Erreur système");
    exit();
}

$errors = [];
$success = false;

// Traitement du formulaire
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Protection CSRF (optionnel mais recommandé)
    if (!isset($_POST['csrf_token']) || $_POST['csrf_token'] !== $_SESSION['csrf_token']) {
        $errors[] = "Token de sécurité invalide.";
    } else {
        // Validation des données
        $contenu = trim($_POST['contenu'] ?? '');
        $type_observation = $_POST['type_observation'] ?? 'Suivi';
        
        // Types d'observation autorisés
        $types_autorises = ['Suivi', 'Diagnostic', 'Note', 'Urgence', 'Consultation'];
        
        if (empty($contenu)) {
            $errors[] = "Le contenu de l'observation est requis.";
        } elseif (strlen($contenu) < 10) {
            $errors[] = "Le contenu doit contenir au moins 10 caractères.";
        } elseif (strlen($contenu) > 2000) {
            $errors[] = "Le contenu ne peut pas dépasser 2000 caractères.";
        }
        
        if (!in_array($type_observation, $types_autorises)) {
            $errors[] = "Type d'observation invalide.";
        }
        
        // Mise à jour si pas d'erreurs
        if (empty($errors)) {
            try {
                $stmt = $pdo->prepare("
                    UPDATE observations 
                    SET contenu = ?, type_observation = ?, date_modification = NOW() 
                    WHERE id = ? AND id_utilisateur = ?
                ");
                
                $result = $stmt->execute([
                    $contenu,
                    $type_observation,
                    $observation_id,
                    $_SESSION['user']['id']
                ]);
                
                if ($result && $stmt->rowCount() > 0) {
                    $_SESSION['success_message'] = "Observation modifiée avec succès.";
                    header("Location: voir_observation.php?id=$observation_id");
                    exit();
                } else {
                    $errors[] = "Aucune modification n'a été effectuée.";
                }
                
            } catch (PDOException $e) {
                error_log("Erreur lors de la mise à jour : " . $e->getMessage());
                $errors[] = "Erreur lors de la sauvegarde. Veuillez réessayer.";
            }
        }
    }
}

// Génération du token CSRF
if (!isset($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<div class="pc-container">
  <div class="pc-content">
    <!-- En-tête avec breadcrumb -->
    <div class="page-header">
      <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><a href="dashboard.php">Accueil</a></li>
          <li class="breadcrumb-item"><a href="lister_patients.php">Patients</a></li>
          <li class="breadcrumb-item"><a href="voir_observation.php?id=<?= $observation_id ?>">Observation</a></li>
          <li class="breadcrumb-item active">Modifier</li>
        </ol>
      </nav>
      
      <div class="d-flex justify-content-between align-items-center mt-3">
        <div>
          <h4 class="mb-1">Modifier l'observation</h4>
          <p class="text-muted mb-0">
            Patient: <strong><?= htmlspecialchars($observation['prenom'] . ' ' . $observation['nom']) ?></strong>
          </p>
        </div>
        <a href="voir_observation.php?id=<?= $observation_id ?>" class="btn btn-secondary">
          <i class="ti ti-arrow-left"></i> Retour
        </a>
      </div>
    </div>

    <!-- Formulaire de modification -->
    <div class="card mt-4">
      <div class="card-header">
        <h5 class="card-title mb-0">
          <i class="ti ti-edit"></i> Modification de l'observation
        </h5>
      </div>
      
      <div class="card-body">
        <?php if (!empty($errors)): ?>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
          <strong>Erreur(s) détectée(s) :</strong>
          <ul class="mb-0 mt-2">
            <?php foreach ($errors as $error): ?>
              <li><?= htmlspecialchars($error) ?></li>
            <?php endforeach; ?>
          </ul>
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <?php endif; ?>

        <form method="POST" id="observationForm">
          <!-- Token CSRF -->
          <input type="hidden" name="csrf_token" value="<?= $_SESSION['csrf_token'] ?>">
          
          <div class="row">
            <div class="col-md-4">
              <div class="mb-3">
                <label class="form-label fw-bold">Type d'observation <span class="text-danger">*</span></label>
                <select name="type_observation" class="form-select" required>
                  <option value="Suivi" <?= $observation['type_observation'] === 'Suivi' ? 'selected' : '' ?>>Suivi</option>
                  <option value="Diagnostic" <?= $observation['type_observation'] === 'Diagnostic' ? 'selected' : '' ?>>Diagnostic</option>
                  <option value="Note" <?= $observation['type_observation'] === 'Note' ? 'selected' : '' ?>>Note</option>
                  <option value="Urgence" <?= $observation['type_observation'] === 'Urgence' ? 'selected' : '' ?>>Urgence</option>
                  <option value="Consultation" <?= $observation['type_observation'] === 'Consultation' ? 'selected' : '' ?>>Consultation</option>
                </select>
              </div>
            </div>
            
            <div class="col-md-8">
              <div class="mb-3">
                <label class="form-label fw-bold">Date de création</label>
                <input type="text" class="form-control" 
                       value="<?= date('d/m/Y à H:i', strtotime($observation['date_creation'])) ?>" 
                       readonly>
              </div>
            </div>
          </div>

          <div class="mb-3">
            <label class="form-label fw-bold">
              Contenu de l'observation <span class="text-danger">*</span>
            </label>
            <textarea name="contenu" 
                      class="form-control" 
                      rows="8" 
                      maxlength="2000"
                      placeholder="Saisissez le contenu de votre observation..."
                      required><?= htmlspecialchars($observation['contenu']) ?></textarea>
            <div class="form-text">
              <span id="charCount">0</span>/2000 caractères
            </div>
          </div>

          <div class="d-flex justify-content-between">
            <a href="voir_observation.php?id=<?= $observation_id ?>" class="btn btn-outline-secondary">
              <i class="ti ti-x"></i> Annuler
            </a>
            
            <button type="submit" class="btn btn-primary" id="submitBtn">
              <i class="ti ti-device-floppy"></i> Enregistrer les modifications
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const textarea = document.querySelector('textarea[name="contenu"]');
    const charCount = document.getElementById('charCount');
    const submitBtn = document.getElementById('submitBtn');
    
    // Compteur de caractères
    function updateCharCount() {
        const count = textarea.value.length;
        charCount.textContent = count;
        
        if (count > 2000) {
            charCount.classList.add('text-danger');
            submitBtn.disabled = true;
        } else {
            charCount.classList.remove('text-danger');
            submitBtn.disabled = false;
        }
    }
    
    // Initialiser le compteur
    updateCharCount();
    textarea.addEventListener('input', updateCharCount);
    
    // Confirmation avant soumission
    document.getElementById('observationForm').addEventListener('submit', function(e) {
        if (!confirm('Êtes-vous sûr de vouloir modifier cette observation ?')) {
            e.preventDefault();
        }
    });
});
</script>

<?php include 'includes/footer.php'; ?>