<?php
session_start();
require('fpdf/fpdf.php');
require_once 'db.php';

// Vérification de session médecin
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    exit("Accès refusé.");
}
if (!isset($_GET['id'])) {
    exit("Ordonnance non spécifiée.");
}

$id_ordonnance = (int)$_GET['id'];
$id_medecin    = (int)$_SESSION['user']['id'];

// --- Récupération de l'ordonnance + patient
$stmt = $pdo->prepare("
    SELECT o.*,
           p.nom    AS patient_nom,
           p.prenom AS patient_prenom,
           p.sexe,
           o.date_ordonnance
    FROM ordonnances o
    JOIN patients p ON o.id_patient = p.id_patient
    WHERE o.id = ?
");
$stmt->execute([$id_ordonnance]);
$ord = $stmt->fetch();

if (!$ord || $ord['id_utilisateur'] != $id_medecin) {
    exit("Ordonnance non trouvée ou accès interdit.");
}

// --- Récupération du médecin
$stmtM = $pdo->prepare("SELECT username, phone_number FROM users WHERE id_utilisateur = ?");
$stmtM->execute([$id_medecin]);
$doc = $stmtM->fetch();

// ===== Création PDF =====
$pdf = new FPDF();
$pdf->AddPage();
$pdf->SetFont('Arial','',12);

// --- Infos médecin en haut à gauche ---
$pdf->Cell(0,6,utf8_decode("Docteur : ".$doc['username']),0,1,'L');
$pdf->Cell(0,6,utf8_decode("Tél : ".($doc['phone_number'] ?: "Non renseigné")),0,1,'L');
$pdf->Cell(0,6,utf8_decode("Consultation de médecine interne"),0,1,'L');
$pdf->Cell(0,6,utf8_decode("Brazzaville"),0,1,'L');

$pdf->Ln(15);

// --- Titre Ordonnance (avant la date) ---
$pdf->SetFont('Arial','B',14);
$pdf->Cell(0,10,utf8_decode("Ordonnance Médicale"),0,1,'C');

// --- Date ---
$pdf->SetFont('Arial','',12);
$pdf->Cell(0,8,utf8_decode("Date : ".date('d/m/Y', strtotime($ord['date_ordonnance']))),0,1,'C');

$pdf->Ln(10);

// --- Infos patient ---

$pdf->SetFont('Arial','',12);
$pdf->Cell(0,8,utf8_decode("Ms/Mme : ".' '.$ord['patient_nom']." ".$ord['patient_prenom']),0,1,'L');

$pdf->Ln(15);

/* --------- CONTENU DE L’ORDONNANCE ---------
   On affiche NOTES en priorité (c’est là où tout est saisi maintenant).
   Si NOTES est vide, fallback vers medicaments/posologie/duree_traitement. */
$parts = [];
if (!empty($ord['notes'])) {
    $parts[] = trim($ord['notes']);
} else {
    if (!empty($ord['medicaments']))      $parts[] = trim($ord['medicaments']);
    if (!empty($ord['posologie']))        $parts[] = trim($ord['posologie']);
    if (!empty($ord['duree_traitement'])) $parts[] = "Durée du traitement : ".trim($ord['duree_traitement']);
}
$contenu = trim(implode("\n\n", $parts));
if ($contenu === '') $contenu = "—";

// --- Bloc ordonnance : centré visuellement sans toucher aux marges ---
$pdf->SetFont('Arial','',12);
$blockWidth = 160;                      // largeur du bloc (ajuste à 170/150 si tu veux)
$pageWidth  = $pdf->GetPageWidth();     // A4 ≈ 210mm
$leftX      = ($pageWidth - $blockWidth) / 2;

$pdf->SetX($leftX);
$pdf->MultiCell($blockWidth, 8, utf8_decode($contenu), 0, 'L'); // aligné à gauche à l’intérieur d’un bloc centré

// Sortie
$pdf->Output("I", "ordonnance_".$ord['id'].".pdf");
