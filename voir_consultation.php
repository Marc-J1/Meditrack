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

// Récupérer les informations de la consultation avec les données du patient
$stmt = $pdo->prepare("
    SELECT c.*, p.nom, p.prenom, p.sexe, p.date_naissance 
    FROM consultations c 
    JOIN patients p ON c.id_patient = p.id_patient 
    WHERE c.id = ? AND c.id_utilisateur = ?
");
$stmt->execute([$consultation_id, $_SESSION['user']['id']]);

$consultation = $stmt->fetch();

if (!$consultation) {
    header("Location: lister_patients.php?error=Consultation non trouvée");
    exit();
}

// Calculer l'âge du patient
$date_naissance = new DateTime($consultation['date_naissance']);
$aujourd_hui = new DateTime();
$age = $aujourd_hui->diff($date_naissance)->y;

// Récupérer UNIQUEMENT les éléments liés à la consultation courante
$stmt_consultation_actuelle = $pdo->prepare("
    SELECT 
        c.id as consultation_id,
        c.date_consultation,
        c.motif,
        c.diagnostic,
        c.statut,
        -- Ordonnances
        o.id as ordonnance_id,
        o.date_ordonnance,
        -- Observations
        obs.id as observation_id,
        obs.date_observation,
        obs.contenu as contenu_observation,
        obs.type_observation,
        -- Bons d'examen
        be.id as bon_examen_id,
        be.date_creation as date_bon_examen,
        be.service_demandeur
    FROM consultations c
    LEFT JOIN ordonnances o ON c.id = o.id_consultation
    LEFT JOIN observations obs ON c.id = obs.id_consultation
    LEFT JOIN bons_examens be ON c.id = be.id_consultation
    WHERE c.id = ? AND c.id_utilisateur = ?
");
$stmt_consultation_actuelle->execute([$consultation_id, $_SESSION['user']['id']]);
$consultation_data = $stmt_consultation_actuelle->fetchAll();

// Organiser les données de la consultation courante
$consultation_courante = [
    'consultation_id' => $consultation_id,
    'date_consultation' => $consultation['date_consultation'],
    'motif' => $consultation['motif'],
    'diagnostic' => $consultation['diagnostic'],
    'statut' => $consultation['statut'],
    'ordonnances' => [],
    'observations' => [],
    'bons_examens' => []
];

foreach ($consultation_data as $row) {
    // Ajouter ordonnance si elle existe
    if ($row['ordonnance_id'] && !in_array($row['ordonnance_id'], array_column($consultation_courante['ordonnances'], 'id'))) {
        $consultation_courante['ordonnances'][] = [
            'id' => $row['ordonnance_id'],
            'date' => $row['date_ordonnance']
        ];
    }
    
    // Ajouter observation si elle existe
    if ($row['observation_id'] && !in_array($row['observation_id'], array_column($consultation_courante['observations'], 'id'))) {
        $consultation_courante['observations'][] = [
            'id' => $row['observation_id'],
            'date' => $row['date_observation'],
            'contenu' => $row['contenu_observation'],
            'type' => $row['type_observation']
        ];
    }
    
    // Ajouter bon d'examen s'il existe
    if ($row['bon_examen_id'] && !in_array($row['bon_examen_id'], array_column($consultation_courante['bons_examens'], 'id'))) {
        $consultation_courante['bons_examens'][] = [
            'id' => $row['bon_examen_id'],
            'date' => $row['date_bon_examen'],
            'service' => $row['service_demandeur']
        ];
    }
}

// Traitement de la mise à jour
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_consultation'])) {
    $date_consultation = $_POST['date_consultation'] ?? '';
    $motif = $_POST['motif'] ?? '';
    $diagnostic = $_POST['diagnostic'] ?? '';
    $notes = $_POST['notes'] ?? '';
    $statut = $_POST['statut'] ?? 'en_cours';

    if (!empty($date_consultation) && !empty($motif)) {
        $stmt = $pdo->prepare("UPDATE consultations SET date_consultation = ?, motif = ?, diagnostic = ?, notes = ?, statut = ? WHERE id = ?");
        $stmt->execute([$date_consultation, $motif, $diagnostic, $notes, $statut, $consultation_id]);
        header("Location: voir_consultation.php?id=$consultation_id&success=1");
        exit();
    }
}

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<div class="pc-container">
    <div class="pc-content">
        <div class="page-header">
            <div class="d-flex justify-content-between align-items-center">
                <h4 class="mb-3">Détails de la Consultation</h4>
                <a href="details_patient.php?id=<?= $consultation['id_patient'] ?>" class="btn btn-secondary">
                    <i class="ti ti-arrow-left"></i> Retour
                </a>
            </div>
        </div>

        <!-- Infos Patient -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="card-title mb-0"><i class="ti ti-user"></i> Informations du Patient</h5>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6"><strong>Nom :</strong> <?= htmlspecialchars($consultation['nom'] . ' ' . $consultation['prenom']) ?></div>
                    <div class="col-md-6"><strong>Sexe :</strong> <?= htmlspecialchars($consultation['sexe']) ?></div>
                    <div class="col-md-6 mt-2"><strong>Date de naissance :</strong> <?= date('d/m/Y', strtotime($consultation['date_naissance'])) ?></div>
                    <div class="col-md-6 mt-2"><strong>Âge :</strong> <?= $age ?> ans</div>
                </div>
            </div>
        </div>

        <!-- Formulaire ou détails -->
        <?php if ($consultation['statut'] !== 'terminee'): ?>
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="card-title mb-0"><i class="ti ti-edit"></i> Modifier la consultation</h5>
            </div>
            <div class="card-body">
                <form method="POST">
                    <input type="hidden" name="update_consultation" value="1">

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Date et Heure</label>
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
                        <label class="form-label">Motif</label>
                        <textarea name="motif" class="form-control" required><?= htmlspecialchars($consultation['motif']) ?></textarea>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Diagnostic</label>
                        <textarea name="diagnostic" class="form-control"><?= htmlspecialchars($consultation['diagnostic']) ?></textarea>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Notes</label>
                        <textarea name="notes" class="form-control"><?= htmlspecialchars($consultation['notes']) ?></textarea>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary"><i class="ti ti-device-floppy"></i> Enregistrer</button>
                        <a href="voir_consultation.php?id=<?= $consultation_id ?>" class="btn btn-secondary"><i class="ti ti-x"></i> Annuler</a>
                    </div>
                </form>
            </div>
        </div>
        <?php else: ?>
        <!-- Consultation terminée : mode lecture -->
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title mb-0"><i class="ti ti-calendar"></i> Détails de la Consultation</h5>
                <span class="badge bg-success fs-6"><?= ucfirst(str_replace('_', ' ', $consultation['statut'])) ?></span>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Date et Heure :</label>
                        <p class="form-control-plaintext"><?= date('d/m/Y à H:i', strtotime($consultation['date_consultation'])) ?></p>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Statut :</label>
                        <p class="form-control-plaintext">
                            <span class="badge bg-success"><?= ucfirst($consultation['statut']) ?></span>
                        </p>
                    </div>
                </div>
                <div class="mb-3"><label class="form-label fw-bold">Motif :</label>
                    <div class="border rounded p-3 bg-light"><?= nl2br(htmlspecialchars($consultation['motif'])) ?></div>
                </div>
                <?php if (!empty($consultation['diagnostic'])): ?>
                <div class="mb-3"><label class="form-label fw-bold">Diagnostic :</label>
                    <div class="border rounded p-3 bg-light"><?= nl2br(htmlspecialchars($consultation['diagnostic'])) ?></div>
                </div>
                <?php endif; ?>
                <?php if (!empty($consultation['notes'])): ?>
                <div class="mb-3"><label class="form-label fw-bold">Notes :</label>
                    <div class="border rounded p-3 bg-light"><?= nl2br(htmlspecialchars($consultation['notes'])) ?></div>
                </div>
                <?php endif; ?>
            </div>
        </div>
        <?php endif; ?>

        <!-- SECTION MODIFIÉE : Documents liés à cette consultation -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="card-title mb-0"><i class="ti ti-files"></i> Documents liés à cette consultation</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table id="documentsTable" class="table table-striped table-bordered" style="width:100%">
                        <thead>
                            <tr>
                                <th>Date Consultation</th>
                                <th>Motif</th>
                                <th>Diagnostic</th>
                                <th>Statut</th>
                                <th>Ordonnances</th>
                                <th>Observations</th>
                                <th>Bons d'Examen</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><?= date('d/m/Y H:i', strtotime($consultation_courante['date_consultation'])) ?></td>
                                <td>
                                    <div class="text-truncate" style="max-width: 150px;" title="<?= htmlspecialchars($consultation_courante['motif']) ?>">
                                        <?= htmlspecialchars(substr($consultation_courante['motif'], 0, 50)) ?><?= strlen($consultation_courante['motif']) > 50 ? '...' : '' ?>
                                    </div>
                                </td>
                                <td>
                                    <div class="text-truncate" style="max-width: 150px;" title="<?= htmlspecialchars($consultation_courante['diagnostic']) ?>">
                                        <?= htmlspecialchars(substr($consultation_courante['diagnostic'], 0, 50)) ?><?= strlen($consultation_courante['diagnostic']) > 50 ? '...' : '' ?>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge bg-<?= $consultation_courante['statut'] === 'terminee' ? 'success' : ($consultation_courante['statut'] === 'en_cours' ? 'warning' : 'secondary') ?>">
                                        <?= ucfirst(str_replace('_', ' ', $consultation_courante['statut'])) ?>
                                    </span>
                                </td>
                                <td>
                                    <?php if (!empty($consultation_courante['ordonnances'])): ?>
                                        <?php foreach ($consultation_courante['ordonnances'] as $ord): ?>
                                            <div class="mb-1">
                                                <small class="text-muted"><?= date('d/m/Y', strtotime($ord['date'])) ?></small>
                                                <a href="voir_ordonance.php?id=<?= $ord['id'] ?>&from_consultation=<?= $consultation_id ?>" class="btn btn-sm btn-outline-success ms-1" title="Voir ordonnance">
                                                    <i class="ti ti-eye"></i> 
                                                </a>
                                            </div>
                                        <?php endforeach; ?>
                                    <?php else: ?>
                                        <span class="text-muted">Aucune</span>
                                    <?php endif; ?>
                                </td>
                                <td>
                                    <?php if (!empty($consultation_courante['observations'])): ?>
                                        <?php foreach ($consultation_courante['observations'] as $obs): ?>
                                            <div class="mb-1">
                                                <small class="text-muted"><?= date('d/m/Y', strtotime($obs['date'])) ?></small>
                                                <span class="badge bg-info ms-1"><?= ucfirst($obs['type']) ?></span>
                                                <a href="voir_observation.php?id=<?= $obs['id'] ?>&from_consultation=<?= $consultation_id ?>" class="btn btn-sm btn-outline-warning ms-1" title="Voir observation">
                                                    <i class="ti ti-eye"></i> 
                                                </a>
                                            </div>
                                        <?php endforeach; ?>
                                    <?php else: ?>
                                        <span class="text-muted">Aucune</span>
                                    <?php endif; ?>
                                </td>
                                <td>
                                    <?php if (!empty($consultation_courante['bons_examens'])): ?>
                                        <?php foreach ($consultation_courante['bons_examens'] as $bon): ?>
                                            <div class="mb-1">
                                                <small class="text-muted"><?= date('d/m/Y', strtotime($bon['date'])) ?></small>
                                                <a href="voir_bon_examen.php?id=<?= $bon['id'] ?>&from_consultation=<?= $consultation_id ?>" class="btn btn-sm btn-outline-primary ms-1" title="Voir bon d'examen">
                                                    <i class="ti ti-eye"></i> 
                                                </a>
                                            </div>
                                        <?php endforeach; ?>
                                    <?php else: ?>
                                        <span class="text-muted">Aucun</span>
                                    <?php endif; ?>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Actions -->
        <div class="card">
            <div class="card-header"><h5 class="card-title mb-0"><i class="ti ti-settings"></i> Actions</h5></div>
            <div class="card-body">
                <div class="d-flex gap-2 flex-wrap">
                    <a href="ajouter_observation.php?id_patient=<?= $consultation['id_patient'] ?>&id_consultation=<?= $consultation['id'] ?>" class="btn btn-warning">
  <i class="ti ti-eye-plus"></i>Ajouter observation 
</a>

                    <a href="ordonance_patient.php?id=<?= $consultation['id_patient'] ?>&id_consultation=<?= $consultation['id'] ?>" class="btn btn-success">
                        <i class="ti ti-file-text"></i> Nouvelle Ordonnance
                    </a>
                    <a href="nouvelle_consultation.php?id=<?= $consultation['id_patient'] ?>" class="btn btn-warning">
                        <i class="ti ti-calendar-plus"></i> nouvelle consultation
                    </a>
                    <a href="bon_examen.php?id_patient=<?= $consultation['id_patient'] ?>&id_consultation=<?= $consultation['id'] ?>" class="btn btn-primary">
  <i class="ti ti-vial"></i> Créer un bon d'examen
</a>

                </div>
            </div>
        </div>

    </div>
</div>

<?php include 'includes/footer.php'; ?>

<!-- DataTables CSS et JS -->
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

<script>
$(document).ready(function() {
    $('#documentsTable').DataTable({
        "language": {
            "url": "//cdn.datatables.net/plug-ins/1.13.6/i18n/fr-FR.json"
        },
        "pageLength": 10,
        "responsive": true,
        "order": [[0, "desc"]], // Trier par date décroissante
        "columnDefs": [
            { "orderable": false, "targets": [4, 5, 6] } // Désactiver le tri sur les colonnes actions
        ],
        "paging": false, // Désactiver la pagination car il n'y a qu'une ligne
        "searching": false, // Désactiver la recherche car il n'y a qu'une ligne
        "info": false // Désactiver les informations de pagination
    });
});
</script>

<style>
.card-header {
    background-color: #f8f9fa;
    border-bottom: 1px solid #dee2e6;
}
.form-control-plaintext {
    margin-bottom: 0;
    border-bottom: 1px solid #e9ecef;
    padding-bottom: 0.5rem;
}
.badge {
    font-size: 0.875rem;
}
.bg-light {
    background-color: #f8f9fa !important;
}
.border {
    border: 1px solid #dee2e6 !important;
}

/* Styles pour le tableau des documents */
#documentsTable {
    font-size: 0.9rem;
}

#documentsTable td {
    vertical-align: middle;
}

.text-truncate {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.btn-sm {
    font-size: 0.75rem;
    padding: 0.25rem 0.5rem;
}
</style>