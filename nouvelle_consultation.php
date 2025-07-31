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

// Récupérer les informations du patient
$stmt = $pdo->prepare("SELECT * FROM patients WHERE id_patient = ?");
$stmt->execute([$patient_id]);

$patient = $stmt->fetch();

if (!$patient) {
    header("Location: lister_patients.php?error=Patient non trouvé");
    exit();
}

$message = '';
$error = '';

// Traitement du formulaire
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $date_consultation = $_POST['date_consultation'] ?? '';
    $motif = $_POST['motif'] ?? '';
    $diagnostic = $_POST['diagnostic'] ?? '';
    $notes = $_POST['notes'] ?? '';
    $statut = $_POST['statut'] ?? 'terminée';
    
    // Validation
    if (empty($date_consultation) || empty($motif)) {
        $error = "La date et le motif de consultation sont obligatoires.";
    } else {
        try {
           $stmt = $pdo->prepare("INSERT INTO consultations (id_patient, id_utilisateur, date_consultation, motif, diagnostic, statut) VALUES (?, ?, ?, ?, ?, ?)");
$stmt->execute([$patient_id, $_SESSION['user']['id'], $date_consultation, $motif, $diagnostic, $statut]);


            
            $message = "Consultation ajoutée avec succès !";
            
            // Redirection après 2 secondes
          $lastId = $pdo->lastInsertId();
header("Location: voir_consultation.php?id=" . $lastId);
exit();

        } catch (Exception $e) {
            $error = "Erreur lors de l'ajout de la consultation : " . $e->getMessage();
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
                <h4 class="mb-3">Nouvelle Consultation</h4>
                <a href="details_patient.php?id=<?= $patient_id ?>" class="btn btn-secondary">
                    <i class="ti ti-arrow-left"></i> Retour
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
                <div class="row">
                    <div class="col-md-6">
                        <strong><?= htmlspecialchars($patient['nom'] . ' ' . $patient['prenom']) ?></strong>
                    </div>
                    <div class="col-md-6">
                        <span class="text-muted">
                            <?= htmlspecialchars($patient['sexe']) ?> - 
                            <?= date('d/m/Y', strtotime($patient['date_naissance'])) ?>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Messages -->
        <?php if ($message): ?>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="ti ti-check-circle"></i> <?= htmlspecialchars($message) ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <?php endif; ?>

        <?php if ($error): ?>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="ti ti-alert-circle"></i> <?= htmlspecialchars($error) ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <?php endif; ?>

        <!-- Formulaire de consultation -->
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">
                    <i class="ti ti-calendar-plus"></i> Détails de la Consultation
                </h5>
            </div>
            <div class="card-body">
                <form method="POST">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="date_consultation" class="form-label">Date et Heure <span class="text-danger">*</span></label>
                                <input type="datetime-local" class="form-control" id="date_consultation" name="date_consultation" 
                                       value="<?= date('Y-m-d\TH:i') ?>" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="statut" class="form-label">Statut</label>
                                <select class="form-select" id="statut" name="statut">
                                    
                                    <option value="programmee">Programmée</option>
                                    <option value="en_cours">En cours</option> 

                                    <option value="terminee">Terminée</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="motif" class="form-label">Motif de la consultation <span class="text-danger">*</span></label>
                        <textarea class="form-control" id="motif" name="motif" rows="3" required 
                                  placeholder="Décrivez le motif de la consultation..."></textarea>
                    </div>

                    <div class="mb-3">
                        <label for="diagnostic" class="form-label">Diagnostic</label>
                        <textarea class="form-control" id="diagnostic" name="diagnostic" rows="3" 
                                  placeholder="Diagnostic (peut être rempli plus tard)..."></textarea>
                    </div>

                    <div class="mb-3">
                        <label for="notes" class="form-label">Notes complémentaires</label>
                        <textarea class="form-control" id="notes" name="notes" rows="4" 
                                  placeholder="Notes, observations, recommandations..."></textarea>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="ti ti-device-floppy"></i> Enregistrer
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
.card-header {
    background-color: #f8f9fa;
    border-bottom: 1px solid #dee2e6;
}

.alert {
    border: none;
    border-radius: 0.5rem;
}

.form-label {
    font-weight: 500;
}

.text-danger {
    color: #dc3545 !important;
}
</style>