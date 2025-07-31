<?php
// Paramètres de connexion à la base de données
$host = 'localhost';
$dbname = 'patient_manager';
$username = 'root';
$password = ''; // laisse vide pour XAMPP local

try {
    // Connexion avec PDO
    $conn = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    // En cas d'erreur de connexion
    die("Erreur de connexion à la base de données : " . $e->getMessage());
}
