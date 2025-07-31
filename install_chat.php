<?php
/**
 * Installateur du système de chat médical
 * install_chat.php
 * 
 * Exécutez ce script une seule fois pour installer le système de chat
 */

require_once 'db.php';
require_once 'chat_config.php';

// Vérifier les permissions (seul un admin peut installer)
session_start();
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'admin') {
    die('Erreur: Seul un administrateur peut installer le système de chat.');
}

$installation_log = [];
$errors = [];

function logStep($message, $success = true) {
    global $installation_log;
    $installation_log[] = [
        'message' => $message,
        'success' => $success,
        'timestamp' => date('Y-m-d H:i:s')
    ];
    echo ($success ? "✓ " : "✗ ") . $message . "\n";
}

try {
    logStep("Début de l'installation du système de chat");
    
    // 1. Créer les tables
    logStep("Création de la table chat_messages...");
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS chat_messages (
            id_message INT AUTO_INCREMENT PRIMARY KEY,
            id_utilisateur INT NOT NULL,
            message TEXT NOT NULL,
            date_message DATETIME DEFAULT CURRENT_TIMESTAMP,
            statut ENUM('lu', 'non_lu') DEFAULT 'non_lu',
            type_message ENUM('text', 'system') DEFAULT 'text',
            FOREIGN KEY (id_utilisateur) REFERENCES users(id_utilisateur) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");
    
    logStep("Création de la table chat_message_read...");
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS chat_message_read (
            id_read INT AUTO_INCREMENT PRIMARY KEY,
            id_message INT NOT NULL,
            id_utilisateur INT NOT NULL,
            date_lecture DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (id_message) REFERENCES chat_messages(id_message) ON DELETE CASCADE,
            FOREIGN KEY (id_utilisateur) REFERENCES users(id_utilisateur) ON DELETE CASCADE,
            UNIQUE KEY unique_user_message (id_message, id_utilisateur)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");
    
    // 2. Créer les index
    logStep("Création des index pour optimiser les performances...");
    $pdo->exec("CREATE INDEX IF NOT EXISTS idx_chat_messages_date ON chat_messages(date_message)");
    $pdo->exec("CREATE INDEX IF NOT EXISTS idx_chat_messages_user ON chat_messages(id_utilisateur)");
    $pdo->exec("CREATE INDEX IF NOT EXISTS idx_chat_read_user ON chat_message_read(id_utilisateur)");
    $pdo->exec("CREATE INDEX IF NOT EXISTS idx_chat_messages_statut ON chat_messages(statut)");
    
    // 3. Créer le dossier de logs
    logStep("Création du dossier de logs...");
    $log_dir = __DIR__ . '/logs';
    if (!is_dir($log_dir)) {
        mkdir($log_dir, 0755, true);
        logStep("Dossier logs créé");
    } else {
        logStep("Dossier logs existe déjà");
    }
    
    // 4. Vérifier les permissions des fichiers
    logStep("Vérification des permissions...");
    $required_files = ['chat.php', 'chat_api.php', 'chat_config.php'];
    foreach ($required_files as $file) {
        if (!file_exists($file)) {
            $errors[] = "Fichier manquant: $file";
            logStep("Fichier manquant: $file", false);
        } else {
            logStep("Fichier trouvé: $file");
        }
    }
    
    // 5. Insérer le message système d'initialisation
    logStep("Insertion du message d'initialisation...");
    $admin_id = $_SESSION['user']['id_utilisateur'];
    $stmt = $pdo->prepare("
        INSERT INTO chat_messages (id_utilisateur, message, type_message, date_message) 
        VALUES (?, ?, 'system', NOW())
    ");
    $stmt->execute([$admin_id, ChatConfig::SYSTEM_MESSAGES['welcome']]);
    
    // 6. Créer une tâche cron recommandée (information seulement)
    logStep("Information: Ajoutez cette ligne à votre crontab pour nettoyer automatiquement les anciens messages:");
    echo "0 2 * * 0 /usr/bin/php " . __DIR__ . "/chat_cleanup.php\n";
    
    // 7. Tester la connexion à la base de données
    logStep("Test de la connexion à la base de données...");
    $test_query = $pdo->query("SELECT COUNT(*) FROM chat_messages");
    $message_count = $test_query->fetchColumn();
    logStep("Base de données opérationnelle. Messages existants: $message_count");
    
    // 8. Vérifier les utilisateurs autorisés
    logStep("Vérification des utilisateurs autorisés...");
    $stmt = $pdo->query("SELECT COUNT(*) FROM users WHERE role IN ('admin', 'medecin')");
    $authorized_users = $stmt->fetchColumn();
    logStep("$authorized_users utilisateurs autorisés trouvés");
    
    if (empty($errors)) {
        logStep("Installation terminée avec succès!");
        logStep("Vous pouvez maintenant accéder au chat via: chat.php");
        
        // Enregistrer le log d'installation
        $install_log = [
            'date' => date('Y-m-d H:i:s'),
            'version' => '1.0.0',
            'admin_id' => $admin_id,
            'steps' => $installation_log
        ];
        
        file_put_contents(
            $log_dir . '/installation.log', 
            json_encode($install_log, JSON_PRETTY_PRINT) . "\n", 
            FILE_APPEND | LOCK_EX
        );
        
        echo "\n=== INSTALLATION RÉUSSIE ===\n";
        echo "Le système de chat médical est maintenant installé et prêt à l'emploi.\n";
        echo "Accédez à chat.php pour commencer à utiliser le système.\n\n";
        
        echo "Fonctionnalités disponibles:\n";
        echo "- Chat en temps réel entre administrateurs et médecins\n";
        echo "- Notifications de messages non lus\n";
        echo "- Statistiques d'utilisation\n";
        echo "- Interface responsive et sécurisée\n";
        echo "- Historique des messages\n\n";
        
        echo "Pour désinstaller, supprimez les tables chat_messages et chat_message_read.\n";
        
    } else {
        logStep("Installation terminée avec des erreurs:", false);
        foreach ($errors as $error) {
            logStep("ERREUR: $error", false);
        }
    }
    
} catch (Exception $e) {
    logStep("Erreur fatale lors de l'installation: " . $e->getMessage(), false);
    echo "\nVeuillez vérifier:\n";
    echo "- La connexion à la base de données\n";
    echo "- Les permissions des fichiers\n";
    echo "- La structure de la table users\n";
    exit(1);
}

// Fonction pour créer le script de nettoyage
function createCleanupScript() {
    $cleanup_script = '<?php
// Script de nettoyage automatique des anciens messages
// chat_cleanup.php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/chat_config.php";

try {
    $deleted = ChatConfig::cleanOldMessages($pdo, 90);
    echo "Nettoyage terminé. $deleted messages supprimés.\n";
    ChatConfig::logActivity(0, "auto_cleanup", "$deleted messages supprimés");
} catch (Exception $e) {
    error_log("Erreur lors du nettoyage automatique: " . $e->getMessage());
}
?>';
    
    file_put_contents(__DIR__ . '/chat_cleanup.php', $cleanup_script);
    logStep("Script de nettoyage automatique créé");
}

// Créer le script de nettoyage
createCleanupScript();

echo "\n--- LOG D'INSTALLATION ---\n";
foreach ($installation_log as $entry) {
    echo "[{$entry['timestamp']}] " . ($entry['success'] ? "OK" : "ERROR") . " - {$entry['message']}\n";
}
?>