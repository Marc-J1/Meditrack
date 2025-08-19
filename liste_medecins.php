<?php
session_start();

require_once 'db.php';
include 'includes/auto_track.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'Accès à la liste des utilisateurs');

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'admin') {
    header("Location: login.php");
    exit();
}

// === GESTION DES FILTRES ===
$filters = [
    'username' => isset($_GET['username']) ? trim($_GET['username']) : '',
    'date_debut' => isset($_GET['date_debut']) ? $_GET['date_debut'] : '',
    'date_fin' => isset($_GET['date_fin']) ? $_GET['date_fin'] : '',
    'statut' => isset($_GET['statut']) ? $_GET['statut'] : '',
];

$where = [];
$params = [];

if (!empty($filters['username'])) {
    $where[] = "username LIKE :username";
    $params[':username'] = "%{$filters['username']}%";
}
if (!empty($filters['date_debut'])) {
    $where[] = "DATE(date_creation) >= :date_debut";
    $params[':date_debut'] = $filters['date_debut'];
}
if (!empty($filters['date_fin'])) {
    $where[] = "DATE(date_creation) <= :date_fin";
    $params[':date_fin'] = $filters['date_fin'];
}
if (!empty($filters['statut'])) {
    $where[] = "statut = :statut";
    $params[':statut'] = $filters['statut'];
}

$whereClause = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';
$sql = "SELECT * FROM users $whereClause ORDER BY date_creation DESC";
$stmt = $pdo->prepare($sql);
foreach ($params as $key => $val) {
    $stmt->bindValue($key, $val);
}
$stmt->execute();
$users = $stmt->fetchAll();
?>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Liste des Utilisateurs</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
  <link rel="stylesheet" href="https://cdn.datatables.net/buttons/2.4.1/css/buttons.bootstrap5.min.css">
  <style>
    .page-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 2rem; margin-bottom: 2rem; }
    .filter-card { background: #f8f9fa; border-radius: 10px; padding: 1.5rem; margin-bottom: 2rem; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    .table-card { background: white; border-radius: 10px; padding: 1.5rem; box-shadow: 0 2px 20px rgba(0,0,0,0.1); }
  </style>
</head>
<body>

<!-- ✅ TOAST MESSAGE -->
<?php
$type_message = '';
$contenu_message = '';

if (isset($_GET['success'])) {
    $type_message = 'success';
    $contenu_message = htmlspecialchars($_GET['success']);
} elseif (isset($_GET['error'])) {
    $type_message = 'danger';
    $contenu_message = htmlspecialchars($_GET['error']);
}
?>

<?php if (!empty($contenu_message)): ?>
<div class="toast-container position-fixed top-0 end-0 p-3">
  <div id="liveToast" class="toast align-items-center text-bg-<?= $type_message ?> border-0 show" role="alert" aria-live="assertive" aria-atomic="true">
    <div class="d-flex">
      <div class="toast-body"><?= $contenu_message ?></div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Fermer"></button>
    </div>
  </div>
</div>
<script>
document.addEventListener("DOMContentLoaded", function () {
    const toastEl = document.getElementById('liveToast');
    if (toastEl) {
        const toast = new bootstrap.Toast(toastEl, { delay: 3000 });
        toast.show();
    }
});
</script>
<?php endif; ?>

<!-- CONTENU -->
<?php include 'includes/sidebar-admin.php'; ?>
<?php include 'includes/header.php'; ?>

<div class="pc-container">
  <div class="pc-content">
    <div class="page-header">
      <div class="container">
        <h1><i class="fas fa-user-md me-2"></i> Liste des Utilisateurs</h1>
      </div>
    </div>

    <div class="container">
      <div class="filter-card">
        <form method="GET" class="row g-3">
          <div class="col-md-4">
            <label class="form-label">Nom d'utilisateur</label>
            <input type="text" name="username" class="form-control" value="<?= htmlspecialchars($filters['username']) ?>">
          </div>
          <div class="col-md-3">
            <label class="form-label">Statut</label>
            <select name="statut" class="form-select">
              <option value="">Tous</option>
              <option value="principal" <?= $filters['statut'] === 'principal' ? 'selected' : '' ?>>Principal</option>
              <option value="interimaire" <?= $filters['statut'] === 'interimaire' ? 'selected' : '' ?>>Intérimaire</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label">Date début</label>
            <input type="date" name="date_debut" class="form-control" value="<?= $filters['date_debut'] ?>">
          </div>
          <div class="col-md-2">
            <label class="form-label">Date fin</label>
            <input type="date" name="date_fin" class="form-control" value="<?= $filters['date_fin'] ?>">
          </div>
          <div class="col-md-1 d-flex align-items-end">
            <button type="submit" class="btn btn-primary w-100">Filtrer</button>
          </div>
        </form>
      </div>

      <div class="table-card">
        <div class="table-responsive">
          <table id="table-medecins" class="table table-bordered table-hover w-100">
            <thead class="table-light">
              <tr>
                <th>ID</th>
                <th>Nom</th>
                <th>Identifiant</th> <!-- ✅ Ajout colonne -->
                <th>Téléphone</th>
                <th>Adresse</th>
                <th>Email</th>
                <th>Rôle</th>
                <th>Statut</th>
                <th>Date de Création</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($users as $user): ?>
              <tr>
                <td><?= $user['id_utilisateur'] ?></td>
                <td><?= htmlspecialchars($user['username']) ?></td>
                <td><?= htmlspecialchars($user['identifiant']) ?></td> <!-- ✅ Ajout affichage -->
                <td><?= $user['phone_number'] ?></td>
                <td><?= $user['address'] ?></td>
                <td><?= $user['mail'] ?></td>
                <td><?= $user['role'] ?></td>
                <td><?= $user['statut'] ?></td>
                <td><?= date('d/m/Y', strtotime($user['date_creation'])) ?></td>
                <td>
                  <a href="modifier_medecin.php?id=<?= $user['id_utilisateur'] ?>" class="btn btn-sm btn-primary"><i class="ti ti-edit"></i></a>
                  <a href="supprimer_medecin.php?id=<?= $user['id_utilisateur'] ?>" class="btn btn-sm btn-danger" onclick="return confirm('Confirmer la suppression ?');"><i class="ti ti-trash"></i></a>
                </td>
              </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- JS -->
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
    $('#table-medecins').DataTable({
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
