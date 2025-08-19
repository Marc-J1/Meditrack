<?php
session_start();
include 'includes/auto_track.php';
require_once 'db.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'Est entrer dans la page liste patient');

if (!isset($_SESSION['user']) || ($_SESSION['user']['role'] !== 'medecin')) {
    header("Location: login.php");
    exit();
}

$current_medecin_id = $_SESSION['user']['id'];

// 🔽 Récupérer la liste des médecins pour le filtre
$docsStmt = $pdo->prepare("SELECT id_utilisateur, username FROM users WHERE role = 'medecin' ORDER BY username");
$docsStmt->execute();
$medecins = $docsStmt->fetchAll(PDO::FETCH_ASSOC);

// 🔽 Filtres (avec valeur par défaut pour 'medecin' = médecin connecté)
$filters = [
    'nom_patient' => isset($_GET['nom_patient']) ? trim($_GET['nom_patient']) : '',
    'sexe'        => $_GET['sexe'] ?? '',
    'age_min'     => $_GET['age_min'] ?? '',
    'age_max'     => $_GET['age_max'] ?? '',
    'taille_min'  => $_GET['taille_min'] ?? '',
    'taille_max'  => $_GET['taille_max'] ?? '',
    'poids_min'   => $_GET['poids_min'] ?? '',
    'poids_max'   => $_GET['poids_max'] ?? '',
    'date_debut'  => $_GET['date_debut'] ?? '',
    'date_fin'    => $_GET['date_fin'] ?? '',
    // 🆕 filtre médecin: 'all' pour tous, sinon id numérique — défaut = médecin connecté
    'medecin'     => isset($_GET['medecin']) ? $_GET['medecin'] : (string)$current_medecin_id,
];

$where = [];
$params = [];

// 🆕 Par défaut on limite aux patients du médecin connecté, sauf si 'all' est choisi
if ($filters['medecin'] !== 'all') {
    $where[] = "id_utilisateur = :medecin_id";
    $params[':medecin_id'] = (int)$filters['medecin']; // soit celui connecté (défaut), soit un autre id choisi
}

if (!empty($filters['nom_patient'])) {
    $where[] = "(nom LIKE :nom_patient OR prenom LIKE :nom_patient)";
    $params[':nom_patient'] = '%' . $filters['nom_patient'] . '%';
}
if (!empty($filters['sexe'])) {
    $where[] = "sexe = :sexe";
    $params[':sexe'] = $filters['sexe'];
}
if (!empty($filters['age_min'])) {
    $where[] = "TIMESTAMPDIFF(YEAR, date_naissance, CURDATE()) >= :age_min";
    $params[':age_min'] = $filters['age_min'];
}
if (!empty($filters['age_max'])) {
    $where[] = "TIMESTAMPDIFF(YEAR, date_naissance, CURDATE()) <= :age_max";
    $params[':age_max'] = $filters['age_max'];
}
if (!empty($filters['taille_min'])) {
    $where[] = "taille >= :taille_min";
    $params[':taille_min'] = $filters['taille_min'];
}
if (!empty($filters['taille_max'])) {
    $where[] = "taille <= :taille_max";
    $params[':taille_max'] = $filters['taille_max'];
}
if (!empty($filters['poids_min'])) {
    $where[] = "poids >= :poids_min";
    $params[':poids_min'] = $filters['poids_min'];
}
if (!empty($filters['poids_max'])) {
    $where[] = "poids <= :poids_max";
    $params[':poids_max'] = $filters['poids_max'];
}
if (!empty($filters['date_debut'])) {
    $where[] = "DATE(date_creation) >= :date_debut";
    $params[':date_debut'] = $filters['date_debut'];
}
if (!empty($filters['date_fin'])) {
    $where[] = "DATE(date_creation) <= :date_fin";
    $params[':date_fin'] = $filters['date_fin'];
}

$whereClause = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';
$sql = "SELECT *, TIMESTAMPDIFF(YEAR, date_naissance, CURDATE()) AS age FROM patients $whereClause ORDER BY date_creation DESC";
$stmt = $pdo->prepare($sql);
foreach ($params as $key => $val) {
    $stmt->bindValue($key, $val);
}
$stmt->execute();
$patients = $stmt->fetchAll();

$toastMessage = '';
$toastType = '';

if (isset($_GET['success']) && $_GET['success'] === 'modification') {
    $toastMessage = "Modification du patient réussie.";
    $toastType = 'success';
} elseif (isset($_GET['success']) && $_GET['success'] === 'suppression') {
    $toastMessage = "Patient supprimé avec succès.";
    $toastType = 'success';
} elseif (isset($_GET['error'])) {
    $toastMessage = htmlspecialchars($_GET['error']);
    $toastType = 'error';
}
?>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Liste des Patients</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
  <link rel="stylesheet" href="https://cdn.datatables.net/buttons/2.4.1/css/buttons.bootstrap5.min.css">
  <style>
    .page-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 2rem;
        margin-bottom: 2rem;
    }
    .filter-card {
        background: #f8f9fa;
        border-radius: 10px;
        padding: 1.25rem;
        margin-bottom: 2rem;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    /* ▼▼▼ Réduction uniquement des CHAMPS de filtres ▼▼▼ */
    .filter-card .form-label {
        font-size: .85rem;
        margin-bottom: .25rem;
    }
    .filter-card .form-control,
    .filter-card .form-select {
        font-size: .875rem;
        padding: .25rem .5rem;
        line-height: 1.2;
        height: auto;
    }
    .filter-card .btn {
        font-size: .875rem;
        padding: .375rem .5rem;
    }
    /* Sexe plus étroit */
    .filter-sexe { max-width: 140px; } /* 🆕 largeur réduite */
    .filter-medecin { min-width: 220px; } /* un peu de largeur pour les noms */
    /* ▲▲▲ FIN scope filtres ▲▲▲ */

    .table-card {
        background: white;
        border-radius: 10px;
        padding: 1.5rem;
        box-shadow: 0 2px 20px rgba(0,0,0,0.1);
    }
    .table-responsive {
        overflow-x: auto;
        -webkit-overflow-scrolling: touch;
    }
    @media (max-width: 768px) {
        table.dataTable td, table.dataTable th { white-space: nowrap; }
        .dataTables_wrapper .dataTables_length,
        .dataTables_wrapper .dataTables_filter,
        .dataTables_wrapper .dataTables_paginate {
            float: none;
            text-align: center;
        }
    }
  </style>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>
<?php include 'includes/sidebar-medecin.php'; ?>
<?php include 'includes/header.php'; ?>

<div class="pc-container">
  <div class="pcoded-content">
    <div class="page-header">
      <div class="container">
        <h1><i class="fas fa-users me-2"></i> Liste des Patients</h1>
      </div>
    </div>

    <div class="container">
      <div class="filter-card">
        <form method="GET" class="row g-2 align-items-end">
          <div class="col-md-3">
            <label class="form-label">Nom / Prénom</label>
            <input type="text" name="nom_patient" class="form-control form-control-sm" value="<?= htmlspecialchars($filters['nom_patient']) ?>">
          </div>

          <!-- 🆕 Filtre Médecin -->
          <div class="col-md-3">
            <label class="form-label">Trier par médecin</label>
            <select name="medecin" class="form-select form-select-sm filter-medecin">
              <option value="<?= $current_medecin_id ?>" <?= ($filters['medecin'] == (string)$current_medecin_id) ? 'selected' : '' ?>>
                Mes patients (<?= htmlspecialchars($_SESSION['user']['username'] ?? 'moi') ?>)
              </option>
              <option value="all" <?= ($filters['medecin'] === 'all') ? 'selected' : '' ?>>Tous les médecins</option>
              <?php foreach ($medecins as $m): ?>
                <option value="<?= $m['id_utilisateur'] ?>" <?= ($filters['medecin'] == (string)$m['id_utilisateur']) ? 'selected' : '' ?>>
                  <?= htmlspecialchars($m['username']) ?>
                </option>
              <?php endforeach; ?>
            </select>
          </div>

          <div class="col-md-2">
            <label class="form-label">Sexe</label>
            <select name="sexe" class="form-select form-select-sm filter-sexe">
              <option value="">Tous</option>
              <option value="Homme" <?= $filters['sexe'] === 'Homme' ? 'selected' : '' ?>>Homme</option>
              <option value="Femme" <?= $filters['sexe'] === 'Femme' ? 'selected' : '' ?>>Femme</option>
            </select>
          </div>

          <div class="col-md-1">
            <label class="form-label">Âge Min</label>
            <input type="number" name="age_min" class="form-control form-control-sm" value="<?= $filters['age_min'] ?>">
          </div>
          <div class="col-md-1">
            <label class="form-label">Âge Max</label>
            <input type="number" name="age_max" class="form-control form-control-sm" value="<?= $filters['age_max'] ?>">
          </div>
          <div class="col-md-1">
            <label class="form-label">Taille Min</label>
            <input type="number" name="taille_min" step="0.01" class="form-control form-control-sm" value="<?= $filters['taille_min'] ?>">
          </div>
          <div class="col-md-1">
            <label class="form-label">Taille Max</label>
            <input type="number" name="taille_max" step="0.01" class="form-control form-control-sm" value="<?= $filters['taille_max'] ?>">
          </div>
          <div class="col-md-1">
            <label class="form-label">Poids Min</label>
            <input type="number" name="poids_min" step="0.01" class="form-control form-control-sm" value="<?= $filters['poids_min'] ?>">
          </div>
          <div class="col-md-1">
            <label class="form-label">Poids Max</label>
            <input type="number" name="poids_max" step="0.01" class="form-control form-control-sm" value="<?= $filters['poids_max'] ?>">
          </div>
          <div class="col-md-2">
            <label class="form-label">Date Début</label>
            <input type="date" name="date_debut" class="form-control form-control-sm" value="<?= $filters['date_debut'] ?>">
          </div>
          <div class="col-md-2">
            <label class="form-label">Date Fin</label>
            <input type="date" name="date_fin" class="form-control form-control-sm" value="<?= $filters['date_fin'] ?>">
          </div>
          <div class="col-md-2">
            <button type="submit" class="btn btn-primary btn-sm w-100">Filtrer</button>
          </div>
        </form>
      </div>

      <div class="table-card">
        <div class="table-responsive">
          <table id="tablePatients" class="table table-bordered table-hover w-100">
            <thead class="table-light">
              <tr>
                <th>ID</th>
                <th>Nom</th>
                <th>Prénom</th>
                <th>Sexe</th>
                <th>Âge</th>
                <th>Date Naissance</th>
                <th>Taille</th>
                <th>Poids</th>
                <th>Date Création</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($patients as $p): ?>
              <tr>
                <td><?= $p['id_patient'] ?></td>
                <td><?= htmlspecialchars($p['nom']) ?></td>
                <td><?= htmlspecialchars($p['prenom']) ?></td>
                <td><?= $p['sexe'] ?></td>
                <td><?= $p['age'] ?> ans</td>
                <td><?= date('d/m/Y', strtotime($p['date_naissance'])) ?></td>
                <td><?= $p['taille'] ?> cm</td>
                <td><?= $p['poids'] ?> kg</td>
                <td><?= date('d/m/Y', strtotime($p['date_creation'])) ?></td>
                <td>
                  <a href="details_patient.php?id=<?= $p['id_patient'] ?>" class="btn btn-sm btn-success"><i class="ti ti-eye"></i></a>
                  <a href="modifier_patient.php?id=<?= $p['id_patient'] ?>" class="btn btn-sm btn-primary"><i class="ti ti-edit"></i></a>
                  <a href="supprimer_patient.php?id=<?= $p['id_patient'] ?>" class="btn btn-sm btn-danger" onclick="return confirm('Confirmer la suppression ?');"><i class="ti ti-trash"></i></a>
                </td>
              </tr>
              <?php endforeach; ?>
              <script>
<?php if (!empty($toastMessage)): ?>
Swal.fire({
    toast: true,
    position: 'top-end',
    icon: '<?= $toastType ?>',
    title: '<?= $toastMessage ?>',
    showConfirmButton: false,
    timer: 3000,
    timerProgressBar: true,
    background: '#333',
    color: '#fff',
});
<?php endif; ?>
</script>

            </tbody>
          </table>
        </div>
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
  $(document).ready(function () {
    $('#tablePatients').DataTable({
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
  });
</script>
<?php include 'includes/footer.php'; ?>
</body>
</html>
