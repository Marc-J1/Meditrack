<?php
session_start();
require_once 'db.php';

if (!isset($_SESSION['user']) || ($_SESSION['user']['role'] !== 'medecin')) {
    header("Location: login.php");
    exit();
}

// Configuration pagination
$itemsPerPage = isset($_GET['per_page']) ? (int)$_GET['per_page'] : 10;
$currentPage = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$offset = ($currentPage - 1) * $itemsPerPage;

// ===== RÉCUPÉRATION DES FILTRES =====
$filters = [
    'sexe' => isset($_GET['sexe']) ? trim($_GET['sexe']) : '',
    'age_min' => isset($_GET['age_min']) && $_GET['age_min'] !== '' ? (int)$_GET['age_min'] : null,
    'age_max' => isset($_GET['age_max']) && $_GET['age_max'] !== '' ? (int)$_GET['age_max'] : null,
    'taille_min' => isset($_GET['taille_min']) && $_GET['taille_min'] !== '' ? (float)$_GET['taille_min'] : null,
    'taille_max' => isset($_GET['taille_max']) && $_GET['taille_max'] !== '' ? (float)$_GET['taille_max'] : null,
    'poids_min' => isset($_GET['poids_min']) && $_GET['poids_min'] !== '' ? (float)$_GET['poids_min'] : null,
    'poids_max' => isset($_GET['poids_max']) && $_GET['poids_max'] !== '' ? (float)$_GET['poids_max'] : null,
    'date_debut' => isset($_GET['date_debut']) && $_GET['date_debut'] !== '' ? $_GET['date_debut'] : null,
    'date_fin' => isset($_GET['date_fin']) && $_GET['date_fin'] !== '' ? $_GET['date_fin'] : null,
];

// ===== CONSTRUCTION DE LA REQUÊTE SQL AVEC FILTRES =====
$whereConditions = [];
$params = [];

// Filtre sexe
if (!empty($filters['sexe'])) {
    $whereConditions[] = "sexe = :sexe";
    $params[':sexe'] = $filters['sexe'];
}

// Filtre âge min
if ($filters['age_min'] !== null) {
    $whereConditions[] = "TIMESTAMPDIFF(YEAR, date_naissance, CURDATE()) >= :age_min";
    $params[':age_min'] = $filters['age_min'];
}

// Filtre âge max
if ($filters['age_max'] !== null) {
    $whereConditions[] = "TIMESTAMPDIFF(YEAR, date_naissance, CURDATE()) <= :age_max";
    $params[':age_max'] = $filters['age_max'];
}

// Filtre taille min
if ($filters['taille_min'] !== null) {
    $whereConditions[] = "taille >= :taille_min";
    $params[':taille_min'] = $filters['taille_min'];
}

// Filtre taille max
if ($filters['taille_max'] !== null) {
    $whereConditions[] = "taille <= :taille_max";
    $params[':taille_max'] = $filters['taille_max'];
}

// Filtre poids min
if ($filters['poids_min'] !== null) {
    $whereConditions[] = "poids >= :poids_min";
    $params[':poids_min'] = $filters['poids_min'];
}

// Filtre poids max
if ($filters['poids_max'] !== null) {
    $whereConditions[] = "poids <= :poids_max";
    $params[':poids_max'] = $filters['poids_max'];
}

// Filtre date début
if ($filters['date_debut'] !== null) {
    $whereConditions[] = "DATE(date_creation) >= :date_debut";
    $params[':date_debut'] = $filters['date_debut'];
}

// Filtre date fin
if ($filters['date_fin'] !== null) {
    $whereConditions[] = "DATE(date_creation) <= :date_fin";
    $params[':date_fin'] = $filters['date_fin'];
}

// Construction de la clause WHERE
$whereClause = '';
if (!empty($whereConditions)) {
    $whereClause = ' WHERE ' . implode(' AND ', $whereConditions);
}

// ===== COMPTAGE TOTAL AVEC FILTRES =====
$countSql = "SELECT COUNT(*) FROM patients" . $whereClause;
$countStmt = $pdo->prepare($countSql);
foreach ($params as $key => $value) {
    $countStmt->bindValue($key, $value);
}
$countStmt->execute();
$totalItems = $countStmt->fetchColumn();
$totalPages = ceil($totalItems / $itemsPerPage);

// ===== REQUÊTE PRINCIPALE AVEC FILTRES ET PAGINATION =====
$mainSql = "SELECT *, TIMESTAMPDIFF(YEAR, date_naissance, CURDATE()) AS age 
            FROM patients" . $whereClause . " 
            ORDER BY date_creation DESC 
            LIMIT :offset, :limit";

$mainStmt = $pdo->prepare($mainSql);

// Bind des paramètres de filtres
foreach ($params as $key => $value) {
    $mainStmt->bindValue($key, $value);
}

// Bind des paramètres de pagination
$mainStmt->bindValue(':offset', $offset, PDO::PARAM_INT);
$mainStmt->bindValue(':limit', $itemsPerPage, PDO::PARAM_INT);
$mainStmt->execute();

// ===== FONCTION POUR CONSTRUIRE LES URLS AVEC FILTRES =====
function buildUrlWithFilters($page = null, $perPage = null) {
    global $filters, $itemsPerPage, $currentPage;
    
    $params = [];
    
    // Ajouter la page
    $params['page'] = $page !== null ? $page : $currentPage;
    
    // Ajouter per_page
    $params['per_page'] = $perPage !== null ? $perPage : $itemsPerPage;
    
    // Ajouter les filtres existants
    foreach ($filters as $key => $value) {
        if ($value !== null && $value !== '') {
            $params[$key] = $value;
        }
    }
    
    return '?' . http_build_query($params);
}

include 'includes/header.php';
include 'includes/sidebar-medecin.php';

?>
<?php if (isset($_GET['success']) && in_array($_GET['success'], ['modification', 'suppression'])): ?>
<?php
    $message = ($_GET['success'] === 'modification')
        ? ' Patient modifié avec succès.'
        : 'Patient supprimé avec succès.';
?>
<div id="toast-success" style="
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background-color: #3f3c3cff;
    color: white;
    padding: 20px 30px;
    border-radius: 10px;
    box-shadow: 0 8px 16px rgba(0,0,0,0.3);
    font-size: 18px;
    z-index: 1000;
    opacity: 0;
    transition: opacity 0.5s ease-in-out;
">
    <?= $message ?>
</div>

<script>
window.addEventListener('DOMContentLoaded', () => {
    const toast = document.getElementById('toast-success');
    toast.style.opacity = '1';

    setTimeout(() => {
        toast.style.opacity = '0';
    }, 3000);
});
</script>
<?php endif; ?>



<!-- Contenu principal -->
<div class="pc-container">
  <div class="pc-content">
    <div class="page-header">
      <h4 class="mb-3">Liste des Patients</h4>
      <?php if ($totalItems > 0): ?>
        <p class="text-muted">
          <?php 
          $hasFilters = array_filter($filters, function($v) { return $v !== null && $v !== ''; });
          if (!empty($hasFilters)) {
              echo "Affichage de $totalItems patient(s) correspondant aux critères";
          } else {
              echo "Total : $totalItems patient(s)";
          }
          ?>
        </p>
      <?php endif; ?>
    </div>

    <div class="card">
      <div class="card-body">
        <!-- Formulaire de filtres -->
        <div class="bg-gray-50 p-4 rounded-md mb-4">
          <form method="GET" action="" class="flex flex-wrap gap-3 items-end">
            <!-- Conservation de la pagination -->
            <input type="hidden" name="per_page" value="<?php echo $itemsPerPage; ?>">
            
            <div>
              <label for="sexe" class="text-sm text-gray-600">Sexe</label>
              <select name="sexe" id="sexe" class="form-select form-select-sm">
                <option value="">Tous</option>
                <option value="Homme" <?php echo $filters['sexe'] === 'Homme' ? 'selected' : ''; ?>>Homme</option>
                <option value="Femme" <?php echo $filters['sexe'] === 'Femme' ? 'selected' : ''; ?>>Femme</option>
              </select>
            </div>

            <!-- Filtre âge avec min/max -->
            <div>
              <label class="text-sm text-gray-600">Âge (ans)</label>
              <div class="flex gap-1 items-center">
                <input type="number" name="age_min" id="age_min" 
                       class="form-control form-control-sm" 
                       placeholder="Min" style="width: 70px;" 
                       min="0" max="120"
                       value="<?php echo $filters['age_min'] !== null ? $filters['age_min'] : ''; ?>">
                <span class="text-xs text-gray-500">à</span>
                <input type="number" name="age_max" id="age_max" 
                       class="form-control form-control-sm" 
                       placeholder="Max" style="width: 70px;" 
                       min="0" max="120"
                       value="<?php echo $filters['age_max'] !== null ? $filters['age_max'] : ''; ?>">
              </div>
            </div>

            <!-- Filtre taille avec min/max -->
            <div>
              <label class="text-sm text-gray-600">Taille (cm)</label>
              <div class="flex gap-1 items-center">
                <input type="number" name="taille_min" id="taille_min" 
                       class="form-control form-control-sm" 
                       placeholder="Min" style="width: 70px;" 
                       min="50" max="250" step="0.1"
                       value="<?php echo $filters['taille_min'] !== null ? $filters['taille_min'] : ''; ?>">
                <span class="text-xs text-gray-500">à</span>
                <input type="number" name="taille_max" id="taille_max" 
                       class="form-control form-control-sm" 
                       placeholder="Max" style="width: 70px;" 
                       min="50" max="250" step="0.1"
                       value="<?php echo $filters['taille_max'] !== null ? $filters['taille_max'] : ''; ?>">
              </div>
            </div>

            <!-- Filtre poids avec min/max -->
            <div>
              <label class="text-sm text-gray-600">Poids (kg)</label>
              <div class="flex gap-1 items-center">
                <input type="number" name="poids_min" id="poids_min" 
                       class="form-control form-control-sm" 
                       placeholder="Min" style="width: 70px;" 
                       min="1" max="300" step="0.1"
                       value="<?php echo $filters['poids_min'] !== null ? $filters['poids_min'] : ''; ?>">
                <span class="text-xs text-gray-500">à</span>
                <input type="number" name="poids_max" id="poids_max" 
                       class="form-control form-control-sm" 
                       placeholder="Max" style="width: 70px;" 
                       min="1" max="300" step="0.1"
                       value="<?php echo $filters['poids_max'] !== null ? $filters['poids_max'] : ''; ?>">
              </div>
            </div>

            <div>
              <label for="date_debut" class="text-sm text-gray-600">Du</label>
              <input type="date" name="date_debut" id="date_debut" 
                     class="form-control form-control-sm"
                     value="<?php echo $filters['date_debut'] !== null ? $filters['date_debut'] : ''; ?>">
            </div>

            <div>
              <label for="date_fin" class="text-sm text-gray-600">Au</label>
              <input type="date" name="date_fin" id="date_fin" 
                     class="form-control form-control-sm"
                     value="<?php echo $filters['date_fin'] !== null ? $filters['date_fin'] : ''; ?>">
            </div>
            

            <div class="flex gap-2">
              <button type="submit" class="btn btn-sm btn-primary">
                <i class="ti ti-filter"></i> Filtrer
              </button>
              <a href="<?php echo $_SERVER['PHP_SELF']; ?>?per_page=<?php echo $itemsPerPage; ?>" 
                 class="btn btn-sm btn-secondary">
                <i class="ti ti-x"></i> Réinitialiser
              </a>
              <button type="button" id="export-excel" class="btn btn-sm btn-success">
                <i class="ti ti-download"></i> Exporter Excel
              </button>
            </div>
          </form>
        </div>

        <!-- Contrôles de pagination -->
        <div class="d-flex justify-content-between align-items-center mb-3">
          <div class="d-flex align-items-center gap-2">
            <span> </span>
            <select id="per-page-select" class="form-control" style="width: 80px; height: 32px; padding: 4px 8px;">
              <option value="5" <?php echo $itemsPerPage == 5 ? 'selected' : ''; ?>>5</option>
              <option value="10" <?php echo $itemsPerPage == 10 ? 'selected' : ''; ?>>10</option>
              <option value="25" <?php echo $itemsPerPage == 25 ? 'selected' : ''; ?>>25</option>
              <option value="50" <?php echo $itemsPerPage == 50 ? 'selected' : ''; ?>>50</option>
              <option value="100" <?php echo $itemsPerPage == 100 ? 'selected' : ''; ?>>100</option>
            </select>
            <span> </span>
          </div>
          
          <?php if ($totalItems > 0): ?>
          <div>
            Affichage de <?php echo min(($currentPage - 1) * $itemsPerPage + 1, $totalItems); ?> 
            à <?php echo min($currentPage * $itemsPerPage, $totalItems); ?> 
            sur <?php echo $totalItems; ?> entrées
          </div>
          <?php endif; ?>
        </div>

        <div class="table-responsive">
          <table id="table-patients" class="table table-hover table-bordered nowrap w-100">
            <thead class="thead-dark">
              <tr>
                <th>ID</th>
                <th>Nom</th>
                <th>Prénom</th>
                <th>Sexe</th>
                <th>Date de Naissance</th>
                <th>Âge</th>
                <th>Taille (cm)</th>
                <th>Poids (kg)</th>
                <th>Date Création</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              
              <?php if ($totalItems > 0): ?>
                <?php while ($row = $mainStmt->fetch()): ?>
                  <tr>
                      <td><?php echo htmlspecialchars($row['id_patient']); ?></td>
                      <td><?php echo htmlspecialchars($row['nom']); ?></td>
                      <td><?php echo htmlspecialchars($row['prenom']); ?></td>
                      <td><?php echo htmlspecialchars($row['sexe']); ?></td>
                      <td><?php echo date('d/m/Y', strtotime($row['date_naissance'])); ?></td>
                      <td><?php echo $row['age']; ?> ans</td>
                      <td><?php echo $row['taille']; ?> cm</td>
                      <td><?php echo $row['poids']; ?> kg</td>
                      <td><?php echo date('d/m/Y', strtotime($row['date_creation'])); ?></td>
                      <td>
                        <a href='details_patient.php?id=<?php echo $row['id_patient']; ?>' 
                           class='btn btn-sm btn-success' title="Voir détails">
                          <i class='ti ti-eye'></i>
                        </a>
                        <a href='modifier_patient.php?id=<?php echo $row['id_patient']; ?>' 
                           class='btn btn-sm btn-primary' title="Modifier">
                          <i class='ti ti-edit'></i>
                        </a>
                        <a href='supprimer_patient.php?id=<?php echo $row['id_patient']; ?>' 
                           class='btn btn-sm btn-danger' title="Supprimer"
                           onclick="return confirm('Confirmer la suppression ?');">
                          <i class='ti ti-trash'></i>
                        </a>
                      </td>
                  </tr>
                <?php endwhile; ?>
              <?php else: ?>
                <tr>
                  <td colspan="10" class="text-center py-4">
                    <i class="ti ti-search text-muted" style="font-size: 2rem;"></i>
                    <p class="text-muted mt-2 mb-0">
                      <?php 
                      $hasFilters = array_filter($filters, function($v) { return $v !== null && $v !== ''; });
                      if (!empty($hasFilters)) {
                          echo "Aucun patient ne correspond aux critères de recherche";
                      } else {
                          echo "Aucun patient enregistré";
                      }
                      ?>
                    </p>
                  </td>
                </tr>
              <?php endif; ?>
            </tbody>
          </table>
        </div>

        <!-- Pagination -->
        <?php if ($totalPages > 1): ?>
        <div class="d-flex justify-content-between align-items-center mt-4">
          <div>
            <!-- Espace pour informations supplémentaires -->
          </div>
          
          <div class="d-flex align-items-center gap-2">
            <!-- Bouton Previous -->
            <?php if ($currentPage > 1): ?>
              <a href="<?php echo buildUrlWithFilters($currentPage - 1); ?>" 
                 class="btn btn-outline-secondary btn-sm">
                Précédent
              </a>
            <?php else: ?>
              <button class="btn btn-outline-secondary btn-sm" disabled>
                Précédent
              </button>
            <?php endif; ?>
            

            <!-- Numéros de pages -->
            <?php
            $startPage = max(1, $currentPage - 2);
            $endPage = min($totalPages, $currentPage + 2);
            
            // Afficher la première page si on est loin du début
            if ($startPage > 1): ?>
              <a href="<?php echo buildUrlWithFilters(1); ?>" 
                 class="btn btn-outline-secondary btn-sm">1</a>
              <?php if ($startPage > 2): ?>
                <span class="text-muted">...</span>
              <?php endif; ?>
            <?php endif; ?>

            <?php for ($i = $startPage; $i <= $endPage; $i++): ?>
              <a href="<?php echo buildUrlWithFilters($i); ?>" 
                 class="btn <?php echo $i == $currentPage ? 'btn-primary' : 'btn-outline-secondary'; ?> btn-sm">
                <?php echo $i; ?>
              </a>
            <?php endfor; ?>

            <!-- Afficher la dernière page si on est loin de la fin -->
            <?php if ($endPage < $totalPages): ?>
              <?php if ($endPage < $totalPages - 1): ?>
                <span class="text-muted">...</span>
              <?php endif; ?>
              <a href="<?php echo buildUrlWithFilters($totalPages); ?>" 
                 class="btn btn-outline-secondary btn-sm"><?php echo $totalPages; ?></a>
            <?php endif; ?>

            <!-- Bouton Next -->
            <?php if ($currentPage < $totalPages): ?>
              <a href="<?php echo buildUrlWithFilters($currentPage + 1); ?>" 
                 class="btn btn-outline-secondary btn-sm">
                Suivant
              </a>
            <?php else: ?>
              <button class="btn btn-outline-secondary btn-sm" disabled>
                Suivant
              </button>
            <?php endif; ?>
          </div>
        </div>
        <?php endif; ?>

      </div>
    </div>
  </div>
</div>

<?php include 'includes/footer.php'; ?>

<script>
$(document).ready(function () {
    // Configuration DataTable simple (pas de filtrage JS, juste pour l'export)
    const table = $('#table-patients').DataTable({
        paging: false,
        searching: false,
        info: false,
        ordering: false,
        dom: 'Bt',
        buttons: [
            {
                extend: 'excelHtml5',
                text: '<i class="ti ti-download"></i> Excel',
                className: 'btn btn-success btn-sm d-none',
                title: 'Liste des Patients - ' + new Date().toLocaleDateString('fr-FR'),
                exportOptions: {
                    columns: ':not(:last-child)' // Exclure la colonne Actions
                }
            }
        ],
        language: {
            "processing": "Traitement en cours...",
            "loadingRecords": "Chargement en cours...",
            "zeroRecords": "Aucun patient trouvé",
            "emptyTable": "Aucune donnée disponible"
        }
    });

    // Gestionnaire pour le changement du nombre d'éléments par page
    $('#per-page-select').on('change', function() {
        const perPage = $(this).val();
        const currentUrl = new URL(window.location.href);
        currentUrl.searchParams.set('per_page', perPage);
        currentUrl.searchParams.set('page', '1');
        window.location.href = currentUrl.toString();
    });

    // Export Excel
    $('#export-excel').on('click', function(e) {
        e.preventDefault();
        table.button(0).trigger();
    });

    // Validation des champs min/max côté client
    function validateMinMax(minId, maxId, label) {
        const minVal = parseFloat($(minId).val());
        const maxVal = parseFloat($(maxId).val());
        
        if (!isNaN(minVal) && !isNaN(maxVal) && minVal > maxVal) {
            alert(`La valeur minimum de ${label} ne peut pas être supérieure à la valeur maximum`);
            return false;
        }
        return true;
    }

    // Validation avant soumission du formulaire
    $('form').on('submit', function(e) {
        let isValid = true;
        
        isValid &= validateMinMax('#age_min', '#age_max', 'l\'âge');
        isValid &= validateMinMax('#taille_min', '#taille_max', 'la taille');
        isValid &= validateMinMax('#poids_min', '#poids_max', 'le poids');
        
        // Validation des dates
        const dateDebut = $('#date_debut').val();
        const dateFin = $('#date_fin').val();
        
        if (dateDebut && dateFin && new Date(dateDebut) > new Date(dateFin)) {
            alert('La date de début ne peut pas être postérieure à la date de fin');
            isValid = false;
        }
        
        if (!isValid) {
            e.preventDefault();
        }
    });

    // Validation en temps réel
    $('#age_min, #age_max').on('blur', function() {
        validateMinMax('#age_min', '#age_max', 'l\'âge');
    });

    $('#taille_min, #taille_max').on('blur', function() {
        validateMinMax('#taille_min', '#taille_max', 'la taille');
    });

    $('#poids_min, #poids_max').on('blur', function() {
        validateMinMax('#poids_min', '#poids_max', 'le poids');
    });
});
</script>