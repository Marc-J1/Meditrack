<?php
require_once '../db.php';

header('Content-Type: application/json');

// Sécurisation des paramètres POST
$draw = intval($_POST['draw'] ?? 0);
$start = intval($_POST['start'] ?? 0);
$length = intval($_POST['length'] ?? 10);
$search = $_POST['search']['value'] ?? '';

// Filtres personnalisés
$date_debut = $_POST['date_debut'] ?? '';
$date_fin = $_POST['date_fin'] ?? '';
$medecin = $_POST['medecin'] ?? '';
$statut = $_POST['statut'] ?? ''; // Pas utilisé pour les observations

// Configuration des colonnes pour le tri
$columns = [
    0 => 'o.date_observation',
    1 => 'patient_nom',
    2 => 'u.username',
    3 => 'o.type_observation',
    4 => 'o.contenu'
];

$order_column = $columns[$_POST['order'][0]['column'] ?? 0] ?? 'o.date_observation';
$order_dir = $_POST['order'][0]['dir'] ?? 'DESC';

// Requête de base avec jointures
$base_query = "
    FROM observations o
    LEFT JOIN patients p ON o.id_patient = p.id_patient
    LEFT JOIN users u ON o.id_utilisateur = u.id_utilisateur
    WHERE 1=1
";

$params = [];

// Application des filtres
if (!empty($date_debut)) {
    $base_query .= " AND DATE(o.date_observation) >= :date_debut";
    $params['date_debut'] = $date_debut;
}

if (!empty($date_fin)) {
    $base_query .= " AND DATE(o.date_observation) <= :date_fin";
    $params['date_fin'] = $date_fin;
}

if (!empty($medecin)) {
    $base_query .= " AND u.username = :medecin";
    $params['medecin'] = $medecin;
}

if (!empty($search)) {
    $base_query .= " AND (
        p.nom LIKE :search OR
        p.prenom LIKE :search OR
        u.username LIKE :search OR
        o.type_observation LIKE :search OR
        o.contenu LIKE :search
    )";
    $params['search'] = '%' . $search . '%';
}

// Comptage total des enregistrements
$total_query = "SELECT COUNT(*) FROM observations";
$stmt_total = $pdo->query($total_query);
$total_records = $stmt_total->fetchColumn();

// Comptage des enregistrements filtrés
$filtered_query = "SELECT COUNT(*) " . $base_query;
$stmt_filtered = $pdo->prepare($filtered_query);
foreach ($params as $key => $value) {
    $stmt_filtered->bindValue(":$key", $value);
}
$stmt_filtered->execute();
$filtered_records = $stmt_filtered->fetchColumn();

// Validation de la colonne de tri
$valid_order_columns = [
    'o.date_observation',
    'patient_nom',
    'u.username',
    'o.type_observation',
    'o.contenu'
];

if (!in_array($order_column, $valid_order_columns)) {
    $order_column = 'o.date_observation';
}

// Requête principale pour récupérer les données
$data_query = "
    SELECT 
        o.id,
        o.date_observation,
        CONCAT(COALESCE(p.nom, ''), ' ', COALESCE(p.prenom, '')) AS patient,
        COALESCE(p.nom, '') AS patient_nom,
        COALESCE(p.prenom, '') AS patient_prenom,
        COALESCE(u.username, 'N/A') AS medecin,
        COALESCE(o.type_observation, '') AS type_observation,
        COALESCE(o.contenu, '') AS contenu
    " . $base_query . "
    ORDER BY $order_column $order_dir
    LIMIT :start, :length
";

$stmt_data = $pdo->prepare($data_query);
foreach ($params as $key => $value) {
    $stmt_data->bindValue(":$key", $value);
}
$stmt_data->bindValue(":start", $start, PDO::PARAM_INT);
$stmt_data->bindValue(":length", $length, PDO::PARAM_INT);
$stmt_data->execute();
$data = $stmt_data->fetchAll(PDO::FETCH_ASSOC);

// Formatage des données pour DataTables
$formatted_data = [];
foreach ($data as $row) {
    $formatted_data[] = [
        'id' => $row['id'],
        'date_observation' => $row['date_observation'],
        'patient' => trim($row['patient']) ?: 'Patient inconnu',
        'patient_nom' => $row['patient_nom'],
        'patient_prenom' => $row['patient_prenom'],
        'medecin' => $row['medecin'],
        'type_observation' => $row['type_observation'],
        'contenu' => $row['contenu']
    ];
}

// Réponse JSON
echo json_encode([
    'draw' => $draw,
    'recordsTotal' => $total_records,
    'recordsFiltered' => $filtered_records,
    'data' => $formatted_data
]);
?>