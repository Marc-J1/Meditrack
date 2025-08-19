<?php
session_start();
include 'includes/auto_track.php';
require_once 'includes/db.php'; // Connexion PDO
require_once 'includes/activity_logger.php'; // à mettre en haut du fichier
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'A ajouté un patient');


// ---- Helpers d'erreur (toast via ?error=) ----
function redirect_error($msg) {
    header("Location: ajouter_patient.php?error=" . urlencode($msg));
    exit();
}

// ---- Utils: normaliser nombres (gère virgule -> point) ----
function norm_number($raw) {
    $v = trim((string)$raw);
    if ($v === '') return null;
    $v = str_replace(' ', '', $v);
    $v = str_replace(',', '.', $v);
    return $v;
}

// ---- Validation Poids/Taille ----
// Retourne [true, ['poids'=>$kg,'taille'=>$m]] ou [false, 'message']
function validate_poids_taille($poidsRaw, $tailleRaw, $kgMin=30, $kgMax=300, $mMin=1.20, $mMax=2.30) {
    $pStr = norm_number($poidsRaw);
    $tStr = norm_number($tailleRaw);

    if ($pStr === null || $tStr === null) {
        return [false, "Veuillez renseigner le poids (kg) et la taille (m)."];
    }
    if (!is_numeric($pStr) || !is_numeric($tStr)) {
        return [false, "Poids/Taille invalides (valeurs numériques attendues)."];
    }

    $p = (float)$pStr; // kg
    $t = (float)$tStr; // m

    if ($p < $kgMin || $p > $kgMax) {
        return [false, "Poids hors limites ({$kgMin}–{$kgMax} kg)."];
    }
    if ($t < $mMin || $t > $mMax) {
        return [false, "Taille hors limites ({$mMin}–{$mMax} m)."];
    }

    // Garde-fou IMC (évite valeurs absurdes)
    if ($t > 0) {
        $bmi = $p / ($t*$t);
        if ($bmi > 80) {
            return [false, "Valeurs incohérentes — vérifiez le poids et la taille."];
        }
    }

    // Arrondis doux
    $p = round($p, 1);
    $t = round($t, 2);

    return [true, ['poids' => $p, 'taille' => $t]];
}

// ---- Validation Date de Naissance ----
function parse_dob_to_iso(string $input): ?string {
    $input = trim($input);
    if ($input === '') return null;

    // YYYY-MM-DD
    $dt = DateTime::createFromFormat('!Y-m-d', $input, new DateTimeZone('Africa/Brazzaville'));
    if ($dt && $dt->format('Y-m-d') === $input) {
        return $dt->format('Y-m-d');
    }

    // DD/MM/YYYY
    if (preg_match('#^\s*(\d{2})/(\d{2})/(\d{4})\s*$#', $input, $m)) {
        [$all, $d, $mth, $y] = $m;
        if (checkdate((int)$mth, (int)$d, (int)$y)) {
            $dt = DateTime::createFromFormat('!d/m/Y', "$d/$mth/$y", new DateTimeZone('Africa/Brazzaville'));
            return $dt ? $dt->format('Y-m-d') : null;
        }
    }
    return null;
}
// Retourne [true, $iso] ou [false, 'message']
function validate_dob(string $rawDob, string $minDate = '1900-01-01'): array {
    $iso = parse_dob_to_iso($rawDob);
    if ($iso === null) return [false, "Date de naissance invalide. Utilisez JJ/MM/AAAA ou AAAA-MM-JJ."];

    $tz = new DateTimeZone('Africa/Brazzaville');
    $dob = DateTime::createFromFormat('!Y-m-d', $iso, $tz);
    $min = DateTime::createFromFormat('!Y-m-d', $minDate, $tz);

    $today = new DateTime('now', $tz);
    $todayStr = $today->format('Y-m-d');
    $todayDate = DateTime::createFromFormat('!Y-m-d', $todayStr, $tz);

    if ($dob > $todayDate) return [false, "La date de naissance ne peut pas être dans le futur."];
    if ($dob < $min)       return [false, "La date de naissance ne peut pas être antérieure au ".date('d/m/Y', strtotime($minDate))."."];

    return [true, $iso];
}

// Vérifie que la requête est bien POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Récupération et nettoyage des données
    $nom = trim($_POST['nom']);
    $prenom = trim($_POST['prenom']);
    $sexe = trim($_POST['sexe']);
    $date_naissance = trim($_POST['date_naissance']);
    $loisirs = trim($_POST['loisirs']);
    $divers = trim($_POST['divers']);
    $antecedents_medicaux = trim($_POST['antecedents_medicaux']);
    $chirurgicaux = trim($_POST['chirurgicaux']);
    $familiaux = trim($_POST['familiaux']);
    $mentions_particulieres = trim($_POST['mentions_particulieres']);
    $telephone = trim($_POST['telephone']);
    $profession = trim($_POST['profession']);
    $poids = trim($_POST['poids']);
    $taille = trim($_POST['taille']);

    // Vérifie que l'utilisateur est bien un médecin connecté
    if (!isset($_SESSION['user']['id'])) {
        header("Location: login.php");
        exit();
    }
    $id_utilisateur = $_SESSION['user']['id']; // le médecin qui ajoute

    // ---- Validations serveur ciblées ----
    if ($nom === '' || $prenom === '' || $sexe === '' || $date_naissance === '' || $telephone === '' || $profession === '' || $poids === '' || $taille === '') {
        redirect_error("Veuillez remplir tous les champs obligatoires.");
    }

    // Date de naissance : pas futur, pas avant 1900-01-01
    [$okDob, $dobOrErr] = validate_dob($date_naissance, '1900-01-01');
    if (!$okDob) redirect_error($dobOrErr);
    $date_naissance_iso = $dobOrErr;

    // Poids/Taille : bornes logiques (adultes)
    [$okHW, $hwOrMsg] = validate_poids_taille($poids, $taille, 30, 300, 1.20, 2.30);
    if (!$okHW) redirect_error($hwOrMsg);
    $poids_ok = $hwOrMsg['poids'];   // kg (ex: 68.5)
    $taille_ok = $hwOrMsg['taille']; // m  (ex: 1.75)

    try {
        // Insertion dans la base de données
        $stmt = $pdo->prepare("INSERT INTO patients (
            nom, prenom, sexe, date_naissance, loisirs, divers, 
            antecedents_medicaux, chirurgicaux, familiaux, mentions_particulieres, 
            telephone, profession, poids, taille, id_utilisateur
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        $stmt->execute([
            $nom, $prenom, $sexe, $date_naissance_iso, $loisirs, $divers,
            $antecedents_medicaux, $chirurgicaux, $familiaux, $mentions_particulieres,
            $telephone, $profession, $poids_ok, $taille_ok, $id_utilisateur
        ]);

        // 📝 Historique
        if ($stmt->rowCount() > 0) {
            $id_patient = $pdo->lastInsertId();
            $donnees_apres = [
                'nom' => $nom,
                'prenom' => $prenom,
                'sexe' => $sexe,
                'date_naissance' => $date_naissance_iso,
                'telephone' => $telephone,
                'profession' => $profession,
                'poids' => $poids_ok,
                'taille' => $taille_ok,
                'loisirs' => $loisirs,
                'divers' => $divers,
                'antecedents_medicaux' => $antecedents_medicaux,
                'chirurgicaux' => $chirurgicaux,
                'familiaux' => $familiaux,
                'mentions_particulieres' => $mentions_particulieres
            ];

            logPatientAction('ajout', $id_patient, "$nom $prenom", "Ajout du patient", null, $donnees_apres);
            logCreation('ajouter_patient_traitement.php', "Patient créé: $nom $prenom (ID: $id_patient)");
        }

        header("Location: ajouter_patient.php?success=1");
        exit;

    } catch (PDOException $e) {
        header("Location: ajouter_patient.php?error=" . urlencode($e->getMessage()));
        exit;
    }

} else {
    header("Location: ajouter_patient.php");
    exit;
}
