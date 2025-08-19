<?php
/**
 * Système de logging d'activité pour l'application médicale
 * 
 * Ce fichier contient les fonctions pour enregistrer automatiquement
 * toutes les activités des utilisateurs dans la base de données
 */

class ActivityLogger {
    private $pdo;
    
    public function __construct($pdo) {
        $this->pdo = $pdo;
    }
    
    /**
     * Enregistre une activité utilisateur
     */
    public function logActivity($userId, $username, $actionType, $pageVisited = null, $details = null, $sessionDuration = null) {
    try {
        // Appliquer la vérification anti-doublon uniquement pour les consultations
        if ($actionType === 'consultation') {
            $sqlCheck = "SELECT COUNT(*) FROM user_activity
                         WHERE id_utilisateur = ?
                           AND action_type = ?
                           AND page_visitee = ?
                           AND details_action = ?
                           AND date_action >= NOW() - INTERVAL 1 MINUTE";
            
            $stmtCheck = $this->pdo->prepare($sqlCheck);
            $stmtCheck->execute([$userId, $actionType, $pageVisited, $details]);
            $alreadyLogged = $stmtCheck->fetchColumn();

            if ($alreadyLogged > 0) {
                return false; // Ne pas enregistrer de doublon
            }
        }

        // Insérer l'activité
        $sql = "INSERT INTO user_activity (
            id_utilisateur, username, action_type, page_visitee, 
            details_action, adresse_ip, user_agent, session_id, duree_session
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([
            $userId,
            $username,
            $actionType,
            $pageVisited,
            $details,
            $this->getClientIP(),
            $this->getUserAgent(),
            session_id(),
            $sessionDuration
        ]);

        return true;
    } catch (Exception $e) {
        error_log("Erreur lors de l'enregistrement de l'activité: " . $e->getMessage());
        return false;
    }
}

    
    /**
     * Enregistre une connexion utilisateur
     */
    public function logLogin($userId, $username) {
        // Enregistrer l'activité de connexion
        $this->logActivity($userId, $username, 'connexion', 'login.php', 'Connexion réussie');
        
        // Créer ou mettre à jour la session
        $this->createOrUpdateSession($userId, $username);
        
        return true;
    }
    
    /**
     * Enregistre une déconnexion utilisateur
     */
    public function logLogout($userId, $username, $sessionDuration = null) {
        // Enregistrer l'activité de déconnexion
        $this->logActivity($userId, $username, 'deconnexion', 'logout.php', 'Déconnexion', $sessionDuration);
        
        // Fermer la session
        $this->closeSession($userId);
        
        return true;
    }
    
    /**
     * Enregistre l'accès à une page
     */
    public function logPageVisit($userId, $username, $page, $details = null) {
        return $this->logActivity($userId, $username, 'consultation', $page, $details);
    }
    
    /**
     * Enregistre une création d'élément
     */
    public function logCreation($userId, $username, $page, $details) {
        return $this->logActivity($userId, $username, 'creation', $page, $details);
    }
    
    /**
     * Enregistre une modification d'élément
     */
    public function logModification($userId, $username, $page, $details) {
        return $this->logActivity($userId, $username, 'modification', $page, $details);
    }
    
    /**
     * Enregistre une suppression d'élément
     */
    public function logSuppression($userId, $username, $page, $details) {
        return $this->logActivity($userId, $username, 'suppression', $page, $details);
    }
    
    /**
     * Enregistre une action sur les utilisateurs avec contexte
     */
    public function logUserAction($userAuthorId, $userAuthorName, $userTargetId, $userTargetName, $actionType, $details, $dataBefore = null, $dataAfter = null) {
        try {
            // Définir les variables de session pour les triggers
            $this->pdo->exec("SET @current_user_id = " . intval($userAuthorId));
            $this->pdo->exec("SET @current_username = '" . addslashes($userAuthorName) . "'");
            $this->pdo->exec("SET @current_user_ip = '" . addslashes($this->getClientIP()) . "'");
            
            $sql = "INSERT INTO historique_utilisateurs (
                id_utilisateur_cible, nom_utilisateur_cible, 
                id_utilisateur_auteur, nom_utilisateur_auteur,
                action_type, details_action, donnees_avant, donnees_apres, adresse_ip, user_agent
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([
                $userTargetId,
                $userTargetName,
                $userAuthorId,
                $userAuthorName,
                $actionType,
                $details,
                $dataBefore ? json_encode($dataBefore) : null,
                $dataAfter ? json_encode($dataAfter) : null,
                $this->getClientIP(),
                $this->getUserAgent()
            ]);
            
            return true;
        } catch (Exception $e) {
            error_log("Erreur lors de l'enregistrement de l'action utilisateur: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Crée ou met à jour une session utilisateur
     */
    private function createOrUpdateSession($userId, $username) {
        try {
            $sql = "INSERT INTO user_sessions (
                id_utilisateur, username, session_id, adresse_ip, user_agent, statut_session
            ) VALUES (?, ?, ?, ?, ?, 'active')
            ON DUPLICATE KEY UPDATE 
                derniere_activite = CURRENT_TIMESTAMP,
                statut_session = 'active',
                adresse_ip = VALUES(adresse_ip)";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([
                $userId,
                $username,
                session_id(),
                $this->getClientIP(),
                $this->getUserAgent()
            ]);
            
            return true;
        } catch (Exception $e) {
            error_log("Erreur lors de la création/mise à jour de session: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Ferme une session utilisateur
     */
    private function closeSession($userId) {
        try {
            $sql = "UPDATE user_sessions 
                    SET statut_session = 'fermee', 
                        derniere_activite = CURRENT_TIMESTAMP 
                    WHERE id_utilisateur = ? AND session_id = ?";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([$userId, session_id()]);
            
            return true;
        } catch (Exception $e) {
            error_log("Erreur lors de la fermeture de session: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Met à jour la dernière activité de l'utilisateur
     */
    public function updateLastActivity($userId) {
        try {
            $sql = "UPDATE user_sessions 
                    SET derniere_activite = CURRENT_TIMESTAMP 
                    WHERE id_utilisateur = ? AND session_id = ? AND statut_session = 'active'";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([$userId, session_id()]);
            
            return true;
        } catch (Exception $e) {
            error_log("Erreur lors de la mise à jour de l'activité: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Obtient l'adresse IP du client
     */
    private function getClientIP() {
        $ipKeys = ['HTTP_CLIENT_IP', 'HTTP_X_FORWARDED_FOR', 'REMOTE_ADDR'];
        
        foreach ($ipKeys as $key) {
            if (array_key_exists($key, $_SERVER) && !empty($_SERVER[$key])) {
                $ip = $_SERVER[$key];
                if (strpos($ip, ',') !== false) {
                    $ip = explode(',', $ip)[0];
                }
                $ip = trim($ip);
                if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE)) {
                    return $ip;
                }
            }
        }
        
        return $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
    }
    
    /**
     * Obtient le User Agent du client
     */
    private function getUserAgent() {
        return $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
    }
    
    /**
     * Nettoie les anciennes données d'activité
     */
    public function cleanOldData($daysToKeep = 180) {
        try {
            // Nettoyer les activités anciennes
            $sql = "DELETE FROM user_activity WHERE date_action < DATE_SUB(NOW(), INTERVAL ? DAY)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([$daysToKeep]);
            
            // Nettoyer les sessions expirées
            $sql = "DELETE FROM user_sessions WHERE statut_session != 'active' AND derniere_activite < DATE_SUB(NOW(), INTERVAL 30 DAY)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            
            // Marquer les sessions inactives comme expirées
            $sql = "UPDATE user_sessions SET statut_session = 'expiree' WHERE statut_session = 'active' AND derniere_activite < DATE_SUB(NOW(), INTERVAL 24 HOUR)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            
            return true;
        } catch (Exception $e) {
            error_log("Erreur lors du nettoyage des données: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Obtient les statistiques d'activité
     */
    public function getActivityStats($period = '24h') {
        try {
            $interval = match ($period) {
                '1h' => 'INTERVAL 1 HOUR',
                '24h' => 'INTERVAL 24 HOUR',
                '7d' => 'INTERVAL 7 DAY',
                '30d' => 'INTERVAL 30 DAY',
                default => 'INTERVAL 24 HOUR'
            };
            
            $sql = "SELECT 
                        action_type,
                        COUNT(*) as count,
                        COUNT(DISTINCT id_utilisateur) as unique_users
                    FROM user_activity 
                    WHERE date_action >= DATE_SUB(NOW(), $interval)
                    GROUP BY action_type
                    ORDER BY count DESC";
            
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            error_log("Erreur lors de la récupération des statistiques: " . $e->getMessage());
            return [];
        }
    }
}

/**
 * Fonctions helper globales pour faciliter l'utilisation
 */

// Instance globale du logger
$activityLogger = null;

/**
 * Initialise le logger d'activité
 */
function initActivityLogger($pdo) {
    global $activityLogger;
    $activityLogger = new ActivityLogger($pdo);
    return $activityLogger;
}

/**
 * Log rapide d'une activité
 */
function logActivity($actionType, $page = null, $details = null) {
    global $activityLogger;
    
    if (!$activityLogger || !isset($_SESSION['user'])) {
        return false;
    }
    
    return $activityLogger->logActivity(
        $_SESSION['user']['id'],
        $_SESSION['user']['username'],
        $actionType,
        $page,
        $details
    );
}

/**
 * Log rapide d'une connexion
 */
function logLogin($user) {
    global $activityLogger;
    
    if (!$activityLogger) {
        return false;
    }
    
    return $activityLogger->logLogin($user['id_utilisateur'], $user['username']);
}

/**
 * Log rapide d'une déconnexion
 */
function logLogout($user, $sessionDuration = null) {
    global $activityLogger;
    
    if (!$activityLogger) {
        return false;
    }
    
    return $activityLogger->logLogout($user['id_utilisateur'], $user['username'], $sessionDuration);
}

/**
 * Log rapide d'une consultation de page
 */
function logPageVisit($page, $details = null) {
    return logActivity('consultation', $page, $details);
}

/**
 * Log rapide d'une création
 */
function logCreation($page, $details) {
    return logActivity('creation', $page, $details);
}

/**
 * Log rapide d'une modification
 */
function logModification($page, $details) {
    return logActivity('modification', $page, $details);
}

/**
 * Log rapide d'une suppression
 */
function logSuppression($page, $details) {
    return logActivity('suppression', $page, $details);
}

/**
 * Met à jour l'activité de l'utilisateur (heartbeat)
 */
function updateUserActivity() {
    global $activityLogger;
    
    if (!$activityLogger || !isset($_SESSION['user'])) {
        return false;
    }
    
    return $activityLogger->updateLastActivity($_SESSION['user']['id']);
}

/**
 * Middleware pour tracker automatiquement les pages visitées
 */
function autoTrackPage($excludePages = []) {
    if (!isset($_SESSION['user'])) {
        return false;
    }
    
    $currentPage = basename($_SERVER['PHP_SELF']);
    
    // Pages à exclure du tracking automatique
    $defaultExcludes = ['ajax/', 'api/', 'cron/', 'includes/'];
    $excludePages = array_merge($defaultExcludes, $excludePages);
    
    foreach ($excludePages as $exclude) {
        if (strpos($_SERVER['REQUEST_URI'], $exclude) !== false) {
            return false;
        }
    }
    
    // Ne pas tracker les requêtes AJAX
    if (!empty($_SERVER['HTTP_X_REQUESTED_WITH']) && 
        strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest') {
        return false;
    }
    
    // Tracker la visite de page
    $details = null;
    if (!empty($_GET)) {
        $details = 'Paramètres: ' . http_build_query($_GET);
    }
    
    return logPageVisit($currentPage, $details);
}

/**
 * Hook pour les actions CRUD sur les patients
 */
function logPatientAction($action, $patientId, $patientName, $details = null) {
    if (!isset($_SESSION['user'])) {
        return false;
    }
    
    $page = basename($_SERVER['PHP_SELF']);
    $fullDetails = "Patient: $patientName (ID: $patientId)";
    if ($details) {
        $fullDetails .= " - $details";
    }
    
    return logActivity($action, $page, $fullDetails);
}

/**
 * Hook pour les actions sur les utilisateurs/médecins
 */
function logUserManagementAction($action, $targetUserId, $targetUsername, $details = null, $dataBefore = null, $dataAfter = null) {
    global $activityLogger;
    
    if (!$activityLogger || !isset($_SESSION['user'])) {
        return false;
    }
    
    return $activityLogger->logUserAction(
        $_SESSION['user']['id'],
        $_SESSION['user']['username'],
        $targetUserId,
        $targetUsername,
        $action,
        $details,
        $dataBefore,
        $dataAfter
    );
}

/**
 * Génère un rapport d'activité pour un utilisateur
 */
function generateUserActivityReport($userId, $startDate = null, $endDate = null) {
    global $pdo;
    
    if (!$startDate) {
        $startDate = date('Y-m-d', strtotime('-30 days'));
    }
    if (!$endDate) {
        $endDate = date('Y-m-d');
    }
    
    try {
        $sql = "SELECT 
                    DATE(date_action) as date,
                    action_type,
                    COUNT(*) as count,
                    MIN(date_action) as first_action,
                    MAX(date_action) as last_action
                FROM user_activity 
                WHERE id_utilisateur = ? 
                AND DATE(date_action) BETWEEN ? AND ?
                GROUP BY DATE(date_action), action_type
                ORDER BY date DESC, action_type";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$userId, $startDate, $endDate]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        error_log("Erreur lors de la génération du rapport: " . $e->getMessage());
        return [];
    }
}

/**
 * Obtient les utilisateurs les plus actifs
 */
function getMostActiveUsers($period = '7d', $limit = 10) {
    global $pdo;
    
    $interval = match ($period) {
        '1d' => 'INTERVAL 1 DAY',
        '7d' => 'INTERVAL 7 DAY',
        '30d' => 'INTERVAL 30 DAY',
        default => 'INTERVAL 7 DAY'
    };
    
    try {
        $sql = "SELECT 
                    u.username,
                    u.role,
                    COUNT(ua.id) as total_actions,
                    COUNT(DISTINCT DATE(ua.date_action)) as active_days,
                    MAX(ua.date_action) as last_activity
                FROM users u
                JOIN user_activity ua ON u.id_utilisateur = ua.id_utilisateur
                WHERE ua.date_action >= DATE_SUB(NOW(), $interval)
                GROUP BY u.id_utilisateur, u.username, u.role
                ORDER BY total_actions DESC
                LIMIT ?";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$limit]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        error_log("Erreur lors de la récupération des utilisateurs actifs: " . $e->getMessage());
        return [];
    }
}

/**
 * Détecte les activités suspectes
 */
function detectSuspiciousActivity() {
    global $pdo;
    
    $suspiciousActivities = [];
    
    try {
        // Connexions multiples depuis différentes IPs
        $sql = "SELECT 
                    username,
                    COUNT(DISTINCT adresse_ip) as ip_count,
                    GROUP_CONCAT(DISTINCT adresse_ip) as ips
                FROM user_activity 
                WHERE action_type = 'connexion' 
                AND date_action >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
                GROUP BY username
                HAVING ip_count > 3";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $multipleIPs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        if (!empty($multipleIPs)) {
            $suspiciousActivities['multiple_ips'] = $multipleIPs;
        }
        
        // Activité excessive (plus de 100 actions en 1h)
        $sql = "SELECT 
                    username,
                    COUNT(*) as action_count,
                    MIN(date_action) as first_action,
                    MAX(date_action) as last_action
                FROM user_activity 
                WHERE date_action >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
                GROUP BY username
                HAVING action_count > 100";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $excessiveActivity = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        if (!empty($excessiveActivity)) {
            $suspiciousActivities['excessive_activity'] = $excessiveActivity;
        }
        
        // Connexions en dehors des heures de travail (22h-6h)
        $sql = "SELECT 
                    username,
                    adresse_ip,
                    date_action
                FROM user_activity 
                WHERE action_type = 'connexion' 
                AND (HOUR(date_action) >= 22 OR HOUR(date_action) <= 6)
                AND date_action >= DATE_SUB(NOW(), INTERVAL 7 DAY)
                ORDER BY date_action DESC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $afterHours = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        if (!empty($afterHours)) {
            $suspiciousActivities['after_hours'] = $afterHours;
        }
        
        return $suspiciousActivities;
    } catch (Exception $e) {
        error_log("Erreur lors de la détection d'activités suspectes: " . $e->getMessage());
        return [];
    }
}

/**
 * Planifie le nettoyage automatique des données
 */
function scheduleCleanup() {
    global $activityLogger;
    
    // À exécuter via un cron job quotidien
    if ($activityLogger) {
        return $activityLogger->cleanOldData(180); // Garder 6 mois de données
    }
    
    return false;
}

/**
 * Export des données d'activité
 */
function exportActivityData($filters = [], $format = 'csv') {
    global $pdo;
    
    try {
        $whereConditions = [];
        $params = [];
        
        if (!empty($filters['date_debut'])) {
            $whereConditions[] = "DATE(ua.date_action) >= ?";
            $params[] = $filters['date_debut'];
        }
        
        if (!empty($filters['date_fin'])) {
            $whereConditions[] = "DATE(ua.date_action) <= ?";
            $params[] = $filters['date_fin'];
        }
        
        if (!empty($filters['username'])) {
            $whereConditions[] = "ua.username LIKE ?";
            $params[] = "%{$filters['username']}%";
        }
        
        if (!empty($filters['action_type'])) {
            $whereConditions[] = "ua.action_type = ?";
            $params[] = $filters['action_type'];
        }
        
        $whereClause = !empty($whereConditions) ? "WHERE " . implode(" AND ", $whereConditions) : "";
        
        $sql = "SELECT 
                    ua.date_action,
                    ua.username,
                    ua.action_type,
                    ua.page_visitee,
                    ua.details_action,
                    ua.adresse_ip,
                    ua.session_id
                FROM user_activity ua
                $whereClause
                ORDER BY ua.date_action DESC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        if ($format === 'csv') {
            return generateCSV($data);
        } elseif ($format === 'json') {
            return json_encode($data, JSON_PRETTY_PRINT);
        }
        
        return $data;
    } catch (Exception $e) {
        error_log("Erreur lors de l'export: " . $e->getMessage());
        return false;
    }
}

/**
 * Génère un fichier CSV
 */
function generateCSV($data) {
    if (empty($data)) {
        return false;
    }
    
    $output = fopen('php://temp', 'w');
    
    // En-têtes
    fputcsv($output, array_keys($data[0]));
    
    // Données
    foreach ($data as $row) {
        fputcsv($output, $row);
    }
    
    rewind($output);
    $csv = stream_get_contents($output);
    fclose($output);
    
    return $csv;
}
?>