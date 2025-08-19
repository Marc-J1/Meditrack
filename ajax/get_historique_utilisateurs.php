<?php
session_start();
require_once '../db.php';

// Vérification de l'accès admin
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'admin') {
    http_response_code(403);
    exit(json_encode(['error' => 'Accès refusé']));
}

// Paramètres DataTables
$draw = intval($_POST['draw']);
$start = intval($_POST['start']);
$length = intval($_POST['length']);
$search_value = $_POST['search']['value'];

// Filtres spécifiques
$date_debut = $_POST['date_debut'] ?? '';
$date_fin = $_POST['date_fin'] ?? '';
$action_type = $_POST['action_type'] ?? '';
$utilisateur_cible = $_POST['utilisateur_cible'] ?? '';

// Colonnes pour le tri
$columns = [
    0 => 'date_action',
    1 => 'action_type',
    2 => 'nom_utilisateur_cible',
    3 => 'nom_utilisateur_auteur',
    4 => 'details_action',
    5 => 'adresse_ip'
];

$order_column = $columns[$_POST['order'][0]['column']] ?? 'date_action';
$order_dir = $_POST['order'][0]['dir'] === 'asc' ? 'ASC' : 'DESC';

try {
    // Requête de base
    $base_query = "FROM historique_utilisateurs h";
    
    // Conditions de recherche
    $where_conditions = [];
    $params = [];
    
    // Filtres spécifiques
    if (!empty($date_debut)) {
        $where_conditions[] = "DATE(h.date_action) >= ?";
        $params[] = $date_debut;
    }
    
    if (!empty($date_fin)) {
        $where_conditions[] = "DATE(h.date_action) <= ?";
        $params[] = $date_fin;
    }
    
    if (!empty($action_type)) {
        $where_conditions[] = "h.action_type = ?";
        $params[] = $action_type;
    }
    
    if (!empty($utilisateur_cible)) {
        $where_conditions[] = "h.nom_utilisateur_cible LIKE ?";
        $params[] = "%$utilisateur_cible%";
    }
    
    // Recherche globale
    if (!empty($search_value)) {
        $where_conditions[] = "(h.nom_utilisateur_cible LIKE ? OR h.nom_utilisateur_auteur LIKE ? OR h.details_action LIKE ? OR h.adresse_ip LIKE ?)";
        $params[] = "%$search_value%";
        $params[] = "%$search_value%";
        $params[] = "%$search_value%";
        $params[] = "%$search_value%";
    }
    
    $where_clause = "";
    if (!empty($where_conditions)) {
        $where_clause = "WHERE " . implode(" AND ", $where_conditions);
    }
    
    // Requête pour compter le total
    $total_query = "SELECT COUNT(*) $base_query $where_clause";
    $total_stmt = $pdo->prepare($total_query);
    $total_stmt->execute($params);
    $total_records = $total_stmt->fetchColumn();
    
    // Requête principale avec pagination
    $main_query = "SELECT h.* $base_query $where_clause ORDER BY $order_column $order_dir LIMIT $length OFFSET $start";
    $main_stmt = $pdo->prepare($main_query);
    $main_stmt->execute($params);
    $historiques = $main_stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Formatage des données
    $data = [];
    foreach ($historiques as $historique) {
        $data[] = [
            'id' => $historique['id'],
            'date_action' => $historique['date_action'],
            'action_type' => $historique['action_type'],
            'nom_utilisateur_cible' => htmlspecialchars($historique['nom_utilisateur_cible']),
            'prenom_utilisateur_cible' => htmlspecialchars($historique['prenom_utilisateur_cible'] ?? ''),
            'nom_utilisateur_auteur' => htmlspecialchars($historique['nom_utilisateur_auteur']),
            'details_action' => htmlspecialchars($historique['details_action']),
            'adresse_ip' => $historique['adresse_ip'],
            'user_agent' => $historique['user_agent'],
            'donnees_avant' => $historique['donnees_avant'],
            'donnees_apres' => $historique['donnees_apres']
        ];
    }
    
    // Réponse JSON pour DataTables
    $response = [
        'draw' => $draw,
        'recordsTotal' => $total_records,
        'recordsFiltered' => $total_records,
        'data' => $data
    ];
    
    header('Content-Type: application/json');
    echo json_encode($response);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
}
?>