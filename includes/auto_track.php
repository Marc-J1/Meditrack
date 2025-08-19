<?php
require_once 'includes/activity_logger.php';

// Auto-tracking pour toutes les pages
if (isset($_SESSION['user'])) {
    // Mettre à jour l'activité
    updateUserActivity();
    
    // Tracker la page si ce n'est pas AJAX
    autoTrackPage();
}
?>