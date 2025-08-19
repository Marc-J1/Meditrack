<?php
session_start();
require_once 'db.php';

// Vérification de l'accès admin uniquement
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'admin') {
    header("Location: login.php");
    exit();
}

// Configuration des types d'observabilité
$observability_types = [
    'dashboard' => [
        'title' => 'Vue d\'ensemble',
        'icon' => 'fas fa-tachometer-alt',
        'description' => 'Statistiques générales et activité en temps réel'
    ],
    'historique_utilisateurs' => [
        'title' => 'Historique utilisateurs',
        'icon' => 'fas fa-user-edit',
        'description' => 'Actions sur les comptes médecins'
    ],
    'activite_globale' => [
        'title' => 'Activité globale',
        'icon' => 'fas fa-chart-line',
        'description' => 'Toutes les actions de l\'application'
    ]
];

// Type par défaut
$current_type = isset($_GET['type']) && isset($observability_types[$_GET['type']]) ? $_GET['type'] : 'dashboard';

// Récupération des statistiques générales pour le dashboard
if ($current_type === 'dashboard') {
    // Statistiques générales
    $stats_queries = [
        'total_users' => "SELECT COUNT(*) FROM users WHERE role = 'medecin'",
        'actions_today' => "SELECT COUNT(*) FROM user_activity WHERE DATE(date_action) = CURDATE()",
        'patients_added_today' => "SELECT COUNT(*) FROM historique_patients WHERE DATE(date_action) = CURDATE() AND action_type = 'ajout'",
        'users_modified_today' => "SELECT COUNT(*) FROM historique_utilisateurs WHERE DATE(date_action) = CURDATE()"
    ];
    
    $stats = [];
    foreach ($stats_queries as $key => $query) {
        $stmt = $pdo->prepare($query);
        $stmt->execute();
        $stats[$key] = $stmt->fetchColumn();
    }
    
    // Activité récente (dernières 24h) - Format modifié
   // Activité récente (dernières 24h) — dédoublonnée
// Activité récente (dernières 24h) — fusion user_activity + historique_utilisateurs
$recent_activity_query = "
    SELECT 
        ua.username,
        ua.action_type,
        ua.details_action,
        ua.date_action AS last_date,
        ua.adresse_ip
    FROM user_activity ua
    WHERE ua.date_action >= DATE_SUB(NOW(), INTERVAL 24 HOUR)

    UNION ALL

    SELECT
        COALESCE(h.nom_utilisateur_auteur, u.username) AS username,
        h.action_type,
        h.details_action,
        h.date_action AS last_date,
        h.adresse_ip
    FROM historique_utilisateurs h
    LEFT JOIN users u ON u.id_utilisateur = h.id_utilisateur_auteur
    WHERE h.date_action >= DATE_SUB(NOW(), INTERVAL 24 HOUR)

    ORDER BY last_date DESC
    LIMIT 20
";
$stmt_recent = $pdo->prepare($recent_activity_query);
$stmt_recent->execute();
$recent_activities = $stmt_recent->fetchAll(PDO::FETCH_ASSOC);

$stmt_recent = $pdo->prepare($recent_activity_query);
$stmt_recent->execute();
$recent_activities = $stmt_recent->fetchAll(PDO::FETCH_ASSOC);

}

// Récupération des utilisateurs pour les filtres
$query_users = "SELECT id_utilisateur, username FROM users WHERE role = 'medecin' ORDER BY username";
$stmt_users = $pdo->prepare($query_users);
$stmt_users->execute();
$users_list = $stmt_users->fetchAll(PDO::FETCH_ASSOC);

function badgeClassForAction($t) {
    $t = strtolower(trim($t));
    return match ($t) {
        'ajout','creation'        => 'action-ajout',
        'modification','update'   => 'action-modification',
        'suppression','delete'    => 'action-suppression',
        'connexion','login'       => 'action-connexion',
        'consultation','view'     => 'action-consultation',
        default                   => 'bg-secondary'
    };
}

// Libellés clairs pour les actions
function libelleAction($type) {
    $map = [
        'consultation'          => 'Consultation de données',
        'ajout'                 => 'Ajout d’un élément',
        'creation'              => 'Création d’un élément',
        'modification'          => 'Modification d’un élément',
        'suppression'           => 'Suppression d’un élément',
        'connexion'             => 'Connexion à l’application',
        'deconnexion'           => 'Déconnexion',
        'changement_statut'     => 'Changement de statut',
        'reinitialisation_mdp'  => 'Réinitialisation du mot de passe'
    ];
    return $map[strtolower($type)] ?? ucfirst($type);
}

// Affichage chronologique lisible
function formatDateActivite($date) {
    $ts = strtotime($date);
    if (date('Y-m-d') === date('Y-m-d', $ts)) {
        return '<span class="text-success">'.date('H:i', $ts).' (Aujourd\'hui)</span>';
    } elseif (date('Y-m-d', strtotime('-1 day')) === date('Y-m-d', $ts)) {
        return '<span class="text-primary">'.date('H:i', $ts).' (Hier)</span>';
    }
    return date('d/m/Y H:i', $ts);
}




?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Observabilité Globale - <?= $observability_types[$current_type]['title'] ?></title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- DataTables CSS -->
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.11.5/css/dataTables.bootstrap5.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/responsive/2.2.9/css/responsive.bootstrap5.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/buttons/2.2.2/css/buttons.bootstrap5.min.css">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <style>
        .page-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 2rem; margin-bottom: 2rem; 
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
        }
        
        .nav-tabs-custom {
            border-bottom: 3px solid #667eea;
            margin-bottom: 2rem;
            background: white;
            border-radius: 10px 10px 0 0;
            padding: 0.5rem 1rem 0;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .nav-tabs-custom .nav-link {
            border: none;
            color: #6c757d;
            font-weight: 500;
            padding: 1rem 1.5rem;
            margin: 0 0.25rem;
            border-radius: 10px 10px 0 0;
            position: relative;
            transition: all 0.3s ease;
        }
        
        .nav-tabs-custom .nav-link:hover {
            color: #667eea;
            background-color: #f8f9fa;
        }
        
        .nav-tabs-custom .nav-link.active {
            color: white;
            background: linear-gradient(135deg, #667eea 0%, #667eea 100%);
            border-color: transparent;
            transform: translateY(-2px);
        }
        
        .stats-card {
            background: white;
            border-radius: 15px;
            padding: 1.5rem;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            border-left: 4px solid #667eea;
            transition: transform 0.3s ease;
            margin-bottom: 1.5rem;
        }
        
        .stats-card:hover {
            transform: translateY(-5px);
        }
        
        .stats-number {
            font-size: 2.5rem;
            font-weight: bold;
            color: #667eea;
        }
        
        .stats-label {
            color: #6c757d;
            font-size: 0.9rem;
            text-transform: uppercase;
            font-weight: 500;
        }
        
        .stats-icon {
            font-size: 3rem;
            color: #667eea;
            opacity: 0.3;
        }
        
        .filter-card {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .table-card {
            background: white;
            border-radius: 10px;
            padding: 1.5rem;
            box-shadow: 0 2px 20px rgba(0,0,0,0.1);
        }
        
        .activity-item {
            border-left: 3px solid #ff6b6b;
            padding: 1rem;
            margin-bottom: 1rem;
            background: white;
            border-radius: 0 10px 10px 0;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .activity-time {
            color: #6c757d;
            font-size: 0.8rem;
        }
        
        .loading-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(255,255,255,0.8);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            border-radius: 10px;
        }
        
        .chart-container {
            position: relative;
            height: 400px;
            background: white;
            border-radius: 10px;
            padding: 1rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }
        
        .alert-security {
            border-left: 4px solid #dc3545;
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
        
        .badge-action {
            font-size: 0.7rem;
            padding: 0.3rem 0.6rem;
        }
        
        .action-ajout { background-color: #28a745 !important; }
        .action-modification { background-color: #ffc107 !important; color: #000; }
        .action-suppression { background-color: #dc3545 !important; }
        .action-connexion { background-color: #007bff !important; }
        .action-consultation { background-color: #6f42c1 !important; }

        /* Nouveau style pour l'affichage des activités */
        .activity-user {
            font-weight: bold;
            font-size: 1.1rem;
            color: #333;
            margin-bottom: 0.5rem;
        }
        
        .activity-details {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 0.5rem;
        }
        
        .activity-action {
            font-size: 0.9rem;
            color: #666;
            margin-bottom: 0.3rem;
        }
        
        .activity-description {
            font-size: 0.9rem;
            color: #888;
            flex-grow: 1;
            margin-right: 1rem;
        }
    </style>
</head>

<body>
    <?php include 'includes/sidebar-admin.php'; ?>
    <?php include 'includes/header.php'; ?>

    <div class="pc-container">
        <div class="pcoded-content">
            <div class="page-header">
                <div class="container">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h1 class="mb-0">
                                <i class="fas fa-eye me-3"></i>
                                Observabilité Globale
                            </h1>
                            <p class="mb-0 mt-2 opacity-75">Surveillance complète de l'activité de l'application</p>
                        </div>
                        <div class="col-md-4 text-end">
                            <div class="badge bg-light text-dark fs-6 p-2">
                                <i class="fas fa-shield-alt me-1"></i>
                                Accès Administrateur
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="container-fluid">
                <!-- Onglets de navigation -->
                <ul class="nav nav-tabs nav-tabs-custom" id="observabilityTabs" role="tablist">
                    <?php foreach ($observability_types as $key => $config): ?>
                        <li class="nav-item" role="presentation">
                            <a class="nav-link <?= $key === $current_type ? 'active' : '' ?>" 
                               href="?type=<?= $key ?>"
                               role="tab"
                               title="<?= $config['description'] ?>">
                                <i class="<?= $config['icon'] ?> me-2"></i>
                                <?= $config['title'] ?>
                            </a>
                        </li>
                    <?php endforeach; ?>
                </ul>

                <!-- Contenu des onglets -->
                <div class="tab-content">
                    <?php if ($current_type === 'dashboard'): ?>
                        <!-- Vue d'ensemble -->
                        <div class="row">
                            <!-- Statistiques principales -->
                            <div class="col-lg-8">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="stats-card">
                                            <div class="d-flex justify-content-between align-items-center">
                                                <div>
                                                    <div class="stats-number"><?= $stats['total_users'] ?></div>
                                                    <div class="stats-label">Médecins actifs</div>
                                                </div>
                                                <i class="fas fa-user-md stats-icon"></i>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="stats-card">
                                            <div class="d-flex justify-content-between align-items-center">
                                                <div>
                                                    <div class="stats-number"><?= $stats['actions_today'] ?></div>
                                                    <div class="stats-label">Actions aujourd'hui</div>
                                                </div>
                                                <i class="fas fa-chart-bar stats-icon"></i>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="stats-card">
                                            <div class="d-flex justify-content-between align-items-center">
                                                <div>
                                                    <div class="stats-number"><?= $stats['patients_added_today'] ?></div>
                                                    <div class="stats-label">Nouveaux patients</div>
                                                </div>
                                                <i class="fas fa-user-plus stats-icon"></i>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="stats-card">
                                            <div class="d-flex justify-content-between align-items-center">
                                                <div>
                                                    <div class="stats-number"><?= $stats['users_modified_today'] ?></div>
                                                    <div class="stats-label">Utilisateurs modifiés</div>
                                                </div>
                                                <i class="fas fa-user-edit stats-icon"></i>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Graphique d'activité -->
                            <div class="col-lg-4">
                                <div class="chart-container">
                                    <h5 class="mb-3">Activité des dernières 24h</h5>
                                    <canvas id="activityChart"></canvas>
                                </div>
                            </div>
                        </div>

                        <!-- Activité récente modifiée -->
                        <div class="table-card">
                            <h5 class="mb-3">
                                <i class="fas fa-clock me-2"></i>
                                Activité récente (24h)
                            </h5>
                            <div class="row">
  <?php foreach ($recent_activities as $activity): ?>
    <?php $badge = badgeClassForAction($activity['action_type']);
     ?>
    
    <div class="col-md-6">
      <div class="activity-item">
        <div class="activity-user">
          <?= htmlspecialchars($activity['username']) ?>
        </div>

        <div class="activity-action">
          <span class="badge badge-action <?= $badge ?>">
           <?= libelleAction($activity['action_type']) ?>
          </span>
        </div>

        <div class="activity-details">
          <div class="activity-description">
            <?= htmlspecialchars($activity['details_action']) ?>
          </div>
          <div class="activity-time text-end">
            <i class="fas fa-clock me-1"></i>
          <?= formatDateActivite($activity['last_date']) ?>
            <?php if (!empty($activity['adresse_ip'])): ?>
              <br>
              <span class="text-muted">
                <i class="fas fa-map-marker-alt me-1"></i>
                <?= htmlspecialchars($activity['adresse_ip']) ?>
              </span>
            <?php endif; ?>
          </div>
        </div>
      </div>
    </div>
  <?php endforeach; ?>
</div>

                        </div>

                    <?php elseif ($current_type === 'historique_utilisateurs'): ?>
                        <!-- Historique des utilisateurs -->
                        <div class="filter-card">
                            <h5 class="mb-3">
                                <i class="fas fa-filter me-2"></i>
                                Filtres de recherche - Historique des utilisateurs
                            </h5>
                            <div class="row">
                                <div class="col-md-3">
                                    <label for="filter_date_debut_users" class="form-label">Date début</label>
                                    <input type="date" class="form-control" id="filter_date_debut_users">
                                </div>
                                <div class="col-md-3">
                                    <label for="filter_date_fin_users" class="form-label">Date fin</label>
                                    <input type="date" class="form-control" id="filter_date_fin_users">
                                </div>
                                <div class="col-md-3">
                                    <label for="filter_action_users" class="form-label">Type d'action</label>
                                    <select class="form-select" id="filter_action_users">
                                        <option value="">Toutes les actions</option>
                                        <option value="ajout">Ajout</option>
                                        <option value="modification">Modification</option>
                                        <option value="suppression">Suppression</option>
                                        <option value="changement_statut">Changement statut</option>
                                        <option value="reinitialisation_mdp">Réinit. mot de passe</option>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <label for="filter_utilisateur_cible" class="form-label">Utilisateur concerné</label>
                                    <select class="form-select" id="filter_utilisateur_cible">
                                        <option value="">Tous les utilisateurs</option>
                                        <?php foreach ($users_list as $user): ?>
                                            <option value="<?= htmlspecialchars($user['username']) ?>">
                                                <?= htmlspecialchars($user['username']) ?>
                                            </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                            </div>
                            <div class="row mt-3">
                                <div class="col-12">
                                    <button type="button" class="btn btn-primary" id="btn_filter_users">
                                        <i class="fas fa-search me-1"></i>
                                        Appliquer les filtres
                                    </button>
                                    <button type="button" class="btn btn-outline-secondary ms-2" id="btn_reset_users">
                                        <i class="fas fa-undo me-1"></i>
                                        Réinitialiser
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div class="table-card position-relative">
                            <div class="loading-overlay d-none" id="loading_overlay_users">
                                <div class="text-center">
                                    <div class="spinner-border text-primary" role="status">
                                        <span class="visually-hidden">Chargement...</span>
                                    </div>
                                    <p class="mt-2">Chargement des données...</p>
                                </div>
                            </div>
                            
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5 class="mb-0">
                                    <i class="fas fa-history me-2"></i>
                                    Historique des actions sur les utilisateurs
                                </h5>
                            </div>
                            
                            <div class="table-responsive">
                                <table id="historique_users_table" class="table table-striped table-hover" style="width:100%">
                                    <thead>
                                        <tr>
                                            <th>Date</th>
                                            <th>Action</th>
                                            <th>Utilisateur concerné</th>
                                            <th>Auteur</th>
                                            <th>Détails</th>
                                            <th>IP</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <!-- Données chargées via AJAX -->
                                    </tbody>
                                </table>
                            </div>
                        </div>

                    <?php else: ?>
                        <!-- Activité globale -->
                        <div class="filter-card">
                            <h5 class="mb-3">
                                <i class="fas fa-filter me-2"></i>
                                Filtres de recherche - Activité globale
                            </h5>
                            <div class="row">
                                <div class="col-md-2">
                                    <label for="filter_date_debut_activity" class="form-label">Date début</label>
                                    <input type="date" class="form-control" id="filter_date_debut_activity">
                                </div>
                                <div class="col-md-2">
                                    <label for="filter_date_fin_activity" class="form-label">Date fin</label>
                                    <input type="date" class="form-control" id="filter_date_fin_activity">
                                </div>
                                <div class="col-md-2">
                                    <label for="filter_utilisateur_activity" class="form-label">Utilisateur</label>
                                    <select class="form-select" id="filter_utilisateur_activity">
                                        <option value="">Tous</option>
                                        <?php foreach ($users_list as $user): ?>
                                            <option value="<?= htmlspecialchars($user['username']) ?>">
                                                <?= htmlspecialchars($user['username']) ?>
                                            </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="filter_action_activity" class="form-label">Type d'action</label>
                                    <select class="form-select" id="filter_action_activity">
                                        <option value="">Toutes</option>
                                        <option value="connexion">Connexion</option>
                                        <option value="deconnexion">Déconnexion</option>
                                        <option value="consultation">Consultation</option>
                                        <option value="creation">Création</option>
                                        <option value="modification">Modification</option>
                                        <option value="suppression">Suppression</option>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="filter_page_activity" class="form-label">Page</label>
                                    <input type="text" class="form-control" id="filter_page_activity" placeholder="Ex: dashboard.php">
                                </div>
                                <div class="col-md-2 d-flex align-items-end">
                                    <button type="button" class="btn btn-primary w-100" id="btn_filter_activity">
                                        <i class="fas fa-search me-1"></i>
                                        Filtrer
                                    </button>
                                </div>
                            </div>
                            <div class="row mt-2">
                                <div class="col-12">
                                    <button type="button" class="btn btn-outline-secondary" id="btn_reset_activity">
                                        <i class="fas fa-undo me-1"></i>
                                        Réinitialiser
                                    </button>
                                    <button type="button" class="btn btn-outline-info ms-2" id="btn_export_activity">
                                        <i class="fas fa-download me-1"></i>
                                        Exporter
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div class="table-card position-relative">
                            <div class="loading-overlay d-none" id="loading_overlay_activity">
                                <div class="text-center">
                                    <div class="spinner-border text-primary" role="status">
                                        <span class="visually-hidden">Chargement...</span>
                                    </div>
                                    <p class="mt-2">Chargement des données...</p>
                                </div>
                            </div>
                            
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5 class="mb-0">
                                    <i class="fas fa-chart-line me-2"></i>
                                    Toutes les activités de l'application
                                </h5>
                                <div class="badge bg-primary fs-6">
                                    <span id="total_activity_displayed">0</span> / <span id="total_activity_all">0</span> actions
                                </div>
                            </div>
                            
                            <div class="table-responsive">
                                <table id="activity_table" class="table table-striped table-hover" style="width:100%">
                                    <thead>
                                        <tr>
                                            <th>Date/Heure</th>
                                            <th>Utilisateur</th>
                                            <th>Action</th>
                                            <th>Page/Module</th>
                                            <th>Détails</th>
                                            <th>IP</th>
                                            <th>Session</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <!-- Données chargées via AJAX -->
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
    <script src="https://cdn.datatables.net/responsive/2.2.9/js/dataTables.responsive.min.js"></script>
    <script src="https://cdn.datatables.net/responsive/2.2.9/js/responsive.bootstrap5.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.2.2/js/dataTables.buttons.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.2.2/js/buttons.bootstrap5.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.2.2/js/buttons.html5.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.2.2/js/buttons.print.min.js"></script>

    <script>
// Script JavaScript simplifié
let currentType = '<?= $current_type ?>';
let historiqueUsersTable = null;
let activityTable = null;

$(document).ready(function() {
    console.log('DOM Ready - Current Type:', currentType);
    initializePage();
    setupEventListeners();
});

function initializePage() {
    console.log('Initializing page for type:', currentType);
    
    switch (currentType) {
        case 'dashboard':
            initializeDashboard();
            break;
        case 'historique_utilisateurs':
            console.log('Initializing historique users table...');
            initializeHistoriqueUsersTable();
            break;
        case 'activite_globale':
            console.log('Initializing activity table...');
            initializeActivityTable();
            break;
    }
}

function initializeDashboard() {
    // Graphique d'activité
    const ctx = document.getElementById('activityChart');
    if (ctx) {
        try {
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['Actions totales', 'Nouveaux patients', 'Utilisateurs modifiés'],
                    datasets: [{
                        data: [<?= $stats['actions_today'] ?? 0 ?>, <?= $stats['patients_added_today'] ?? 0 ?>, <?= $stats['users_modified_today'] ?? 0 ?>],
                        backgroundColor: [
                            '#007bff',
                            '#28a745',
                            '#ffc107'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom'
                        }
                    }
                }
            });
        } catch (error) {
            console.error('Erreur Chart.js:', error);
        }
    }
}

function initializeHistoriqueUsersTable() {
    console.log('Starting initializeHistoriqueUsersTable...');
    
    if (!$('#historique_users_table').length) {
        console.error('Table #historique_users_table not found');
        return;
    }
    
    if (historiqueUsersTable) {
        historiqueUsersTable.destroy();
        historiqueUsersTable = null;
    }

    try {
        historiqueUsersTable = $('#historique_users_table').DataTable({
            processing: true,
            serverSide: true,
            destroy: true,
            ajax: {
                url: 'ajax/get_historique_utilisateurs.php',
                type: 'POST',
                data: function(d) {
                    d.date_debut = $('#filter_date_debut_users').val();
                    d.date_fin = $('#filter_date_fin_users').val();
                    d.action_type = $('#filter_action_users').val();
                    d.utilisateur_cible = $('#filter_utilisateur_cible').val();
                    console.log('AJAX Data sent - Historique:', d);
                    return d;
                },
                beforeSend: function() {
                    console.log('AJAX beforeSend - Historique users table');
                    showLoading('loading_overlay_users', true);
                },
                complete: function() {
                    console.log('AJAX complete - Historique users table');
                    showLoading('loading_overlay_users', false);
                },
                error: function(xhr, error, code) {
                    console.error('AJAX Error - Historique users table:', {
                        status: xhr.status,
                        error: error,
                        code: code,
                        responseText: xhr.responseText
                    });
                    showLoading('loading_overlay_users', false);
                }
            },
            columns: [
                { 
                    data: 'date_action', 
                    title: 'Date',
                    render: function(data) {
                        if (!data) return '';
                        try {
                            const date = new Date(data);
                            return date.toLocaleString('fr-FR');
                        } catch (error) {
                            return data;
                        }
                    }
                },
                { 
                    data: 'action_type', 
                    title: 'Action',
                    render: function(data) {
                        if (!data) return '';
                        const actionMap = {
                            'ajout': '<span class="badge bg-success">Ajout</span>',
                            'modification': '<span class="badge bg-warning text-dark">Modification</span>',
                            'suppression': '<span class="badge bg-danger">Suppression</span>',
                            'changement_statut': '<span class="badge bg-info">Changement statut</span>',
                            'reinitialisation_mdp': '<span class="badge bg-secondary">Réinit. MDP</span>'
                        };
                        return actionMap[data] || '<span class="badge bg-secondary">' + data + '</span>';
                    }
                },
                { 
                    data: 'nom_utilisateur_cible', 
                    title: 'Utilisateur concerné',
                    render: function(data) {
                        return data ? '<strong>' + data + '</strong>' : '';
                    }
                },
                { 
                    data: 'nom_utilisateur_auteur', 
                    title: 'Auteur',
                    render: function(data) {
                        return data ? '<span class="badge bg-primary">' + data + '</span>' : '';
                    }
                },
                { 
                    data: 'details_action', 
                    title: 'Détails',
                    render: function(data) {
                        if (!data) return '';
                        if (data.length > 60) {
                            return '<span title="' + data + '">' + data.substring(0, 60) + '...</span>';
                        }
                        return data;
                    }
                },
                { 
                    data: 'adresse_ip', 
                    title: 'IP',
                    render: function(data) {
    if (!data) return '';
    const labels = {
        consultation: 'Consultation de données',
        ajout: 'Ajout d’un élément',
        creation: 'Création d’un élément',
        modification: 'Modification d’un élément',
        suppression: 'Suppression d’un élément',
        connexion: 'Connexion à l’application',
        deconnexion: 'Déconnexion',
        changement_statut: 'Changement de statut',
        reinitialisation_mdp: 'Réinitialisation du mot de passe'
    };
    let label = labels[data.toLowerCase()] || data;
    return '<span class="badge badge-action action-' + data + '">' + label + '</span>';
}

                },
                { 
                    data: null, 
                    title: 'Actions',
                    render: function(data, type, row) {
                        return '<button class="btn btn-sm btn-outline-primary" onclick="voirDetailsHistorique(' + row.id + ', \'utilisateur\')" title="Voir détails">' +
                                '<i class="fas fa-eye"></i>' +
                                '</button>';
                    }
                }
            ],
            order: [[0, 'desc']],
            pageLength: 25,
            language: {
                url: 'https://cdn.datatables.net/plug-ins/1.11.5/i18n/fr-FR.json'
            },
            responsive: true,
            dom: 'Bfrtip',
            buttons: [
                {
                    extend: 'excel',
                    text: '<i class="fas fa-file-excel me-1"></i>Excel',
                    className: 'btn btn-success btn-sm'
                },
                {
                    extend: 'pdf',
                    text: '<i class="fas fa-file-pdf me-1"></i>PDF',
                    className: 'btn btn-danger btn-sm'
                }
            ]
        });
        
        console.log('Historique users table initialized successfully');
        
    } catch (error) {
        console.error('Erreur lors de l\'initialisation de la table historique users:', error);
    }
}

function initializeActivityTable() {
    console.log('Starting initializeActivityTable...');
    
    if (!$('#activity_table').length) {
        console.error('Table #activity_table not found');
        return;
    }
    
    if (activityTable) {
        activityTable.destroy();
        activityTable = null;
    }

    try {
        activityTable = $('#activity_table').DataTable({
            processing: true,
            serverSide: true,
            destroy: true,
            ajax: {
                url: 'ajax/get_activity_globale.php',
                type: 'POST',
                data: function(d) {
                    d.date_debut = $('#filter_date_debut_activity').val();
                    d.date_fin = $('#filter_date_fin_activity').val();
                    d.utilisateur = $('#filter_utilisateur_activity').val();
                    d.action_type = $('#filter_action_activity').val();
                    d.page = $('#filter_page_activity').val();
                    console.log('AJAX Data sent - Activity:', d);
                    return d;
                },
                beforeSend: function() {
                    console.log('AJAX beforeSend - Activity table');
                    showLoading('loading_overlay_activity', true);
                },
                complete: function() {
                    console.log('AJAX complete - Activity table');
                    showLoading('loading_overlay_activity', false);
                },
                error: function(xhr, error, code) {
                    console.error('AJAX Error - Activity table:', {
                        status: xhr.status,
                        error: error,
                        code: code,
                        responseText: xhr.responseText
                    });
                    showLoading('loading_overlay_activity', false);
                }
            },
            columns: [
                { 
                    data: 'date_action', 
                    title: 'Date/Heure',
                    render: function(data) {
                        if (!data) return '';
                        try {
                            const date = new Date(data);
                            return date.toLocaleString('fr-FR');
                        } catch (error) {
                            return data;
                        }
                    }
                },
                { 
                    data: 'username', 
                    title: 'Utilisateur',
                    render: function(data) {
                        return data ? '<strong>' + data + '</strong>' : '';
                    }
                },
                { 
                    data: 'action_type', 
                    title: 'Action',
                    render: function(data) {
                        return data ? '<span class="badge badge-action action-' + data + '">' + data + '</span>' : '';
                    }
                },
                { 
                    data: 'page_visitee', 
                    title: 'Page/Module',
                    render: function(data) {
                        return data || '-';
                    }
                },
                { 
                    data: 'details_action', 
                    title: 'Détails',
                    render: function(data) {
                        if (!data) return '-';
                        if (data.length > 50) {
                            return '<span title="' + data + '">' + data.substring(0, 50) + '...</span>';
                        }
                        return data;
                    }
                },
                { 
                    data: 'adresse_ip', 
                    title: 'IP',
                    render: function(data) {
                        return data ? '<code>' + data + '</code>' : '-';
                    }
                },
                { 
                    data: 'session_id', 
                    title: 'Session',
                    render: function(data) {
                        return data ? '<code>' + data.substring(0, 8) + '...</code>' : '-';
                    }
                }
            ],
            order: [[0, 'desc']],
            pageLength: 50,
            language: {
                url: 'https://cdn.datatables.net/plug-ins/1.11.5/i18n/fr-FR.json'
            },
            responsive: true,
            dom: 'Bfrtip',
            buttons: [
                {
                    extend: 'excel',
                    text: '<i class="fas fa-file-excel me-1"></i>Excel',
                    className: 'btn btn-success btn-sm'
                },
                {
                    extend: 'csv',
                    text: '<i class="fas fa-file-csv me-1"></i>CSV',
                    className: 'btn btn-info btn-sm'
                }
            ],
            drawCallback: function(settings) {
                const total = settings.json ? (settings.json.recordsTotal || 0) : 0;
                const displayed = settings.json ? (settings.json.recordsFiltered || 0) : 0;
                
                $('#total_activity_all').text(total);
                $('#total_activity_displayed').text(displayed);
            }
        });
        
        console.log('Activity table initialized successfully');
        
    } catch (error) {
        console.error('Erreur lors de l\'initialisation de la table activity:', error);
    }
}

function setupEventListeners() {
    console.log('Setting up event listeners');
    
    // Filtres historique utilisateurs
    $(document).off('click', '#btn_filter_users').on('click', '#btn_filter_users', function() {
        console.log('Filter users button clicked');
        if (historiqueUsersTable) {
            historiqueUsersTable.ajax.reload();
        }
    });

    $(document).off('click', '#btn_reset_users').on('click', '#btn_reset_users', function() {
        console.log('Reset users button clicked');
        $('#filter_date_debut_users, #filter_date_fin_users').val('');
        $('#filter_action_users, #filter_utilisateur_cible').val('');
        if (historiqueUsersTable) {
            historiqueUsersTable.ajax.reload();
        }
    });

    // Filtres activité globale
    $(document).off('click', '#btn_filter_activity').on('click', '#btn_filter_activity', function() {
        console.log('Filter activity button clicked');
        if (activityTable) {
            activityTable.ajax.reload();
        }
    });

    $(document).off('click', '#btn_reset_activity').on('click', '#btn_reset_activity', function() {
        console.log('Reset activity button clicked');
        $('#filter_date_debut_activity, #filter_date_fin_activity, #filter_page_activity').val('');
        $('#filter_utilisateur_activity, #filter_action_activity').val('');
        if (activityTable) {
            activityTable.ajax.reload();
        }
    });

    $(document).off('click', '#btn_export_activity').on('click', '#btn_export_activity', function() {
        console.log('Export activity button clicked');
        // Export personnalisé de l'activité
        const params = {
            date_debut: $('#filter_date_debut_activity').val(),
            date_fin: $('#filter_date_fin_activity').val(),
            utilisateur: $('#filter_utilisateur_activity').val(),
            action_type: $('#filter_action_activity').val(),
            page: $('#filter_page_activity').val(),
            format: 'excel'
        };
        
        const url = 'ajax/export_activity.php?' + $.param(params);
        console.log('Opening export URL:', url);
        window.open(url);
    });
}

function showLoading(overlayId, show) {
    const overlay = $('#' + overlayId);
    if (overlay.length) {
        if (show) {
            overlay.removeClass('d-none');
        } else {
            overlay.addClass('d-none');
        }
    }
}

function voirDetailsHistorique(id, type) {
    console.log('Viewing historique details:', id, type);
    
    $.ajax({
        url: 'ajax/get_details_historique.php',
        type: 'POST',
        data: { id: id, type: type },
        success: function(response) {
            showHistoriqueModal(response);
        },
        error: function(xhr, status, error) {
            console.error('Erreur get_details_historique:', { xhr, status, error });
            alert('Erreur lors du chargement des détails');
        }
    });
}

function showHistoriqueModal(data) {
    const modalHtml = `
        <div class="modal fade" id="detailsModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Détails de l'action</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        ${data}
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Fermer</button>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    $('body').append(modalHtml);
    $('#detailsModal').modal('show');
    
    $('#detailsModal').on('hidden.bs.modal', function() {
        $(this).remove();
    });
}

</script>

</body>
</html>
<?php include 'includes/footer.php'; ?>