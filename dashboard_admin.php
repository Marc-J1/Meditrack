<?php
session_start();
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'admin') {
    header("Location: login.php");
    exit();
}

require_once 'db.php';
include 'includes/header.php';
include 'includes/sidebar-admin.php';

if (isset($_GET['reset'])) {
    $date_debut = date('Y-m-01');
    $date_fin = date('Y-m-d');
} else {
    $date_debut = $_GET['date_debut'] ?? date('Y-m-01');
    $date_fin = $_GET['date_fin'] ?? date('Y-m-d');
}

$totalMedecins = $pdo->query("SELECT COUNT(*) FROM medecins")->fetchColumn();
$totalUsers = $pdo->query("SELECT COUNT(*) FROM users")->fetchColumn();
$stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE DATE(date_creation) BETWEEN ? AND ?");
$stmt->execute([$date_debut, $date_fin]);
$medecinsAjoutes = $stmt->fetchColumn();
$stmt = $pdo->prepare("SELECT * FROM users WHERE DATE(date_creation) BETWEEN ? AND ? ORDER BY date_creation DESC");
$stmt->execute([$date_debut, $date_fin]);
$listeMedecins = $stmt->fetchAll();
?>

<style>
input[type="date"] {
    color: #000 !important;
}
.stat-card {
    transition: all 0.3s ease;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
.stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}
.stat-number {
    font-size: 1.75rem;
    font-weight: 700;
    line-height: 1;
}
.stat-title {
    font-size: 0.875rem;
    font-weight: 500;
    color: #6b7280;
}
.stat-subtitle {
    font-size: 0.75rem;
    color: #9ca3af;
}
</style>

<div class="pc-container">
  <div class="pc-content">
    <div class="page-header">
      <div class="page-block">
        <div class="page-header-title">
          <h5 class="mb-0 font-medium">
            <i class="fas fa-chart-line me-2"></i>Tableau de bord administrateur
          </h5>
        </div>
      </div>
    </div>

    <!-- Filtre de dates -->
    <div class="mb-6 max-w-6xl mx-auto">
      <div class="bg-white rounded-lg shadow-sm p-4">
        <form id="filterForm" method="GET" class="flex flex-wrap md:flex-nowrap items-center justify-between gap-4">
          <div class="flex flex-wrap items-center gap-2">
            <label for="date_debut" class="text-sm font-medium text-gray-600 flex items-center">
              <i class="fas fa-calendar-alt text-blue-500 mr-1"></i>Du
            </label>
            <input type="date" id="date_debut" name="date_debut"
                   class="form-input text-sm border rounded-md px-2 py-1 w-40"
                   value="<?= htmlspecialchars($date_debut) ?>" required>

            <label for="date_fin" class="text-sm font-medium text-gray-600 flex items-center ml-3">
              <i class="fas fa-calendar-alt text-blue-500 mr-1"></i>Au
            </label>
            <input type="date" id="date_fin" name="date_fin"
                   class="form-input text-sm border rounded-md px-2 py-1 w-40"
                   value="<?= htmlspecialchars($date_fin) ?>" required>

            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white text-sm px-3 py-1 rounded-md ml-3">
              <i class="fas fa-filter mr-1"></i>Filtrer
            </button>
            <button type="submit" name="reset" value="1"
                    class="border text-sm px-3 py-1 rounded-md text-gray-700 hover:bg-gray-100">
              <i class="fas fa-redo mr-1"></i>Réinitialiser
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Statistiques -->
    <div class="grid grid-cols-3 gap-4 mb-6">
      <div class="stat-card bg-white p-4 border-l-4 border-blue-500">
        <div class="flex items-center">
          <div class="p-2 bg-blue-100 rounded-lg mr-3">
            <i class="fas fa-user-md text-blue-600"></i>
          </div>
          <div class="flex-1">
            <p class="stat-title">Médecins</p>
            <p class="stat-number text-blue-600"><?= $totalMedecins ?></p>
            <p class="stat-subtitle">Enregistrés</p>
          </div>
        </div>
      </div>

      <div class="stat-card bg-white p-4 border-l-4 border-green-500">
        <div class="flex items-center">
          <div class="p-2 bg-green-100 rounded-lg mr-3">
            <i class="fas fa-users text-green-600"></i>
          </div>
          <div class="flex-1">
            <p class="stat-title">Utilisateurs</p>
            <p class="stat-number text-green-600"><?= $totalUsers ?></p>
            <p class="stat-subtitle">Total</p>
          </div>
        </div>
      </div>

      <div class="stat-card bg-white p-4 border-l-4 border-yellow-500">
        <div class="flex items-center">
          <div class="p-2 bg-yellow-100 rounded-lg mr-3">
            <i class="fas fa-calendar-plus text-yellow-600"></i>
          </div>
          <div class="flex-1">
            <p class="stat-title">Médecins ajoutés</p>
            <p class="stat-number text-yellow-600"><?= $medecinsAjoutes ?></p>
            <p class="stat-subtitle">du <?= date('d/m/Y', strtotime($date_debut)) ?> au <?= date('d/m/Y', strtotime($date_fin)) ?></p>
          </div>
        </div>
      </div>
    </div>

    <!-- Tableau des médecins -->
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h6 class="mb-0">
          <i class="fas fa-users-medical me-2"></i>Médecins ajoutés dans la période
        </h6>
      </div>
      <div class="card-body">
        <?php if ($listeMedecins): ?>
          <div class="table-responsive">
            <table class="table table-hover">
              <thead class="table-light">
                <tr>
                  <th>Nom</th>
                  <th>Téléphone</th>
                  <th>Adresse</th>
                  <th>Statut</th>
                  <th>Date</th>
                </tr>
              </thead>
              <tbody>
                <?php foreach ($listeMedecins as $medecin): ?>
                  <tr>
                    <td><?= htmlspecialchars($medecin['username']) ?></td>
                    <td><?= htmlspecialchars($medecin['phone_number']) ?></td>
                    <td><?= htmlspecialchars($medecin['address']) ?></td>
                    <td><span class="badge <?= $medecin['statut'] === 'principal' ? 'bg-success' : 'bg-secondary' ?>"><?= htmlspecialchars($medecin['statut']) ?></span></td>
                    <td><?= date('d/m/Y H:i', strtotime($medecin['date_creation'])) ?></td>
                  </tr>
                <?php endforeach; ?>
              </tbody>
            </table>
          </div>
        <?php else: ?>
          <p class="text-muted">Aucun médecin trouvé pour cette période.</p>
        <?php endif; ?>
      </div>
    </div>

    <div class="mt-4">
      <p>Bienvenue <strong><?= htmlspecialchars($_SESSION['user']['username']) ?></strong> sur votre tableau de bord.</p>
    </div>
  </div>
</div>

<?php include 'includes/footer.php'; ?>