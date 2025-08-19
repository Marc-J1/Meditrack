<?php
session_start();
include 'includes/auto_track.php';
require_once 'db.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'Consulte l\'historique des patients');

if (!isset($_SESSION['user']) || 
    $_SESSION['user']['role'] !== 'medecin' || 
    $_SESSION['user']['statut'] !== 'principal') {
    header("Location: login.php");
    exit();
}

$page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
$limit = 20;
$offset = ($page - 1) * $limit;

$filter_action = isset($_GET['action']) && in_array($_GET['action'], ['ajout', 'modification', 'suppression']) ? $_GET['action'] : '';
$filter_patient = isset($_GET['patient']) ? trim($_GET['patient']) : '';
$filter_date_debut = isset($_GET['date_debut']) ? $_GET['date_debut'] : '';
$filter_date_fin = isset($_GET['date_fin']) ? $_GET['date_fin'] : '';

$whereConditions = [];
$params = [];

if ($filter_action) {
    $whereConditions[] = "action_type = ?";
    $params[] = $filter_action;
}

if ($filter_patient) {
    $whereConditions[] = "(nom_patient LIKE ? OR prenom_patient LIKE ?)";
    $params[] = "%$filter_patient%";
    $params[] = "%$filter_patient%";
}

if ($filter_date_debut) {
    $whereConditions[] = "DATE(date_action) >= ?";
    $params[] = $filter_date_debut;
}

if ($filter_date_fin) {
    $whereConditions[] = "DATE(date_action) <= ?";
    $params[] = $filter_date_fin;
}

$whereClause = !empty($whereConditions) ? "WHERE " . implode(" AND ", $whereConditions) : "";

$sql = "SELECT * FROM historique_patients $whereClause ORDER BY date_action DESC LIMIT ? OFFSET ?";
$params[] = (int)$limit;
$params[] = (int)$offset;

$stmt = $pdo->prepare($sql);
$totalParams = count($params);
foreach ($params as $i => $val) {
    $type = ($i >= $totalParams - 2) ? PDO::PARAM_INT : PDO::PARAM_STR;
    $stmt->bindValue($i + 1, $val, $type);
}
$stmt->execute();
$historiques = $stmt->fetchAll();

$countSql = "SELECT COUNT(*) FROM historique_patients $whereClause";
$countParams = array_slice($params, 0, -2);
$countStmt = $pdo->prepare($countSql);
$countStmt->execute($countParams);
$totalRecords = $countStmt->fetchColumn();
$totalPages = ceil($totalRecords / $limit);


?>
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<title>Historique des Patients</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
<link rel="stylesheet" href="https://cdn.datatables.net/buttons/2.4.1/css/buttons.bootstrap5.min.css">
<style>
    .page-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 2rem; margin-bottom: 2rem; }
    .table-card { background: white; border-radius: 10px; padding: 1.5rem; box-shadow: 0 2px 20px rgba(0,0,0,0.1); }
    .filter-card { background: #f8f9fa; border-radius: 10px; padding: 1.5rem; margin-bottom: 2rem; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
.table-responsive {
    overflow-x: auto;
    max-width: 100%;
}

table.dataTable {
    width: 100% !important;
    table-layout: auto;
}

table.dataTable td,
table.dataTable th {
    word-wrap: break-word;
    white-space: nowrap;
    text-align: center;
}

@media (max-width: 768px) {
    table.dataTable td,
    table.dataTable th {
        white-space: normal; /* ✅ pour qu'il casse sur petit écran */
    }
}

</style>
</head>
<body>

  <?php include 'includes/sidebar-medecin.php'; ?>
  <?php include 'includes/header.php'; ?>

 
  

<div class="pc-container">
    <div class="pcoded-content"> <!-- ✅ Correction ici -->
        <div class="page-header">
            <div class="container">
                <h1><i class="fas fa-history me-2"></i> Historique des Patients</h1>
                <p class="opacity-75">Suivi complet des ajouts, modifications et suppressions de patients</p>
            </div>
        </div>

        <div class="container">
            <div class="filter-card">
                <form method="GET" class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label">Type d'action</label>
                        <select name="action" class="form-select">
                            <option value="">-- Toutes --</option>
                            <option value="ajout" <?= $filter_action === 'ajout' ? 'selected' : '' ?>>Ajout</option>
                            <option value="modification" <?= $filter_action === 'modification' ? 'selected' : '' ?>>Modification</option>
                            <option value="suppression" <?= $filter_action === 'suppression' ? 'selected' : '' ?>>Suppression</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Patient</label>
                        <input type="text" name="patient" class="form-control" value="<?= htmlspecialchars($filter_patient) ?>">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Date début</label>
                        <input type="date" name="date_debut" class="form-control" value="<?= $filter_date_debut ?>">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Date fin</label>
                        <input type="date" name="date_fin" class="form-control" value="<?= $filter_date_fin ?>">
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary w-100">Filtrer</button>
                    </div>
                </form>
            </div>

            <div class="table-card">
                <div class="table-responsive">
                <table id="tablePatients" class="table table-striped table-hover" style="width:100%">
                    <thead class="table-light">
                        <tr>
                            <th>Date</th>
                            <th>Heure</th>
                            <th>Action</th>
                            <th>Patient</th>
                            <th>Médecin</th>
                            <th>Détails</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($historiques as $historique): ?>
                        <tr>
                            <td><?= date('d/m/Y', strtotime($historique['date_action'])) ?></td>
                            <td><?= date('H:i:s', strtotime($historique['date_action'])) ?></td>
                            <td>
                                <?php
                                $badges = [
                                    'ajout' => '<span class="badge bg-success">Ajout</span>',
                                    'modification' => '<span class="badge bg-warning text-dark">Modification</span>',
                                    'suppression' => '<span class="badge bg-danger">Suppression</span>'
                                ];
                                echo $badges[$historique['action_type']] ?? $historique['action_type'];
                                ?>
                            </td>
                            <td><?= htmlspecialchars($historique['nom_patient']) . ' ' . htmlspecialchars($historique['prenom_patient']) ?></td>
                            <td><?= htmlspecialchars($historique['nom_utilisateur']) ?></td>
                            <td><?= htmlspecialchars($historique['details_action']) ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/dataTables.buttons.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.html5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.print.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/pdfmake.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/vfs_fonts.js"></script>
<script>
    $(document).ready(function() {
        const table = $('#tablePatients').DataTable({
            dom: 'Bfrtip',
            buttons: [
                { extend: 'excel', className: 'btn btn-success btn-sm' },
                { extend: 'pdf', className: 'btn btn-danger btn-sm' },
                { extend: 'print', className: 'btn btn-info btn-sm' }
            ],
            language: {
                url: '//cdn.datatables.net/plug-ins/1.13.6/i18n/fr-FR.json'
            },
            responsive: true
        });

        // 🔄 Forcer recalcul après sidebar toggle
        setTimeout(() => $(window).trigger('resize'), 500);
        window.addEventListener('resize', () => {
            table.columns.adjust().responsive.recalc();
        });
    });
</script>
</body>
</html>
<?php include 'includes/footer.php'; ?>
