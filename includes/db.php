<?php
$host = 'localhost';           // Serveur MySQL
$dbname = 'patient_manager';   // Nom de la base de données
$username = 'root';            // Nom d'utilisateur MySQL (par défaut sur XAMPP)
$password = '';                // Mot de passe MySQL (souvent vide sur XAMPP)

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    // Définir le mode d'erreur pour obtenir des exceptions en cas de souci
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Erreur de connexion à la base de données : " . $e->getMessage());
}
?>
