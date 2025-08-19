<?php
require_once '../db.php';

session_start();
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'admin') {
    http_response_code(403);
    echo '<div class="alert alert-danger">Accès refusé</div>';
    exit();
}

$id = intval($_POST['id'] ?? 0);
$type = $_POST['type'] ?? '';

if (!$id || !$type) {
    echo '<div class="alert alert-warning">Paramètres manquants</div>';
    exit();
}

try {
    if ($type === 'utilisateur') {
        $sql = "SELECT 
                    hu.*,
                    u.id_utilisateur as user_exists,
                    u.statut as current_status
                FROM historique_utilisateurs hu
                LEFT JOIN users u ON hu.id_utilisateur_cible = u.id_utilisateur
                WHERE hu.id = ?";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$id]);
        $record = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$record) {
            echo '<div class="alert alert-danger">Enregistrement non trouvé</div>';
            exit();
        }
        
        // Déterminer le statut de l'utilisateur
        $userStatus = 'Actif';
        $statusClass = 'success';
        
        if (!$record['user_exists']) {
            $userStatus = 'SUPPRIMÉ';
            $statusClass = 'danger';
        } elseif ($record['current_status'] === 'inactif') {
            $userStatus = 'Inactif';
            $statusClass = 'warning';
        }
        
        echo '<div class="row">';
        
        // Informations générales
        echo '<div class="col-md-6">';
        echo '<h6 class="text-primary"><i class="fas fa-info-circle me-2"></i>Informations générales</h6>';
        echo '<table class="table table-sm table-borderless">';
        echo '<tr><td><strong>Date/Heure:</strong></td><td>' . date('d/m/Y H:i:s', strtotime($record['date_action'])) . '</td></tr>';
        echo '<tr><td><strong>Action:</strong></td><td><span class="badge bg-' . getActionBadgeClass($record['action_type']) . '">' . strtoupper($record['action_type']) . '</span></td></tr>';
        echo '<tr><td><strong>Utilisateur concerné:</strong></td><td>' . htmlspecialchars($record['nom_utilisateur_cible']) . ' <span class="badge bg-' . $statusClass . ' ms-1">' . $userStatus . '</span></td></tr>';
        echo '<tr><td><strong>Auteur de l\'action:</strong></td><td>' . htmlspecialchars($record['nom_utilisateur_auteur'] ?: 'Système') . '</td></tr>';
        echo '<tr><td><strong>Adresse IP:</strong></td><td><code>' . htmlspecialchars($record['adresse_ip']) . '</code></td></tr>';
        echo '</table>';
        echo '</div>';
        
        // Détails techniques
        echo '<div class="col-md-6">';
        echo '<h6 class="text-primary"><i class="fas fa-cog me-2"></i>Détails techniques</h6>';
        echo '<table class="table table-sm table-borderless">';
        echo '<tr><td><strong>ID Enregistrement:</strong></td><td>#' . $record['id'] . '</td></tr>';
        echo '<tr><td><strong>ID Utilisateur cible:</strong></td><td>' . ($record['id_utilisateur_cible'] ?: 'N/A') . '</td></tr>';
        echo '<tr><td><strong>ID Utilisateur auteur:</strong></td><td>' . ($record['id_utilisateur_auteur'] ?: 'N/A') . '</td></tr>';
        echo '<tr><td><strong>User Agent:</strong></td><td><small>' . htmlspecialchars(substr($record['user_agent'] ?: 'Non disponible', 0, 50)) . '...</small></td></tr>';
        echo '</table>';
        echo '</div>';
        
        echo '</div>'; // End row
        
        // Description de l'action
        if ($record['details_action']) {
            echo '<div class="row mt-3">';
            echo '<div class="col-12">';
            echo '<h6 class="text-primary"><i class="fas fa-file-alt me-2"></i>Description de l\'action</h6>';
            echo '<div class="alert alert-light">';
            echo '<pre class="mb-0" style="white-space: pre-wrap;">' . htmlspecialchars($record['details_action']) . '</pre>';
            echo '</div>';
            echo '</div>';
            echo '</div>';
        }
        
        // Données avant/après si disponibles
        if ($record['donnees_avant'] || $record['donnees_apres']) {
            echo '<div class="row mt-3">';
            
            if ($record['donnees_avant']) {
                echo '<div class="col-md-6">';
                echo '<h6 class="text-danger"><i class="fas fa-arrow-left me-2"></i>Données avant modification</h6>';
                echo '<div class="alert alert-danger alert-sm">';
                
                $dataBefore = json_decode($record['donnees_avant'], true);
                if ($dataBefore) {
                    echo '<table class="table table-sm table-borderless text-dark">';
                    foreach ($dataBefore as $key => $value) {
                        if (stripos($key, 'password') !== false || stripos($key, 'mdp') !== false) {
                            $value = '***masqué***';
                        }
                        echo '<tr><td><strong>' . htmlspecialchars($key) . ':</strong></td><td>' . htmlspecialchars($value) . '</td></tr>';
                    }
                    echo '</table>';
                } else {
                    echo '<pre class="mb-0">' . htmlspecialchars($record['donnees_avant']) . '</pre>';
                }
                echo '</div>';
                echo '</div>';
            }
            
            if ($record['donnees_apres']) {
                echo '<div class="col-md-6">';
                echo '<h6 class="text-success"><i class="fas fa-arrow-right me-2"></i>Données après modification</h6>';
                echo '<div class="alert alert-success alert-sm">';
                
                $dataAfter = json_decode($record['donnees_apres'], true);
                if ($dataAfter) {
                    echo '<table class="table table-sm table-borderless text-dark">';
                    foreach ($dataAfter as $key => $value) {
                        if (stripos($key, 'password') !== false || stripos($key, 'mdp') !== false) {
                            $value = '***masqué***';
                        }
                        echo '<tr><td><strong>' . htmlspecialchars($key) . ':</strong></td><td>' . htmlspecialchars($value) . '</td></tr>';
                    }
                    echo '</table>';
                } else {
                    echo '<pre class="mb-0">' . htmlspecialchars($record['donnees_apres']) . '</pre>';
                }
                echo '</div>';
                echo '</div>';
            }
            
            echo '</div>'; // End row
        }
        
        // Alerte si utilisateur supprimé
        if (!$record['user_exists']) {
            echo '<div class="alert alert-warning mt-3">';
            echo '<i class="fas fa-exclamation-triangle me-2"></i>';
            echo '<strong>Attention:</strong> L\'utilisateur concerné par cette action a été supprimé du système. ';
            echo 'Cette trace est conservée de manière permanente à des fins d\'audit.';
            echo '</div>';
        }
        
    } else {
        echo '<div class="alert alert-warning">Type d\'historique non supporté</div>';
    }
    
} catch (Exception $e) {
    error_log("Erreur get_details_historique: " . $e->getMessage());
    echo '<div class="alert alert-danger">Erreur lors du chargement des détails: ' . htmlspecialchars($e->getMessage()) . '</div>';
}

function getActionBadgeClass($actionType) {
    switch ($actionType) {
        case 'ajout':
        case 'creation':
            return 'success';
        case 'modification':
            return 'warning';
        case 'suppression':
        case 'supprime':
            return 'danger';
        case 'changement_statut':
            return 'info';
        case 'reinitialisation_mdp':
            return 'primary';
        default:
            return 'secondary';
    }
}
?>