<?php
session_start();
require_once '../db.php';

// Vérification de l'accès admin
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'admin') {
    http_response_code(403);
    exit(json_encode(['error' => 'Accès refusé']));
}

// Paramètres DataTables
$draw = intval($_POST['draw'] ?? 0);
$start = intval($_POST['start'] ?? 0);
$length = intval($_POST['length'] ?? 25);
$search_value = $_POST['search']['value'] ?? '';

try {
    // ✅ Version SIMPLE pour commencer - Seulement les données de base
    $where_clause = "WHERE u.role = 'medecin'";
    $params = [];
    
    if (!empty($search_value)) {
        $where_clause .= " AND (u.username LIKE ? OR u.role LIKE ?)";
        $params[] = "%$search_value%";
        $params[] = "%$search_value%"; 
    }
    
    // Compter le total
    $total_query = "SELECT COUNT(*) FROM users u " . $where_clause;
    $total_stmt = $pdo->prepare($total_query);
    $total_stmt->execute($params);
    $total_records = $total_stmt->fetchColumn();
    
    // Requête principale - VERSION SIMPLE
    $main_query = "
    SELECT 
        u.id_utilisateur,
        u.username,
        u.role,
        u.statut,
        u.date_creation,
        NULL as derniere_activite,
        'aucune' as statut_session,
        NULL as derniere_ip,
        0 as connexions_semaine,
        0 as actions_aujourdhui
    FROM users u 
    " . $where_clause . "
    ORDER BY u.username ASC
    LIMIT " . $length . " OFFSET " . $start;
    
    $main_stmt = $pdo->prepare($main_query);
    $main_stmt->execute($params);
    $users = $main_stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Maintenant essayons d'enrichir avec les données d'activité
    foreach ($users as $key => &$user) {
        // Dernière activité
        try {
            $activity_query = "SELECT MAX(date_action) as derniere_activite, adresse_ip 
                              FROM user_activity 
                              WHERE id_utilisateur = ? 
                              ORDER BY date_action DESC LIMIT 1";
            $activity_stmt = $pdo->prepare($activity_query);
            $activity_stmt->execute([$user['id_utilisateur']]);
            $activity = $activity_stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($activity) {
                $user['derniere_activite'] = $activity['derniere_activite'];
                $user['derniere_ip'] = $activity['adresse_ip'];
            }
        } catch (Exception $e) {
            // Ignorer les erreurs d'activité
        }
        
        // Sessions actives
        try {
            $session_query = "SELECT statut_session FROM user_sessions 
                             WHERE id_utilisateur = ? AND statut_session = 'active' LIMIT 1";
            $session_stmt = $pdo->prepare($session_query);
            $session_stmt->execute([$user['id_utilisateur']]);
            $session = $session_stmt->fetch();
            
            if ($session) {
                $user['statut_session'] = 'active';
            }
        } catch (Exception $e) {
            // Ignorer les erreurs de session
        }
        
        // Connexions de la semaine
        try {
            $conn_query = "SELECT COUNT(*) as count FROM user_activity 
                          WHERE id_utilisateur = ? 
                          AND action_type IN ('connexion', 'login')
                          AND DATE(date_action) >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)";
            $conn_stmt = $pdo->prepare($conn_query);
            $conn_stmt->execute([$user['id_utilisateur']]);
            $conn_count = $conn_stmt->fetchColumn();
            $user['connexions_semaine'] = (int)$conn_count;
        } catch (Exception $e) {
            // Ignorer
        }
        
        // Actions d'aujourd'hui
        try {
            $actions_query = "SELECT COUNT(*) as count FROM user_activity 
                             WHERE id_utilisateur = ? 
                             AND DATE(date_action) = CURDATE()";
            $actions_stmt = $pdo->prepare($actions_query);
            $actions_stmt->execute([$user['id_utilisateur']]);
            $actions_count = $actions_stmt->fetchColumn();
            $user['actions_aujourdhui'] = (int)$actions_count;
        } catch (Exception $e) {
            // Ignorer
        }
    }
    
    // ✅ Formatage des données 
    $data = [];
    foreach ($users as $user) {
        $data[] = [
            'id_utilisateur' => (int)$user['id_utilisateur'],
            'username' => $user['username'] ?: '', 
            'role' => $user['role'] ?: '', 
            'statut' => $user['statut'] ?: '', 
            'date_creation' => $user['date_creation'],
            'derniere_activite' => $user['derniere_activite'], 
            'statut_session' => $user['statut_session'] ?: 'aucune',
            'derniere_ip' => $user['derniere_ip'] ?: '',
            'connexions_semaine' => (int)($user['connexions_semaine'] ?: 0),
            'actions_aujourdhui' => (int)($user['actions_aujourdhui'] ?: 0)
        ];
    }
    
    // ✅ Réponse JSON 
    $response = [
        'draw' => (int)$draw,
        'recordsTotal' => (int)$total_records,
        'recordsFiltered' => (int)$total_records, 
        'data' => $data,
        'debug' => [
            'version' => 'simple',
            'total_users_found' => count($users),
            'search_term' => $search_value,
            'sample_user' => count($users) > 0 ? $users[0] : null
        ]
    ];
    
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-cache, must-revalidate');
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    error_log("Erreur BDD get_users_activity.php: " . $e->getMessage());
    http_response_code(500);
    
    $error_response = [
        'error' => 'Erreur base de données: ' . $e->getMessage(),
        'draw' => (int)$draw,
        'recordsTotal' => 0,
        'recordsFiltered' => 0,
        'data' => [],
        'debug' => [
            'sql_error' => $e->getMessage(),
            'sql_code' => $e->getCode(),
            'query_attempted' => 'simple version'
        ]
    ];
    
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($error_response);
    
} catch (Exception $e) {
    error_log("Erreur générale get_users_activity.php: " . $e->getMessage());
    http_response_code(500);
    
    $error_response = [
        'error' => 'Erreur serveur: ' . $e->getMessage(),
        'draw' => (int)$draw,
        'recordsTotal' => 0,
        'recordsFiltered' => 0,
        'data' => [],
        'debug' => [
            'error_message' => $e->getMessage(),
            'error_line' => $e->getLine(),
            'version' => 'simple'
        ]
    ];
    
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($error_response);
}
?>