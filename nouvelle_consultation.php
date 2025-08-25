<?php
session_start();

require_once 'db.php';
include 'includes/auto_track.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'Accès à nouvelle consultation');

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

if (!isset($_GET['id'])) {
    header("Location: lister_patients.php");
    exit();
}

$patient_id = (int) $_GET['id'];

// Récupérer les informations du patient
$stmt = $pdo->prepare("SELECT * FROM patients WHERE id_patient = ?");
$stmt->execute([$patient_id]);
$patient = $stmt->fetch();

if (!$patient) {
    header("Location: lister_patients.php?error=Patient%20non%20trouv%C3%A9");
    exit();
}

$message = '';
$error = '';

// Valeurs par défaut / réaffichage si erreur
$date_consultation_val = date('Y-m-d\TH:i');
$motif_val = '';
$diagnostic_val = '';
$notes_val = '';
$statut_val = 'terminee'; // sans accent pour cohérence avec les options

// Traitement du formulaire
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $date_consultation = $_POST['date_consultation'] ?? '';
    $motif = $_POST['motif'] ?? '';
    $diagnostic = $_POST['diagnostic'] ?? '';
    $notes = $_POST['notes'] ?? '';
    $statut = $_POST['statut'] ?? 'terminee';

    // pour réafficher en cas d'erreur
    $date_consultation_val = htmlspecialchars($date_consultation);
    $motif_val = htmlspecialchars($motif);
    $diagnostic_val = htmlspecialchars($diagnostic);
    $notes_val = htmlspecialchars($notes);
    $statut_val = htmlspecialchars($statut);

    // Validation
    if (empty($date_consultation) || empty($motif)) {
        $error = "La date et le motif de consultation sont obligatoires.";
    } else {
        try {
            // ID utilisateur depuis la session (compatibilité deux clés possibles)
            $id_utilisateur = $_SESSION['user']['id_utilisateur'] ?? ($_SESSION['user']['id'] ?? null);
            if (!$id_utilisateur) {
                throw new Exception("Utilisateur non identifié (id_utilisateur manquant en session).");
            }

            // ✅ Insert avec la colonne notes
            $stmt = $pdo->prepare("
                INSERT INTO consultations (id_patient, id_utilisateur, date_consultation, motif, diagnostic, notes, statut)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([
                $patient_id,
                $id_utilisateur,
                $date_consultation,
                $motif,
                $diagnostic,
                $notes,
                $statut
            ]);

            $lastId = (int) $pdo->lastInsertId();

            $patient_nom = trim(($patient['nom'] ?? '') . ' ' . ($patient['prenom'] ?? ''));
            logCreation('consultation.php', "Nouvelle consultation pour $patient_nom (ID patient: $patient_id)");

            // ✅ SOLUTION A : rediriger vers la page de vue AVEC id = ID_CONSULTATION
            // et conserver l'ID patient séparément
            header("Location: voir_consultation.php?id={$lastId}&success=1&patient_id={$patient_id}");
            exit();
        } catch (Exception $e) {
            $error = "Erreur lors de l'ajout de la consultation : " . $e->getMessage();
        }
    }
}

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<!-- SweetAlert pour le toast de succès (gardé si jamais tu ré-utilises ce pattern ici plus tard) -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<div class="pc-container">
    <div class="pc-content">
        <div class="page-header">
            <div class="d-flex justify-content-between align-items-center">
                <h4 class="mb-3">Nouvelle Consultation</h4>
                <a href="details_patient.php?id=<?= (int)$patient_id ?>" class="btn btn-secondary">
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
                        <strong><?= htmlspecialchars(($patient['nom'] ?? '') . ' ' . ($patient['prenom'] ?? '')) ?></strong>
                    </div>
                    <div class="col-md-6">
                        <span class="text-muted">
                            <?= htmlspecialchars($patient['sexe'] ?? '') ?> - 
                            <?= isset($patient['date_naissance']) ? date('d/m/Y', strtotime($patient['date_naissance'])) : '' ?>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Messages (fallback) -->
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
                                       value="<?= $date_consultation_val ?>" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="statut" class="form-label">Statut</label>
                                <select class="form-select" id="statut" name="statut">
                                    <option value="programmee" <?= $statut_val==='programmee'?'selected':''; ?>>Programmée</option> 
                                    <option value="en_cours" <?= $statut_val==='en_cours'?'selected':''; ?>>En cours</option> 
                                    <option value="terminee" <?= $statut_val==='terminee'?'selected':''; ?>>Terminée</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="motif" class="form-label">Motif de la consultation <span class="text-danger">*</span></label>
                        <textarea class="form-control" id="motif" name="motif" rows="3" required 
                                  placeholder="Décrivez le motif de la consultation..."><?= $motif_val ?></textarea>
                    </div>

                    <div class="mb-3">
                        <label for="diagnostic" class="form-label">Diagnostic</label>
                        <textarea class="form-control" id="diagnostic" name="diagnostic" rows="3" 
                                  placeholder="Diagnostic (peut être rempli plus tard)..."><?= $diagnostic_val ?></textarea>
                    </div>

                    <div class="mb-3">
                        <label for="notes" class="form-label">Notes complémentaires</label>
                        <textarea class="form-control" id="notes" name="notes" rows="4" 
                                  placeholder="Notes, observations, recommandations..."><?= $notes_val ?></textarea>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="ti ti-device-floppy"></i> Enregistrer
                        </button>
                        <a href="details_patient.php?id=<?= (int)$patient_id ?>" class="btn btn-secondary">
                            <i class="ti ti-x"></i> Annuler
                        </a>

                        <?php
                        // NOTE : avec la solution A, on redirige vers voir_consultation.php,
                        // donc ce bouton ne sera normalement pas affiché juste après l'enregistrement.
                        // Je le laisse ici au cas où tu recharges la page avec des paramètres ad hoc.
                        if (isset($_GET['success']) && $_GET['success'] == '1' && isset($_GET['id'])): ?>
                          <a href="voir_consultation.php?id=<?= (int)$_GET['id'] ?>" class="btn btn-outline-success">
                            <i class="ti ti-eye"></i> Voir la consultation
                          </a>
                        <?php endif; ?>
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
.form-label { font-weight: 500; }
.text-danger { color: #dc3545 !important; }
</style>
