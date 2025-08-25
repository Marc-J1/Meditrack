<?php
session_start();
require('fpdf/fpdf.php');
require_once 'db.php';

// ---- Vérif session & param ----
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    exit("Accès refusé.");
}
if (!isset($_GET['id'])) {
    exit("Ordonnance non spécifiée.");
}
$id_ordonnance = (int)$_GET['id'];
$id_medecin    = (int)$_SESSION['user']['id'];

// ---- Récupération ordonnance + patient ----
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

// Si ta table 'ordonnances' ne contient pas 'id_utilisateur', supprime le test suivant :
if (!$ord || (isset($ord['id_utilisateur']) && (int)$ord['id_utilisateur'] !== $id_medecin)) {
    exit("Ordonnance non trouvée ou accès interdit.");
}

// ---- Récupération médecin ----
$stmtM = $pdo->prepare("SELECT username, phone_number FROM users WHERE id_utilisateur = ?");
$stmtM->execute([$id_medecin]);
$doc = $stmtM->fetch();

// ---- Préparation contenu (même logique que ton code) ----
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

// ==== Création PDF A4 PAYSAGE avec 2 panneaux A5 PORTRAIT ====
$pdf = new FPDF('L', 'mm', 'A4');

// Définis tes marges externes ici (et réutilise ces variables)
$outerLeft   = 10;
$outerTop    = 10;
$outerRight  = 10;
$outerBottom = 10;

$pdf->SetMargins($outerLeft, $outerTop, $outerRight);
$pdf->SetAutoPageBreak(false);
$pdf->AddPage();

// Dimensions page
$pageW = $pdf->GetPageWidth();   // ≈ 297mm
$pageH = $pdf->GetPageHeight();  // ≈ 210mm

// Paramétrage colonnes A5
$gutter = 6; // espace central

// Largeur disponible pour 2 colonnes
$availW = $pageW - $outerLeft - $outerRight - $gutter;
// Largeur d'un panneau
$panelW = $availW / 2;
// Hauteur d'un panneau
$panelH = $pageH - $outerTop - $outerBottom;

// Coordonnées panneaux
$panel1X = $outerLeft;
$panel1Y = $outerTop;

$panel2X = $outerLeft + $panelW + $gutter;
$panel2Y = $panel1Y;

// (Optionnel) Cadre de découpe
function drawPanelBorder($pdf, $x, $y, $w, $h) {
    $pdf->SetDrawColor(180,180,180);
    $pdf->SetLineWidth(0.2);
    $pdf->Rect($x, $y, $w, $h);
}

// Rendu d’un exemplaire (garde ton “design” : mêmes polices/alignements)
function renderPrescriptionPanel($pdf, $x, $y, $w, $h, $doc, $ord, $contenu) {
    // Marges internes du panneau
    $inset  = 10;                 // marge interne
    $innerX = $x + $inset;
    $innerY = $y + $inset;
    $innerW = $w - 2*$inset;

    // ---- En-tête médecin (gauche) ----
    $pdf->SetFont('Arial','',12);
    $pdf->SetXY($innerX, $innerY);
    $pdf->Cell($innerW, 6, utf8_decode("Docteur : ".($doc['username'] ?? '')), 0, 2, 'L');
    $pdf->Cell($innerW, 6, utf8_decode("Tél : ".(!empty($doc['phone_number']) ? $doc['phone_number'] : "Non renseigné")), 0, 2, 'L');
    $pdf->Cell($innerW, 6, utf8_decode("Consultation de médecine interne"), 0, 2, 'L');
    $pdf->Cell($innerW, 6, utf8_decode("Brazzaville"), 0, 2, 'L');

    $pdf->Ln(6);

    // ---- Titre centré ----
    $pdf->SetFont('Arial','B',14);
    $pdf->SetX($innerX);
    $pdf->Cell($innerW, 10, utf8_decode("Ordonnance Médicale"), 0, 2, 'C');

    // ---- Date centrée ----
    $pdf->SetFont('Arial','',12);
    $dateTxt = "Date : ".date('d/m/Y', strtotime($ord['date_ordonnance']));
    $pdf->SetX($innerX);
    $pdf->Cell($innerW, 8, utf8_decode($dateTxt), 0, 2, 'C');

    $pdf->Ln(3);

    // ---- Infos patient (gauche) ----
    $patientLine = "M/Mme : ".($ord['patient_nom'] ?? '')." ".($ord['patient_prenom'] ?? '');
    $pdf->SetX($innerX);
    $pdf->Cell($innerW, 8, utf8_decode($patientLine), 0, 2, 'L');

    $pdf->Ln(4);

    // ---- Bloc contenu principal ----
    $blockW = min($innerW, 160);          // largeur contrôlée (ton ancien 160)
    $leftX  = $innerX + ($innerW - $blockW) / 2;

    $pdf->SetFont('Arial','',12);
    $pdf->SetXY($leftX, $pdf->GetY());
    $pdf->MultiCell($blockW, 8, utf8_decode($contenu), 0, 'L');
}

// (Optionnel) Bordures de découpe
drawPanelBorder($pdf, $panel1X, $panel1Y, $panelW, $panelH);
drawPanelBorder($pdf, $panel2X, $panel2Y, $panelW, $panelH);

// Rendu des 2 exemplaires
renderPrescriptionPanel($pdf, $panel1X, $panel1Y, $panelW, $panelH, $doc, $ord, $contenu);
renderPrescriptionPanel($pdf, $panel2X, $panel2Y, $panelW, $panelH, $doc, $ord, $contenu);

// Sortie
$pdf->Output("I", "ordonnance_".$ord['id'].".pdf");
