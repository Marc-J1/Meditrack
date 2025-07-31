<?php
// Configuration du système de chat médical
// chat_config.php

class ChatConfig {
    
    // Paramètres généraux
    const MAX_MESSAGE_LENGTH = 1000;
    const MESSAGES_PER_PAGE = 50;
    const POLLING_INTERVAL = 3000; // millisecondes
    const TYPING_TIMEOUT = 2000; // millisecondes
    
    // Paramètres de sécurité
    const ALLOWED_ROLES = ['admin', 'medecin'];
    const ENABLE_MESSAGE_ENCRYPTION = false;
    const LOG_CHAT_ACTIVITY = true;
    
    // Paramètres d'affichage
    const SHOW_TYPING_INDICATOR = true;
    const SHOW_READ_RECEIPTS = true;
    const ENABLE_EMOJI = true;
    const ENABLE_FILE_UPLOAD = false; // À implémenter si nécessaire
    
    // Couleurs par rôle
    const ROLE_COLORS = [
        'admin' => [
            'primary' => '#f093fb',
            'secondary' => '#f5576c',
            'gradient' => 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)'
        ],
        'medecin' => [
            'primary' => '#4facfe',
            'secondary' => '#00f2fe', 
            'gradient' => 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)'
        ]
    ];
    
    // Messages système
    const SYSTEM_MESSAGES = [
        'welcome' => 'Bienvenue dans l\'espace de discussion médicale',
        'user_joined' => '%s a rejoint la discussion',
        'user_left' => '%s a quitté la discussion',
        'chat_cleared' => 'L\'historique des messages a été effacé',
        'maintenance' => 'Le chat est temporairement en maintenance'
    ];
    
    // Paramètres de notification
    const ENABLE_BROWSER_NOTIFICATIONS = true;
    const NOTIFICATION_SOUND = true;
    const DESKTOP_NOTIFICATIONS = true;
    
    /**
     * Vérifier si un utilisateur peut accéder au chat
     */
    public static function canUserAccessChat($user_role, $user_status = null) {
        // Vérifier le rôle
        if (!in_array($user_role, self::ALLOWED_ROLES)) {
            return false;
        }
        
        // Pour les médecins, vérifier le statut
        if ($user_role === 'medecin') {
            return in_array($user_status, ['principal', 'interimaire']);
        }
        
        return true;
    }
    
    /**
     * Obtenir la couleur selon le rôle
     */
    public static function getRoleColor($role, $type = 'gradient') {
        return self::ROLE_COLORS[$role][$type] ?? self::ROLE_COLORS['medecin'][$type];
    }
    
    /**
     * Valider un message
     */
    public static function validateMessage($message) {
        $errors = [];
        
        if (empty(trim($message))) {
            $errors[] = 'Le message ne peut pas être vide';
        }
        
        if (strlen($message) > self::MAX_MESSAGE_LENGTH) {
            $errors[] = 'Le message est trop long (max ' . self::MAX_MESSAGE_LENGTH . ' caractères)';
        }
        
        // Vérifier le contenu inapproprié (basique)
        $forbidden_words = ['spam', 'test_forbidden']; // À adapter selon vos besoins
        foreach ($forbidden_words as $word) {
            if (stripos($message, $word) !== false) {
                $errors[] = 'Le message contient du contenu inapproprié';
                break;
            }
        }
        
        return $errors;
    }
    
    /**
     * Logger l'activité du chat
     */
    public static function logActivity($user_id, $action, $details = '') {
        if (!self::LOG_CHAT_ACTIVITY) {
            return;
        }
        
        $log_entry = [
            'timestamp' => date('Y-m-d H:i:s'),
            'user_id' => $user_id,
            'action' => $action,
            'details' => $details,
            'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
        ];
        
        // Écrire dans le fichier de log
        $log_file = __DIR__ . '/logs/chat_activity.log';
        $log_dir = dirname($log_file);
        
        if (!is_dir($log_dir)) {
            mkdir($log_dir, 0755, true);
        }
        
        file_put_contents(
            $log_file, 
            json_encode($log_entry) . "\n", 
            FILE_APPEND | LOCK_EX
        );
    }
    
    /**
     * Nettoyer les anciens messages (à exécuter périodiquement)
     */
    public static function cleanOldMessages($pdo, $days = 90) {
        try {
            $stmt = $pdo->prepare("
                DELETE FROM chat_messages 
                WHERE date_message < DATE_SUB(NOW(), INTERVAL ? DAY)
                AND type_message != 'system'
            ");
            $stmt->execute([$days]);
            
            self::logActivity(0, 'cleanup', "Supprimé les messages de plus de {$days} jours");
            
            return $stmt->rowCount();
        } catch (PDOException $e) {
            error_log("Erreur lors du nettoyage des messages: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Obtenir les statistiques détaillées
     */
    public static function getDetailedStats($pdo) {
        try {
            $stats = [];
            
            // Messages par jour (7 derniers jours)
            $stmt = $pdo->prepare("
                SELECT DATE(date_message) as date, COUNT(*) as count
                FROM chat_messages
                WHERE date_message >= DATE_SUB(NOW(), INTERVAL 7 DAY)
                GROUP BY DATE(date_message)
                ORDER BY date DESC
            ");
            $stmt->execute();
            $stats['messages_by_day'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Utilisateurs les plus actifs
            $stmt = $pdo->prepare("
                SELECT u.username, u.role, COUNT(cm.id_message) as message_count
                FROM users u
                JOIN chat_messages cm ON u.id_utilisateur = cm.id_utilisateur
                WHERE cm.date_message >= DATE_SUB(NOW(), INTERVAL 30 DAY)
                GROUP BY u.id_utilisateur
                ORDER BY message_count DESC
                LIMIT 10
            ");
            $stmt->execute();
            $stats['top_users'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Heures de pointe
            $stmt = $pdo->prepare("
                SELECT HOUR(date_message) as hour, COUNT(*) as count
                FROM chat_messages
                WHERE date_message >= DATE_SUB(NOW(), INTERVAL 30 DAY)
                GROUP BY HOUR(date_message)
                ORDER BY count DESC
            ");
            $stmt->execute();
            $stats['peak_hours'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            return $stats;
        } catch (PDOException $e) {
            error_log("Erreur lors de la récupération des statistiques: " . $e->getMessage());
            return [];
        }
    }
}

// Constantes globales pour faciliter l'utilisation
define('CHAT_MAX_MESSAGE_LENGTH', ChatConfig::MAX_MESSAGE_LENGTH);
define('CHAT_POLLING_INTERVAL', ChatConfig::POLLING_INTERVAL);
define('CHAT_ALLOWED_ROLES', ChatConfig::ALLOWED_ROLES);
?>