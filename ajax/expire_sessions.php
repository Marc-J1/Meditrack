<?php
require_once '../db.php';

$sql = "UPDATE user_sessions
        SET statut_session = 'expiree'
        WHERE statut_session = 'active'
          AND TIMESTAMPDIFF(MINUTE, derniere_activite, NOW()) > 10";

$pdo->prepare($sql)->execute();
