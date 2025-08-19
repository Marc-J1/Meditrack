<?php
// Connexion à la base de données (à adapter selon votre configuration)
include 'includes/auto_track.php';
require_once 'db.php';
include 'includes/header.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'A consulté l\'historique médicale');



// Configuration des types d'historiques
$history_types = [
    'consultations' => [
        'title' => 'Consultations',
        'icon' => 'fas fa-stethoscope',
        'table' => 'consultations',
        'date_field' => 'date_consultation',
        'ajax_file' => 'get_consultations.php'
    ],
    'ordonnances' => [
        'title' => 'Ordonnances',
        'icon' => 'fas fa-prescription-bottle-alt',
        'table' => 'ordonnances',
        'date_field' => 'date_ordonnance',
        'ajax_file' => 'get_ordonnances.php'
    ],
    'observations' => [
        'title' => 'Observations',
        'icon' => 'fas fa-eye',
        'table' => 'observations',
        'date_field' => 'date_observation',
        'ajax_file' => 'get_observations.php'
    ],
    'bons_examens' => [
        'title' => 'Bons d\'examens',
        'icon' => 'fas fa-vial',
        'table' => 'bons_examens',
        'date_field' => 'date_creation',
        'ajax_file' => 'get_bons_examens.php'
    ]
];

// Récupération de tous les médecins pour le filtre
$query_medecins = "SELECT id_utilisateur, username FROM users WHERE role = 'medecin' ORDER BY username";
$stmt_medecins = $pdo->prepare($query_medecins);
$stmt_medecins->execute();
$medecins = $stmt_medecins->fetchAll(PDO::FETCH_ASSOC);

// Type par défaut
$current_type = isset($_GET['type']) && isset($history_types[$_GET['type']]) ? $_GET['type'] : 'consultations';
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Historique Médical - <?= $history_types[$current_type]['title'] ?></title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- DataTables CSS -->
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.11.5/css/dataTables.bootstrap5.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/responsive/2.2.9/css/responsive.bootstrap5.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/buttons/2.2.2/css/buttons.bootstrap5.min.css">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <style>
        .page-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-color: transparent;
            transform: translateY(-2px);
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
        
        .status-badge {
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        
        .status-programmee, .status-active {
            background-color: #e3f2fd;
            color: #1976d2;
        }
        
        .status-en_cours {
            background-color: #fff3e0;
            color: #f57c00;
        }
        
        .status-terminee, .status-suspendue {
            background-color: #e8f5e8;
            color: #388e3c;
        }
        
        .btn-action {
            padding: 0.25rem 0.5rem;
            margin: 0 0.2rem;
            border-radius: 5px;
            font-size: 0.8rem;
        }
        
        .dataTables_wrapper .dataTables_filter input {
            border-radius: 20px;
            padding: 0.5rem 1rem;
            border: 1px solid #ddd;
        }
        
        .table th {
            background-color: #667eea;
            color: white;
            border: none;
            padding: 1rem 0.75rem;
        }
        
        .table tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        .type-icon {
            display: inline-block;
            width: 20px;
            margin-right: 8px;
        }
        
        .stats-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            padding: 1rem;
            margin-bottom: 1rem;
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
    </style>
    <style>
  /* Cache le sidebar avec animation quand body a la classe pc-sidebar-hide */
  body.pc-sidebar-hide .pc-sidebar {
    transform: translateX(-100%);
    transition: transform 0.3s ease-in-out;
  }

  .pc-sidebar {
    transition: transform 0.3s ease-in-out;
  }

  /* Décale le contenu vers la gauche pour libérer l’espace */
  body.pc-sidebar-hide .pc-container,
  body.pc-sidebar-hide .pcoded-content,
  body.pc-sidebar-hide .header-wrapper,
  body.pc-sidebar-hide .page-header {
    margin-left: 0 !important;
  }
</style>

</head>

<body>
  <?php include 'includes/sidebar-medecin.php'; ?>
  <?php include 'includes/header.php'; ?>

  <div class="pc-container">
    <div class="pcoded-content">
      <div class="page-header">
        <div class="container">
            <div class="mb-3">
 
</div>

            <div class="row align-items-center">
                <div class="col-md-8">
                    <h1 class="mb-0">
                        <i class="fas fa-history me-3"></i>
                        Historique Médical
                    </h1>
                    <p class="mb-0 mt-2 opacity-75">Gestion complète des données médicales</p>
                </div>
                <div class="col-md-4 text-end">
                    <div class="stats-card">
                        <div class="d-flex align-items-center">
                            <i class="<?= $history_types[$current_type]['icon'] ?> fa-2x me-3"></i>
                            <div>
                                <h5 class="mb-0" id="total_records">0</h5>
                                <small><?= $history_types[$current_type]['title'] ?></small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="container-fluid">
        <!-- Onglets de navigation -->
        <ul class="nav nav-tabs nav-tabs-custom" id="historyTabs" role="tablist">
            <?php foreach ($history_types as $key => $config): ?>
                <li class="nav-item" role="presentation">
                    <a class="nav-link <?= $key === $current_type ? 'active' : '' ?>" 
                       href="?type=<?= $key ?>"
                       role="tab">
                        <i class="<?= $config['icon'] ?> type-icon"></i>
                        <?= $config['title'] ?>
                    </a>
                </li>
            <?php endforeach; ?>
        </ul>

        <!-- Filtres -->
        <div class="filter-card">
            <h5 class="mb-3">
                <i class="fas fa-filter me-2"></i>
                Filtres de recherche - <?= $history_types[$current_type]['title'] ?>
            </h5>
            <div class="row">
                <div class="col-md-3">
                    <label for="filter_date_debut" class="form-label">Date début</label>
                    <input type="date" class="form-control" id="filter_date_debut">
                </div>
                <div class="col-md-3">
                    <label for="filter_date_fin" class="form-label">Date fin</label>
                    <input type="date" class="form-control" id="filter_date_fin">
                </div>
                <div class="col-md-3">
                    <label for="filter_medecin" class="form-label">Médecin</label>
                    <select class="form-select" id="filter_medecin">
                        <option value="">Tous les médecins</option>
                        <?php foreach ($medecins as $medecin): ?>
                            <option value="<?= htmlspecialchars($medecin['username']) ?>">
                                <?= htmlspecialchars($medecin['username']) ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3" id="status_filter_container">
                    <label for="filter_statut" class="form-label">Statut</label>
                    <select class="form-select" id="filter_statut">
                        <option value="">Tous les statuts</option>
                        <!-- Options dynamiques selon le type -->
                    </select>
                </div>
            </div>
            <div class="row mt-3">
                <div class="col-12">
                    <button type="button" class="btn btn-primary" id="btn_filter">
                        <i class="fas fa-search me-1"></i>
                        Appliquer les filtres
                    </button>
                    <button type="button" class="btn btn-outline-secondary ms-2" id="btn_reset">
                        <i class="fas fa-undo me-1"></i>
                        Réinitialiser
                    </button>
                    <button type="button" class="btn btn-outline-info ms-2" id="btn_refresh">
                        <i class="fas fa-sync-alt me-1"></i>
                        Actualiser
                    </button>
                </div>
            </div>
        </div>

        <!-- Tableau des données -->
        <div class="table-card position-relative">
            <div class="loading-overlay d-none" id="loading_overlay">
                <div class="text-center">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Chargement...</span>
                    </div>
                    <p class="mt-2">Chargement des données...</p>
                </div>
            </div>
            
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="mb-0">
                    <i class="fas fa-table me-2"></i>
                    Liste des <?= strtolower($history_types[$current_type]['title']) ?>
                </h5>
                <div class="badge bg-primary fs-6">
                    <span id="total_displayed">0</span> / <span id="total_all">0</span> éléments
                </div>
            </div>
            
            <div class="table-responsive">
                <table id="main_table" class="table table-striped table-hover" style="width:100%">
                    <thead id="table_header">
                        <!-- En-têtes dynamiques -->
                    </thead>
                    <tbody>
                        <!-- Les données seront chargées via AJAX -->
                    </tbody>
                </table>
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
        // Configuration des types d'historiques
      const historyConfigs = {
    consultations: {
        columns: [
            { data: 'date_consultation', title: 'Date', type: 'date' },
            { data: 'patient', title: 'Patient', type: 'patient' },
            { data: 'medecin', title: 'Médecin', type: 'medecin' },
            { data: 'motif', title: 'Motif', type: 'text' },
            { data: 'diagnostic', title: 'Diagnostic', type: 'text' },
            { data: 'statut', title: 'Statut', type: 'status' }
           
        ],
        statuses: [
            { value: 'programmee', text: 'Programmée' },
            { value: 'en_cours', text: 'En cours' },
            { value: 'terminee', text: 'Terminée' }
        ]
    },
    ordonnances: {
        columns: [
               { data: 'date_ordonnance', title: 'Date' },
    { data: 'patient',         title: 'Patient' },
    { data: 'medecin',         title: 'Médecin' },
    { data: 'notes',           title: 'Ordonnance' }, // ✅ ici
    { data: 'statut',          title: 'Statut' }
          
        ],
        statuses: [
            { value: 'active', text: 'Active' },
            { value: 'suspendue', text: 'Suspendue' },
            { value: 'terminee', text: 'Terminée' }
        ]
    },
    observations: {
        columns: [
            { data: 'date_observation', title: 'Date', type: 'date' },
            { data: 'patient', title: 'Patient', type: 'patient' },
            { data: 'medecin', title: 'Médecin', type: 'medecin' },
            { data: 'type_observation', title: 'Type', type: 'badge' },
            { data: 'contenu', title: 'Contenu', type: 'text' }
           
        ],
        statuses: []
    },
    bons_examens: {
        columns: [
            { data: 'date_creation', title: 'Date', type: 'date' },
            { data: 'patient', title: 'Patient', type: 'patient' },
            { data: 'medecin', title: 'Médecin', type: 'medecin' },
            { data: 'service_demandeur', title: 'Service', type: 'text' },
            { data: 'renseignement_clinique', title: 'Renseignements', type: 'text' },
            { data: 'age', title: 'Âge', type: 'text' },
            { data: 'poids', title: 'Poids', type: 'text' }
        
        ],
        statuses: []
    }
};


        let currentType = '<?= $current_type ?>';
        let table = null;

        $(document).ready(function() {
            initializeTable();
            setupEventListeners();
            updateStatusFilter();
        });

        function initializeTable() {
            const config = historyConfigs[currentType];
            
            // Mise à jour des en-têtes
            updateTableHeaders(config.columns);
            
            // Configuration des colonnes DataTable
            const dtColumns = config.columns.map(col => ({
                data: col.data,
                title: col.title,
                orderable: col.type !== 'actions',
                render: function(data, type, row) {
                    return renderCell(data, col.type, row);
                }
            }));

            // Initialisation du DataTable
            if (table) {
                table.destroy();
            }

            table = $('#main_table').DataTable({
                processing: true,
                serverSide: true,
                ajax: {
                    url: 'ajax/get_' + currentType + '.php',
                    type: 'POST',
                    data: function(d) {
                        d.date_debut = $('#filter_date_debut').val();
                        d.date_fin = $('#filter_date_fin').val();
                        d.medecin = $('#filter_medecin').val();
                        d.statut = $('#filter_statut').val();
                    },
                    beforeSend: function() {
                        showLoading(true);
                    },
                    complete: function() {
                        showLoading(false);
                    }
                },
                columns: dtColumns,
                order: [[0, 'desc']],
                pageLength: 25,
                lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "Tout"]],
                language: {
                    url: 'https://cdn.datatables.net/plug-ins/1.11.5/i18n/fr-FR.json'
                },
                responsive: true,
                dom: 'Bfrtip',
                buttons: [
                    {
                        extend: 'excel',
                        text: '<i class="fas fa-file-excel me-1"></i>Excel',
                        className: 'btn btn-success btn-sm',
                        title: 'Historique_' + currentType + '_' + new Date().toISOString().slice(0,10)
                    },
                    {
                        extend: 'pdf',
                        text: '<i class="fas fa-file-pdf me-1"></i>PDF',
                        className: 'btn btn-danger btn-sm',
                        title: 'Historique_' + currentType + '_' + new Date().toISOString().slice(0,10)
                    },
                    {
                        extend: 'print',
                        text: '<i class="fas fa-print me-1"></i>Imprimer',
                        className: 'btn btn-info btn-sm'
                    }
                ],
                drawCallback: function(settings) {
                    const total = settings.json.recordsTotal || 0;
                    const displayed = settings.json.recordsFiltered || 0;
                    
                    $('#total_records').text(total);
                    $('#total_all').text(total);
                    $('#total_displayed').text(displayed);
                }
            });
        }

        function updateTableHeaders(columns) {
            let headerHtml = '<tr>';
            columns.forEach(col => {
                headerHtml += `<th>${col.title}</th>`;
            });
            headerHtml += '</tr>';
            $('#table_header').html(headerHtml);
        }

        function renderCell(data, type, row) {
            switch (type) {
                case 'date':
                    if (data) {
                        const date = new Date(data);
                        return date.toLocaleDateString('fr-FR', {
                            year: 'numeric',
                            month: '2-digit',
                            day: '2-digit',
                            hour: '2-digit',
                            minute: '2-digit'
                        });
                    }
                    return '-';

                case 'patient':
                    return `<strong>${row.patient_nom || ''} ${row.patient_prenom || ''}</strong>`;

                case 'medecin':
                    return `<span class="badge bg-info">${data || ''}</span>`;

                case 'text':
                    if (data && data.length > 50) {
                        return `<span title="${data}">${data.substring(0, 50)}...</span>`;
                    }
                    return data || '-';

                case 'status':
                    if (data) {
                        const statusClass = 'status-' + data;
                        let statusText = data;
                        
                        // Conversion des statuts
                        const statusMap = {
                            'programmee': 'Programmée',
                            'en_cours': 'En cours',
                            'terminee': 'Terminée',
                            'active': 'Active',
                            'suspendue': 'Suspendue'
                        };
                        
                        statusText = statusMap[data] || data;
                        return `<span class="status-badge ${statusClass}">${statusText}</span>`;
                    }
                    return '-';

                case 'badge':
                    return data ? `<span class="badge bg-secondary">${data}</span>` : '-';

                case 'actions':
                    return `
                        <button class="btn btn-sm btn-primary btn-action" onclick="voirElement(${row.id}, '${currentType}')" title="Voir détails">
                            <i class="fas fa-eye"></i>
                        </button>
                       
                    `;

                default:
                    return data || '-';
            }
        }

        function updateStatusFilter() {
            const config = historyConfigs[currentType];
            const statusSelect = $('#filter_statut');
            
            statusSelect.empty().append('<option value="">Tous les statuts</option>');
            
            if (config.statuses && config.statuses.length > 0) {
                config.statuses.forEach(status => {
                    statusSelect.append(`<option value="${status.value}">${status.text}</option>`);
                });
                $('#status_filter_container').show();
            } else {
                $('#status_filter_container').hide();
            }
        }

        function setupEventListeners() {
            // Gestion des filtres
            $('#btn_filter').click(function() {
                if (table) table.ajax.reload();
            });

            $('#btn_reset').click(function() {
                $('#filter_date_debut, #filter_date_fin').val('');
                $('#filter_medecin, #filter_statut').val('');
                if (table) table.ajax.reload();
            });

            $('#btn_refresh').click(function() {
                if (table) table.ajax.reload();
            });

            // Filtrage en temps réel
            $('#filter_medecin, #filter_statut').change(function() {
                if (table) table.ajax.reload();
            });
        }

        function showLoading(show) {
            if (show) {
                $('#loading_overlay').removeClass('d-none');
            } else {
                $('#loading_overlay').addClass('d-none');
            }
        }

        // Fonctions pour les actions
        function voirElement(id, type) {
            window.location.href = `voir_${type.slice(0, -1)}.php?id=${id}`;
        }
        

        function modifierElement(id, type) {
            window.location.href = `modifier_${type.slice(0, -1)}.php?id=${id}`;
        }
    </script>

    

</body>

</html>
<?php include 'includes/footer.php'; ?>