<?php
session_start();
require_once 'db.php';

// Vérifier que l'utilisateur est connecté et autorisé
if (!isset($_SESSION['user']) || !in_array($_SESSION['user']['role'], ['admin', 'medecin'])) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Non autorisé']);
    exit();
}

$user_id = $_SESSION['user']['id_utilisateur'];
$user_role = $_SESSION['user']['role'];
$username = $_SESSION['user']['username'];

// Définir le type de contenu JSON
header('Content-Type: application/json');

try {
    // Récupérer l'action demandée
    $action = $_GET['action'] ?? $_POST['action'] ?? '';
    
    switch ($action) {
        case 'send_message':
            sendMessage($pdo, $user_id);
            break;
            
        case 'get_messages':
            getMessages($pdo, $user_id);
            break;
            
        case 'get_stats':
            getStats($pdo, $user_id);
            break;
            
        default:
            throw new Exception('Action non reconnue');
    }
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}

function sendMessage($pdo, $user_id) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['message']) || empty(trim($input['message']))) {
        throw new Exception('Message vide');
    }
    
    $message = trim($input['message']);
    
    // Limiter la longueur du message
    if (strlen($message) > 1000) {
        throw new Exception('Message trop long (max 1000 caractères)');
    }
    
    // Nettoyer le message (protection XSS basique)
    $message = htmlspecialchars($message, ENT_QUOTES, 'UTF-8');
    
    try {
        $stmt = $pdo->prepare("
    INSERT INTO chat_messages (id_utilisateur, message, date_message, statut, type_message) 
    VALUES (?, ?, NOW(), 'non_lu', 'text')
");

        
        $stmt->execute([$user_id, $message]);

        
        $message_id = $pdo->lastInsertId();
        
        echo json_encode([
            'success' => true,
            'message_id' => $message_id,
            'message' => 'Message envoyé avec succès'
        ]);
        
    } catch (PDOException $e) {
        throw new Exception('Erreur lors de l\'envoi du message');
    }
}

function getMessages($pdo, $user_id) {
    $last_id = isset($_GET['last_id']) ? (int)$_GET['last_id'] : 0;
    
    try {
        $stmt = $pdo->prepare("
            SELECT 
                cm.id_message,
                cm.id_utilisateur,
                cm.message,
                cm.date_message,
                cm.type_message,
                u.username,
                u.role
            FROM chat_messages cm
            JOIN users u ON cm.id_utilisateur = u.id_utilisateur
            WHERE cm.id_message > ?
            ORDER BY cm.date_message ASC
            LIMIT 50
        ");
        
        $stmt->execute([$last_id]);
        $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Marquer les nouveaux messages comme lus pour cet utilisateur
        if (!empty($messages)) {
            $message_ids = array_column($messages, 'id_message');
            $placeholders = str_repeat('?,', count($message_ids) - 1) . '?';
            
            $read_stmt = $pdo->prepare("
                INSERT IGNORE INTO chat_message_read (id_message, id_utilisateur, date_lecture)
                VALUES " . implode(',', array_fill(0, count($message_ids), '(?, ?, NOW())'))
            );
            
            $params = [];
            foreach ($message_ids as $msg_id) {
                $params[] = $msg_id;
                $params[] = $user_id;
            }
            
            $read_stmt->execute($params);
        }
        
        echo json_encode([
            'success' => true,
            'messages' => $messages,
            'count' => count($messages)
        ]);
        
    } catch (PDOException $e) {
        throw new Exception('Erreur lors de la récupération des messages');
    }
}

function getStats($pdo, $user_id) {
    try {
        // Utilisateurs actifs (qui ont envoyé un message dans les dernières 24h)
        $active_users_stmt = $pdo->prepare("
            SELECT COUNT(DISTINCT cm.id_utilisateur) as count
            FROM chat_messages cm
            WHERE cm.date_message >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
        ");
        $active_users_stmt->execute();
        $active_users = $active_users_stmt->fetchColumn();
        
        // Messages d'aujourd'hui
        $today_messages_stmt = $pdo->prepare("
            SELECT COUNT(*) as count
            FROM chat_messages
            WHERE DATE(date_message) = CURDATE()
        ");
        $today_messages_stmt->execute();
        $today_messages = $today_messages_stmt->fetchColumn();
        
        // Messages non lus pour cet utilisateur
        $unread_stmt = $pdo->prepare("
            SELECT COUNT(*) as count
            FROM chat_messages cm
            LEFT JOIN chat_message_read cmr ON (cm.id_message = cmr.id_message AND cmr.id_utilisateur = ?)
            WHERE cm.id_utilisateur != ? AND cmr.id_message IS NULL
        ");
        $unread_stmt->execute([$user_id, $user_id]);
        $unread_messages = $unread_stmt->fetchColumn();
        
        // Dernière activité
        $last_activity_stmt = $pdo->prepare("
            SELECT MAX(date_message) as last_activity
            FROM chat_messages
        ");
        $last_activity_stmt->execute();
        $last_activity_raw = $last_activity_stmt->fetchColumn();
        
        $last_activity = 'Aucune';
        if ($last_activity_raw) {
            $last_time = new DateTime($last_activity_raw);
            $now = new DateTime();
            $diff = $now->diff($last_time);
            
            if ($diff->days > 0) {
                $last_activity = $diff->days . ' jour(s)';
            } elseif ($diff->h > 0) {
                $last_activity = $diff->h . 'h ' . $diff->i . 'min';
            } elseif ($diff->i > 0) {
                $last_activity = $diff->i . ' min';
            } else {
                $last_activity = 'Maintenant';
            }
        }
        
        echo json_encode([
            'success' => true,
            'stats' => [
                'activeUsers' => $active_users,
                'todayMessages' => $today_messages,
                'unreadMessages' => $unread_messages,
                'lastActivity' => $last_activity
            ]
        ]);
        
    } catch (PDOException $e) {
        throw new Exception('Erreur lors de la récupération des statistiques');
    }
}

// Fonction utilitaire pour nettoyer les entrées
function sanitizeInput($input) {
    return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
}

// Fonction pour vérifier les permissions
function checkPermission($required_role, $user_role) {
    $role_hierarchy = ['admin' => 3, 'medecin' => 2, 'user' => 1];
    return $role_hierarchy[$user_role] >= $role_hierarchy[$required_role];
}
?>