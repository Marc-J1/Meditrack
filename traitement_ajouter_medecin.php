<?php
session_start();
require_once 'db.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
//logPageVisit(basename($_SERVER['PHP_SELF']), 'A ajouté un medecin');
// logPageVisit(...);   // <- laisse bien COMMENTÉ pour cette page
logUserManagementAction(
    'ajout',              // <-- c’est le bon type
    $nouveau_id,
    $nouveau_medecin['username'],
    "Nouveau médecin créé avec le statut: " . $nouveau_medecin['statut'],
    null,
    $nouveau_medecin,
    $_SESSION['user']['username'] ?? 'system'
);

include 'includes/auto_track.php';

function redirect_error($msg) {
    header("Location: ajouter_medecin.php?error=" . urlencode($msg));
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Récupération
    $identifiant  = trim($_POST['identifiant'] ?? '');
    $nom          = trim($_POST['nom'] ?? '');
    $password     = trim($_POST['password'] ?? '');
    $phone_number = trim($_POST['phone_number'] ?? '');
    $address      = trim($_POST['address'] ?? '');
    $mail         = trim($_POST['mail'] ?? '');
    $statut       = (isset($_POST['statut']) && in_array($_POST['statut'], ['principal', 'interimaire'])) ? $_POST['statut'] : 'principal';

    // -------- Normalisations --------
    if (preg_match("/\r|\n/", $mail)) redirect_error("Email invalide.");
    $mail_lower = mb_strtolower($mail);

    $raw_phone = preg_replace('/[^\d+]/', '', $phone_number);
    if (preg_match('/^0\d{9}$/', $raw_phone)) {
        $raw_phone = '+242' . substr($raw_phone, 1);
    }
    if (preg_match('/^242\d{9}$/', $raw_phone)) {
        $raw_phone = '+' . $raw_phone;
    }
    $address_norm = preg_replace('/\s+/u', ' ', $address);

    // -------- Validations serveur --------
    if ($identifiant === '' || $nom === '' || $mail_lower === '' || $password === '') {
        redirect_error("Veuillez remplir tous les champs obligatoires.");
    }
    if (!preg_match('/^[a-zA-Z0-9._-]{3,50}$/', $identifiant)) {
        redirect_error("Identifiant invalide (3–50, lettres/chiffres . _ -).");
    }

    if (strlen($password) < 8) redirect_error("Le mot de passe doit contenir au moins 8 caractères.");
    if (!preg_match('/[A-Z]/', $password) || !preg_match('/[a-z]/', $password) || !preg_match('/\d/', $password)) {
        redirect_error("Mot de passe trop faible (majuscule, minuscule et chiffre requis).");
    }
    if (!preg_match('/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/', $mail_lower)) {
        redirect_error("Adresse email invalide.");
    }
    if (!preg_match('/^\+?[1-9]\d{6,14}$/', $raw_phone)) {
        redirect_error("Numéro de téléphone invalide.");
    }
    if (!preg_match('/^\+242\d{9}$/', $raw_phone)) {
        redirect_error("Le numéro doit être au format congolais (+242 suivi de 9 chiffres).");
    }
    if ($address_norm !== '' && !preg_match('/^[\p{L}\p{M}\d\s\-\'\/,\.]{4,255}$/u', $address_norm)) {
        redirect_error("Adresse invalide (caractères non autorisés ou longueur incorrecte).");
    }

    // -------- Unicité identifiant --------
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE identifiant = ?");
    $stmt->execute([$identifiant]);
    if ($stmt->fetchColumn() > 0) {
        redirect_error("Identifiant déjà utilisé.");
    }

    // -------- Unicité email --------
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE mail = ?");
    $stmt->execute([$mail_lower]);
    if ($stmt->fetchColumn() > 0) {
        redirect_error("Email déjà utilisé.");
    }

    // -------- Unicité téléphone --------
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE phone_number = ?");
    $stmt->execute([$raw_phone]);
    if ($stmt->fetchColumn() > 0) {
        redirect_error("Téléphone déjà utilisé.");
    }

    // -------- Insertion --------
    try {
        $insert = $pdo->prepare("
            INSERT INTO users (identifiant, username, password, phone_number, address, mail, role, statut, date_creation)
            VALUES (?, ?, ?, ?, ?, ?, 'medecin', ?, NOW())
        ");
        $insert->execute([
            $identifiant,
            $nom,
            $password,              // tu n'as pas demandé le hash, je ne touche pas
            $raw_phone,             // E.164
            $address_norm,
            $mail_lower,
            $statut
        ]);

        $nouveau_id = $pdo->lastInsertId();
        $nouveau_medecin = [
            'identifiant'  => $identifiant,
            'username'     => $nom,
            'statut'       => $statut,
            'mail'         => $mail_lower,
            'phone_number' => $raw_phone,
            'address'      => $address_norm
        ];

        logUserManagementAction(
            'ajout',
            $nouveau_id,
            $nouveau_medecin['username'],
            "Nouveau médecin créé avec le statut: " . $nouveau_medecin['statut'],
            null,
            $nouveau_medecin,
            $_SESSION['user']['username'] ?? 'system'
        );

        header("Location: ajouter_medecin.php?success=1");
        exit();
    } catch (Exception $e) {
        redirect_error("Erreur lors de l'ajout");
    }

} else {
    header("Location: ajouter_medecin.php");
    exit();
}
