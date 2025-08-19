<?php 
session_start(); 

require_once 'db.php';
require_once 'includes/activity_logger.php';
include 'includes/auto_track.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'A acceder au tableau de bord');

// Vérifier que l'utilisateur est bien un médecin principal
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

// 🆕 Récupération (puis purge) du message de bienvenue
$__welcome = $_SESSION['welcome_message'] ?? '';
if (!empty($__welcome)) { unset($_SESSION['welcome_message']); }

// Récupération des dates de filtre
if (isset($_GET['reset'])) {
    // Si le bouton Réinitialiser est cliqué
    $date_debut = date('Y-m-01');
    $date_fin = date('Y-m-d');
} else {
    $date_debut = isset($_GET['date_debut']) ? $_GET['date_debut'] : date('Y-m-01');
    $date_fin = isset($_GET['date_fin']) ? $_GET['date_fin'] : date('Y-m-d');
}

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<!-- 🆕 Toast de bienvenue -->
<div class="toast-container position-fixed top-0 end-0 p-3">
  <?php if (!empty($__welcome)): ?>
  <div id="welcomeToast" class="toast align-items-center text-bg-primary border-0" role="alert" aria-live="assertive" aria-atomic="true">
    <div class="d-flex">
      <div class="toast-body"><?= htmlspecialchars($__welcome) ?></div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Fermer"></button>
    </div>
  </div>
  <?php endif; ?>
</div>

<!-- CSS personnalisé pour le dashboard -->
<style>
    
  input[type="date"] {
    color: #000 !important;
}
.page-header {
            background: linear-gradient(135deg, #bdb3f7ff 0%, #764ba2 100%);
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
        }
        
.filter-card {
    background: linear-gradient(135deg, #bdb3f7ff 0%, #764ba2 100%);
    color: white;
}

.chart-container {
    position: relative;
    height: 300px;
}

/* Styles pour les cartes compactes */
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

<!-- Contenu principal -->
<div class="pc-container">
    <div class="pc-content">
        <div class="page-header">
            <div class="page-block">
                <div class="page-header-title">
                    <h5 class="mb-0 font-medium">
                        <i class="fas fa-chart-line me-2"></i>Tableau de bord médical
                    </h5>
                </div>
                <ul class="breadcrumb">

                    <li class="breadcrumb-item active"> </li>
                </ul>
            </div>
        </div>

       
<!-- Filtre Final Ultra-Pro avec déclenchement auto -->
<div class="mb-6 max-w-6xl mx-auto">
  <div class="bg-white rounded-lg shadow-sm p-4">
    <form id="filterForm" method="GET" class="flex flex-wrap md:flex-nowrap items-center justify-between gap-4">

      <!-- Bloc dates + actions -->
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

        <!-- Boutons -->
        <button type="submit"
                class="bg-blue-600 hover:bg-blue-700 text-white text-sm px-3 py-1 rounded-md ml-3">
          <i class="fas fa-filter mr-1"></i>Filtrer
        </button>
        <button type="submit" name="reset" value="1"
                class="border text-sm px-3 py-1 rounded-md text-gray-700 hover:bg-gray-100">
          <i class="fas fa-redo mr-1"></i>Réinitialiser
        </button>
      </div>

      <!-- Boutons de raccourcis -->
      <div class="flex flex-wrap gap-2 mt-2 md:mt-0">
        <button type="button" class="text-sm bg-gray-100 hover:bg-gray-200 px-3 py-1 rounded-md"
                onclick="setQuickRange('today')">Aujourd’hui</button>
        <button type="button" class="text-sm bg-gray-100 hover:bg-gray-200 px-3 py-1 rounded-md"
                onclick="setQuickRange('7days')">7 derniers jours</button>
        <button type="button" class="text-sm bg-gray-100 hover:bg-gray-200 px-3 py-1 rounded-md"
                onclick="setQuickRange('thisMonth')">Ce mois</button>
        <button type="button" class="text-sm bg-gray-100 hover:bg-gray-200 px-3 py-1 rounded-md"
                onclick="setQuickRange('lastMonth')">Mois précédent</button>
      </div>
    </form>
  </div>
</div>
<script>
// Remplit les dates et soumet automatiquement
function setQuickRange(range) {
  const today = new Date();
  let start, end;

  switch (range) {
    case 'today':
      start = end = today;
      break;
    case '7days':
      end = today;
      start = new Date(today);
      start.setDate(today.getDate() - 6);
      break;
    case 'thisMonth':
      start = new Date(today.getFullYear(), today.getMonth(), 1);
      end = new Date(today.getFullYear(), today.getMonth() + 1, 0);
      break;
    case 'lastMonth':
      start = new Date(today.getFullYear(), today.getMonth() - 1, 1);
      end = new Date(today.getFullYear(), today.getMonth(), 0);
      break;
  }

  document.getElementById('date_debut').value = start.toISOString().split('T')[0];
  document.getElementById('date_fin').value = end.toISOString().split('T')[0];

  document.getElementById('filterForm').submit();
}

// Empêche soumission si date incorrecte
document.getElementById('filterForm').addEventListener('submit', function (e) {
  const debut = document.getElementById('date_debut').value;
  const fin = document.getElementById('date_fin').value;
  if (debut && fin && debut > fin) {
    e.preventDefault();
    alert("La date de début ne peut pas être postérieure à la date de fin.");
  }
});
</script>


        <!-- Statistiques avec Tailwind CSS - 2 lignes -->
        <div class="mb-6">
            <!-- PREMIÈRE LIGNE : 4 cartes principales -->
            <div class="grid grid-cols-4 gap-4 mb-4">
                
                <!-- Patients consultés -->
                <div class="stat-card bg-white p-4 border-l-4 border-blue-500">
                    <div class="flex items-center">
                        <div class="p-2 bg-blue-100 rounded-lg mr-3">
                            <i class="fas fa-users text-blue-600"></i>
                        </div>
                        <div class="flex-1">
                            <p class="stat-title">Patients consultés</p>
                            <p class="stat-number text-blue-600">
                                <?php 
                                $stmt = $pdo->prepare("SELECT COUNT(DISTINCT id_patient) FROM consultations 
                                                      WHERE DATE(date_consultation) BETWEEN ? AND ?");
                                $stmt->execute([$date_debut, $date_fin]);
                                echo $stmt->fetchColumn(); 
                                ?>
                            </p>
                            <p class="stat-subtitle">Période sélectionnée</p>
                        </div>
                    </div>
                </div>

                <!-- Consultations totales -->
                <div class="stat-card bg-white p-4 border-l-4 border-green-500">
                    <div class="flex items-center">
                        <div class="p-2 bg-green-100 rounded-lg mr-3">
                            <i class="fas fa-stethoscope text-green-600"></i>
                        </div>
                        <div class="flex-1">
                            <p class="stat-title">Consultations</p>
                            <p class="stat-number text-green-600">
                                <?php 
                                $stmt = $pdo->prepare("SELECT COUNT(*) FROM consultations 
                                                      WHERE DATE(date_consultation) BETWEEN ? AND ?");
                                $stmt->execute([$date_debut, $date_fin]);
                                echo $stmt->fetchColumn(); 
                                ?>
                            </p>
                            <p class="stat-subtitle">Total période</p>
                        </div>
                    </div>
                </div>

                <!-- Ordonnances émises -->
                <div class="stat-card bg-white p-4 border-l-4 border-yellow-500">
                    <div class="flex items-center">
                        <div class="p-2 bg-yellow-100 rounded-lg mr-3">
                            <i class="fas fa-prescription-bottle-alt text-yellow-600"></i>
                        </div>
                        <div class="flex-1">
                            <p class="stat-title">Ordonnances</p>
                            <p class="stat-number text-yellow-600">
                                <?php 
                                $stmt = $pdo->prepare("SELECT COUNT(*) FROM ordonnances 
                                                      WHERE DATE(date_ordonnance) BETWEEN ? AND ?");
                                $stmt->execute([$date_debut, $date_fin]);
                                echo $stmt->fetchColumn(); 
                                ?>
                            </p>
                            <p class="stat-subtitle">Émises</p>
                        </div>
                    </div>
                </div>

                <!-- Moyenne consultations/jour -->
                <div class="stat-card bg-white p-4 border-l-4 border-indigo-500">
                    <div class="flex items-center">
                        <div class="p-2 bg-indigo-100 rounded-lg mr-3">
                            <i class="fas fa-chart-line text-indigo-600"></i>
                        </div>
                        <div class="flex-1">
                            <p class="stat-title">Moyenne/jour</p>
                            <p class="stat-number text-indigo-600">
                                <?php 
                                $stmt = $pdo->prepare("SELECT COUNT(*) FROM consultations 
                                                      WHERE DATE(date_consultation) BETWEEN ? AND ?");
                                $stmt->execute([$date_debut, $date_fin]);
                                $total_consultations = $stmt->fetchColumn();

                                $diff = (new DateTime($date_fin))->diff(new DateTime($date_debut))->days + 1;
                                $moyenne = $diff > 0 ? round($total_consultations / $diff, 1) : 0;
                                echo $moyenne;
                                ?>
                            </p>
                            <p class="stat-subtitle">Consultations</p>
                        </div>
                    </div>
                </div>
                 <!-- Consultations programmées -->
               
            </div>

            <!-- DEUXIÈME LIGNE : 3 cartes de statut -->
<div class="grid grid-cols-3 gap-4">
    <!-- Consultations programmées -->
    <div class="stat-card bg-white p-4 border-l-4 border-green-500">
        <div class="flex items-center">
            <div class="p-2 bg-green-100 rounded-lg mr-3">
                <i class="fas fa-calendar-check text-green-600"></i>
            </div>
            <div class="flex-1 text-left">
                <p class="stat-title">Consultations programmées</p>
                <p class="stat-number text-green-600">
                    <?php 
                    $stmt = $pdo->prepare("SELECT COUNT(*) FROM consultations 
                                          WHERE statut = 'programmee' 
                                          AND DATE(date_consultation) BETWEEN ? AND ?");
                    $stmt->execute([$date_debut, $date_fin]);
                    echo $stmt->fetchColumn(); 
                    ?>
                </p>
                <p class="stat-subtitle"></p>
            </div>
        </div>
    </div>

    <!-- Consultations en cours -->
    <div class="stat-card bg-white p-4 border-l-4 border-yellow-500">
        <div class="flex items-center">
            <div class="p-2 bg-yellow-100 rounded-lg mr-3">
                <i class="fas fa-spinner text-yellow-600"></i>
            </div>
            <div class="flex-1 text-left">
                <p class="stat-title">Consultations en cours</p>
                <p class="stat-number text-yellow-600">
                    <?php 
                    $stmt = $pdo->prepare("SELECT COUNT(*) FROM consultations 
                                          WHERE statut = 'en_cours' 
                                          AND DATE(date_consultation) BETWEEN ? AND ?");
                    $stmt->execute([$date_debut, $date_fin]);
                    echo $stmt->fetchColumn(); 
                    ?>
                </p>
                <p class="stat-subtitle"> </p>
            </div>
        </div>
    </div>

    <!-- Consultations terminées -->
    <div class="stat-card bg-white p-4 border-l-4 border-green-500">
        <div class="flex items-center">
            <div class="p-2 bg-green-100 rounded-lg mr-3">
                <i class="fas fa-check-circle text-green-600"></i>
            </div>
            <div class="flex-1 text-left">
                <p class="stat-title">Consultations terminées</p>
                <p class="stat-number text-green-600">
                    <?php 
                    $stmt = $pdo->prepare("SELECT COUNT(*) FROM consultations 
                                          WHERE statut = 'terminee' 
                                          AND DATE(date_consultation) BETWEEN ? AND ?");
                    $stmt->execute([$date_debut, $date_fin]);
                    echo $stmt->fetchColumn(); 
                    ?>
                </p>
                <p class="stat-subtitle"> </p>
            </div>
        </div>
    </div>
</div>

        </div>

        <!-- Graphique des consultations par jour -->
        <div class="row">
            <div class="col-md-12 mb-3">
                <div class="card h-100">
                    <div class="card-header bg-primary text-white">
                        <h6 class="mb-0">
                            <i class="fas fa-chart-bar me-2"></i>Évolution des consultations
                        </h6>
                    </div>
                    <div class="card-body">
                        <div class="chart-container">
                            <canvas id="consultationsChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Script pour le graphique -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Données pour le graphique des consultations par jour
    <?php
    $stmt = $pdo->prepare("SELECT DATE(date_consultation) as date, COUNT(*) as count 
                          FROM consultations 
                          WHERE DATE(date_consultation) BETWEEN ? AND ?
                          GROUP BY DATE(date_consultation)
                          ORDER BY date");
    $stmt->execute([$date_debut, $date_fin]);
    $chart_data = $stmt->fetchAll();
    
    $dates = [];
    $counts = [];
    foreach ($chart_data as $data) {
        $dates[] = date('d/m', strtotime($data['date']));
        $counts[] = $data['count'];
    }
    ?>
    
    const ctx = document.getElementById('consultationsChart').getContext('2d');
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: <?= json_encode($dates) ?>,
            datasets: [{
                label: 'Consultations par jour',
                data: <?= json_encode($counts) ?>,
                borderColor: 'rgb(75, 192, 192)',
                backgroundColor: 'rgba(75, 192, 192, 0.2)',
                tension: 0.4,
                fill: true
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
});
</script>

<?php include 'includes/footer.php'; ?>

<!-- 🆕 Script d’affichage du toast -->
<script>
document.addEventListener("DOMContentLoaded", function () {
  const el = document.getElementById('welcomeToast');
  if (el && typeof bootstrap !== 'undefined') {
    const toast = new bootstrap.Toast(el, { delay: 3500 });
    toast.show();
  }
});
</script>
