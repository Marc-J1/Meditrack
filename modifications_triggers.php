<?php
// MODIFICATIONS À APPORTER AUX FICHIERS EXISTANTS

// ==========================================
// 1. MODIFICATION DE modifier_patient.php
// ==========================================

// REMPLACER cette partie dans modifier_patient.php (lignes ~45-60) :
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // ... récupération des données POST ...

    // 📊 Enregistrer l'état avant modification pour l'historique
    $donnees_avant = [
        'nom' => $patient['nom'],
        'prenom' => $patient['prenom'],
        'sexe' => $patient['sexe'],
        'date_naissance' => $patient['date_naissance'],
        'loisirs' => $patient['loisirs'],
        'divers' => $patient['divers'],
        'antecedents_medicaux' => $patient['antecedents_medicaux'],
        'chirurgicaux' => $patient['chirurgicaux'],
        'familiaux' => $patient['familiaux'],
        'mentions_particulieres' => $patient['mentions_particulieres'],
        'telephone' => $patient['telephone'],
        'profession' => $patient['profession'],
        'poids' => $patient['poids'],
        'taille' => $patient['taille']
    ];

    // 🔄 Mise à jour du patient
    $stmtUpdate = $pdo->prepare("
        UPDATE patients 
        SET nom = ?, prenom = ?, sexe = ?, date_naissance = ?, loisirs = ?, divers = ?, 
            antecedents_medicaux = ?, chirurgicaux = ?, familiaux = ?, mentions_particulieres = ?,
            telephone = ?, profession = ?, poids = ?, taille = ?
        WHERE id_patient = ?
    ");

    $success = $stmtUpdate->execute([
        $nom, $prenom, $sexe, $date_naissance, $loisirs, $divers,
        $antecedents_medicaux, $chirurgicaux, $familiaux, $mentions,
        $telephone, $profession, $poids, $taille,
        $id_patient
    ]);

    if ($success) {
        // 📝 Enregistrer l'action dans l'historique
        $donnees_apres = [
            'nom' => $nom,
            'prenom' => $prenom,
            'sexe' => $sexe,
            'date_naissance' => $date_naissance,
            'loisirs' => $loisirs,
            'divers' => $divers,
            'antecedents_medicaux' => $antecedents_medicaux,
            'chirurgicaux' => $chirurgicaux,
            'familiaux' => $familiaux,
            'mentions_particulieres' => $mentions,
            'telephone' => $telephone,
            'profession' => $profession,
            'poids' => $poids,
            'taille' => $taille
        ];

        $histoStmt = $pdo->prepare("
            INSERT INTO historique_patients (
                id_patient, nom_patient, prenom_patient, action_type, details_action,
                id_utilisateur, nom_utilisateur, donnees_avant, donnees_apres
            ) VALUES (?, ?, ?, 'modification', ?, ?, ?, ?, ?)
        ");

        $histoStmt->execute([
            $id_patient,
            $nom,
            $prenom,
            "Patient modifié: $nom $prenom",
            $_SESSION['user']['id'],
            $_SESSION['user']['username'],
            json_encode($donnees_avant),
            json_encode($donnees_apres)
        ]);
    }

    // ✅ Redirection avec toast
    header("Location: lister_patients.php?success=modification");
    exit();
}

// ==========================================
// 2. MODIFICATION DE ajouter_patient_traitement.php
// ==========================================

// AJOUTER ce code après l'insertion du patient :
session_start();
require_once 'db.php';

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // ... code d'insertion existant ...
    
    // Après l'insertion réussie du patient, ajouter :
    if ($stmt->rowCount() > 0) {
        $id_patient = $pdo->lastInsertId();
        
        // 📝 Enregistrer l'action d'ajout dans l'historique
        $donnees_apres = [
            'nom' => trim($_POST['nom']),
            'prenom' => trim($_POST['prenom']),
            'sexe' => $_POST['sexe'],
            'date_naissance' => $_POST['date_naissance'],
            'telephone' => trim($_POST['telephone']),
            'profession' => trim($_POST['profession']),
            'poids' => trim($_POST['poids']),
            'taille' => trim($_POST['taille']),
            'loisirs' => trim($_POST['loisirs']),
            'divers' => trim($_POST['divers']),
            'antecedents_medicaux' => trim($_POST['antecedents_medicaux']),
            'chirurgicaux' => trim($_POST['chirurgicaux']),
            'familiaux' => trim($_POST['familiaux']),
            'mentions_particulieres' => trim($_POST['mentions_particulieres'])
        ];

        $histoStmt = $pdo->prepare("
            INSERT INTO historique_patients (
                id_patient, nom_patient, prenom_patient, action_type, details_action,
                id_utilisateur, nom_utilisateur, donnees_apres
            ) VALUES (?, ?, ?, 'ajout', ?, ?, ?, ?)
        ");

        $histoStmt->execute([
            $id_patient,
            trim($_POST['nom']),
            trim($_POST['prenom']),
            "Patient ajouté: " . trim($_POST['nom']) . " " . trim($_POST['prenom']),
            $_SESSION['user']['id'],
            $_SESSION['user']['username'],
            json_encode($donnees_apres)
        ]);

        header("Location: ajouter_patient.php?success=1");
    } else {
        header("Location: ajouter_patient.php?error=insertion_failed");
    }
    exit();
}

// ==========================================
// 3. MODIFICATION DE supprimer_patient.php
// ==========================================

// REMPLACER tout le contenu après la vérification d'autorisation :
session_start();
require_once 'db.php';

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

if (!isset($_GET['id']) || !is_numeric($_GET['id'])) {
    header("Location: lister_patients.php?error=id_invalide");
    exit();
}

$id_patient = intval($_GET['id']);
$id_utilisateur = $_SESSION['user']['id'];

// 🔍 Récupérer le patient avant suppression
$stmt = $pdo->prepare("SELECT * FROM patients WHERE id_patient = ?");
$stmt->execute([$id_patient]);
$patient = $stmt->fetch();

if (!$patient) {
    header("Location: lister_patients.php?error=patient_introuvable");
    exit();
}

// 🔒 Vérifier l'autorisation : créateur ou médecin "principal"
$isCreator = $patient['id_utilisateur'] == $id_utilisateur;
$isPrincipal = $_SESSION['user']['statut'] === 'principal';

if (!$isCreator && !$isPrincipal) {
    header("Location: lister_patients.php?error=accès_refusé");
    exit();
}

// 📝 Enregistrer l'action de suppression AVANT la suppression
$donnees_avant = [
    'nom' => $patient['nom'],
    'prenom' => $patient['prenom'],
    'sexe' => $patient['sexe'],
    'date_naissance' => $patient['date_naissance'],
    'telephone' => $patient['telephone'],
    'profession' => $patient['profession'],
    'poids' => $patient['poids'],
    'taille' => $patient['taille'],
    'loisirs' => $patient['loisirs'],
    'divers' => $patient['divers'],
    'antecedents_medicaux' => $patient['antecedents_medicaux'],
    'chirurgicaux' => $patient['chirurgicaux'],
    'familiaux' => $patient['familiaux'],
    'mentions_particulieres' => $patient['mentions_particulieres']
];

$histoStmt = $pdo->prepare("
    INSERT INTO historique_patients (
        id_patient, nom_patient, prenom_patient, action_type, details_action,
        id_utilisateur, nom_utilisateur, donnees_avant
    ) VALUES (?, ?, ?, 'suppression', ?, ?, ?, ?)
");

$histoStmt->execute([
    $id_patient,
    $patient['nom'],
    $patient['prenom'],
    "Patient supprimé: " . $patient['nom'] . " " . $patient['prenom'],
    $_SESSION['user']['id'],
    $_SESSION['user']['username'],
    json_encode($donnees_avant)
]);

// 🗑️ Supprimer les données liées d'abord
$pdo->prepare("DELETE FROM bons_examens WHERE id_patient = ?")->execute([$id_patient]);
$pdo->prepare("DELETE FROM observations WHERE id_patient = ?")->execute([$id_patient]);
$pdo->prepare("DELETE FROM ordonnances WHERE id_patient = ?")->execute([$id_patient]);
$pdo->prepare("DELETE FROM consultations WHERE id_patient = ?")->execute([$id_patient]);

// 🗑️ Supprimer le patient
$pdo->prepare("DELETE FROM patients WHERE id_patient = ?")->execute([$id_patient]);

header("Location: lister_patients.php?success=suppression_réussie");
exit();

// ==========================================
// 4. AJOUT DU LIEN DANS LA SIDEBAR
// ==========================================

// Dans includes/sidebar-medecin.php, ajouter ce lien :
/*
<?php if ($_SESSION['user']['statut'] === 'principal'): ?>
    <li class="pc-item">
        <a href="historique_patients.php" class="pc-link">
            <span class="pc-micon">📜</span>
            <span class="pc-mtext">Historique Patients</span>
        </a>
    </li>
<?php endif; ?>
*/

// ==========================================
// 5. SCRIPT SQL COMPLÉMENTAIRE
// ==========================================

/*
-- Index pour améliorer les performances
CREATE INDEX idx_historique_date_action ON historique_patients(date_action DESC);
CREATE INDEX idx_historique_composite ON historique_patients(action_type, date_action DESC);

-- Vue pour les statistiques rapides
CREATE VIEW v_stats_historique AS
SELECT 
    action_type,
    COUNT(*) as total_actions,
    COUNT(DISTINCT id_patient) as patients_concernes,
    COUNT(DISTINCT id_utilisateur) as utilisateurs_actifs,
    DATE(MIN(date_action)) as premiere_action,
    DATE(MAX(date_action)) as derniere_action
FROM historique_patients 
GROUP BY action_type;

-- Procédure pour nettoyer l'historique ancien (optionnel)
DELIMITER $
CREATE PROCEDURE CleanOldHistory(IN days_to_keep INT)
BEGIN
    DELETE FROM historique_patients 
    WHERE date_action < DATE_SUB(NOW(), INTERVAL days_to_keep DAY);
END$
DELIMITER ;
*/