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
$search_value = $_POST['search']['value'] ?? '';

// Filtres spécifiques
$date_debut = $_POST['date_debut'] ?? '';
$date_fin = $_POST['date_fin'] ?? '';
$utilisateur = $_POST['utilisateur'] ?? '';
$action_type = $_POST['action_type'] ?? '';
$page = $_POST['page'] ?? '';

// Colonnes pour le tri (pointent maintenant sur l'alias commun `a`)
$columns = [
    0 => 'a.date_action',
    1 => 'a.username',
    2 => 'a.action_type',
    3 => 'a.page_visitee',
    4 => 'a.details_action',
    5 => 'a.adresse_ip',
    6 => 'a.session_id'
];

$order_column_index = $_POST['order'][0]['column'] ?? 0;
$order_column = $columns[$order_column_index] ?? 'a.date_action';
$order_dir = ($_POST['order'][0]['dir'] ?? 'desc') === 'asc' ? 'ASC' : 'DESC';

try {
    // Requête de base : UNION user_activity + historique_utilisateurs
    $base_query = "FROM (
        SELECT
            ua.date_action,
            ua.username,
            ua.action_type,
            ua.page_visitee,
            ua.details_action,
            ua.adresse_ip,
            ua.session_id
        FROM user_activity ua

        UNION ALL

        SELECT
            h.date_action,
            COALESCE(h.nom_utilisateur_auteur, u.username) AS username,
            h.action_type,
            NULL AS page_visitee,          -- pas de page pour historique
            h.details_action,
            h.adresse_ip,
            NULL AS session_id             -- pas de session pour historique
        FROM historique_utilisateurs h
        LEFT JOIN users u ON u.id_utilisateur = h.id_utilisateur_auteur
    ) a";

    // Conditions de recherche
    $where_conditions = [];
    $params = [];

    // Filtres spécifiques (référencent `a`)
    if (!empty($date_debut)) {
        $where_conditions[] = "DATE(a.date_action) >= ?";
        $params[] = $date_debut;
    }

    if (!empty($date_fin)) {
        $where_conditions[] = "DATE(a.date_action) <= ?";
        $params[] = $date_fin;
    }

    if (!empty($utilisateur)) {
        $where_conditions[] = "a.username LIKE ?";
        $params[] = "%$utilisateur%";
    }

    if (!empty($action_type)) {
        $where_conditions[] = "a.action_type = ?";
        $params[] = $action_type;
    }

    if (!empty($page)) {
        $where_conditions[] = "a.page_visitee LIKE ?";
        $params[] = "%$page%";
    }

    // Recherche globale
    if (!empty($search_value)) {
        $where_conditions[] = "(a.username LIKE ? OR a.action_type LIKE ? OR a.page_visitee LIKE ? OR a.details_action LIKE ? OR a.adresse_ip LIKE ?)";
        $params[] = "%$search_value%";
        $params[] = "%$search_value%";
        $params[] = "%$search_value%";
        $params[] = "%$search_value%";
        $params[] = "%$search_value%";
    }

    // Génération du WHERE final
    $where_clause = !empty($where_conditions) ? "WHERE " . implode(" AND ", $where_conditions) : "";

    // Requête total filtrée (on garde ton comportement existant)
    $total_query = "SELECT COUNT(*) $base_query $where_clause";
    $total_stmt = $pdo->prepare($total_query);
    $total_stmt->execute($params);
    $total_records = $total_stmt->fetchColumn();

    // Requête principale
    $main_query = "SELECT a.* $base_query $where_clause ORDER BY $order_column $order_dir LIMIT $length OFFSET $start";
    $main_stmt = $pdo->prepare($main_query);
    $main_stmt->execute($params);
    $activities = $main_stmt->fetchAll(PDO::FETCH_ASSOC);

    // Formatage final (inchangé)
    $data = [];
    foreach ($activities as $activity) {
        $data[] = [
            'id' => $activity['id'] ?? null, // côté historique il peut ne pas y avoir d'id homogène
            'date_action' => $activity['date_action'],
            'username' => htmlspecialchars($activity['username'] ?? ''),
            'action_type' => $activity['action_type'] ?? '',
            'page_visitee' => htmlspecialchars($activity['page_visitee'] ?? ''),
            'details_action' => htmlspecialchars($activity['details_action'] ?? ''),
            'adresse_ip' => $activity['adresse_ip'] ?? '',
            'session_id' => $activity['session_id'] ?? '',
            'user_agent' => $activity['user_agent'] ?? '',
            'duree_session' => $activity['duree_session'] ?? ''
        ];
    }

    // Réponse JSON
    echo json_encode([
        'draw' => $draw,
        'recordsTotal' => $total_records,
        'recordsFiltered' => $total_records,
        'data' => $data
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
}
