<?php
session_start();

require('fpdf/fpdf.php');
require_once 'db.php';
include 'includes/auto_track.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'Génération du PDF bon d\'examen');

// ——— Sécurise le buffer: évite tout output avant le PDF ———
if (ob_get_length()) { ob_end_clean(); }

// Vérifier que l'ID est présent
if (!isset($_GET['id'])) {
    die("ID du bon d'examen manquant.");
}
$id_bon = (int)$_GET['id'];

// Récupération des données
$stmt = $pdo->prepare("
    SELECT 
        b.*, 
        p.nom, p.prenom, p.date_naissance, p.poids,
        u.username AS medecin, u.phone_number AS tel_medecin
    FROM bons_examens b
    JOIN patients p ON b.id_patient = p.id_patient
    LEFT JOIN users u ON b.id_utilisateur = u.id_utilisateur
    WHERE b.id = ?
");
$stmt->execute([$id_bon]);
$bon = $stmt->fetch(PDO::FETCH_ASSOC);
if (!$bon) {
    die("Bon d'examen introuvable.");
}

// Préparer les données (avec fallback propres)
$nom_prenom = trim(($bon['nom'] ?? '') . ' ' . ($bon['prenom'] ?? ''));
$poidsTxt   = ($bon['poids'] !== null && $bon['poids'] !== '') ? ($bon['poids'] . ' kg') : '-';
$service    = trim((string)($bon['service_demandeur'] ?? ''));
$service    = ($service !== '') ? $service : '-';
$clinique   = trim((string)($bon['renseignement_clinique'] ?? ''));
$dateNow    = date('d/m/Y H:i');

$ageTxt = '-';
if (!empty($bon['date_naissance'])) {
    try {
        $birthDate = new DateTime($bon['date_naissance']);
        $age       = (new DateTime())->diff($birthDate)->y;
        $ageTxt    = $age . ' ans';
    } catch (\Throwable $e) {
        $ageTxt = '-';
    }
}

// Petite fonction utilitaire pour du texte UTF-8 -> ISO-8859-1 (FPDF)
function t($s) { return utf8_decode((string)$s); }

// ===================
//   Génération PDF
// ===================
$pdf = new FPDF('P', 'mm', 'A4');
$pdf->SetAutoPageBreak(true, 15);
$pdf->AddPage();

// Marges
$pdf->SetMargins(12, 12, 12);

// ——— ENTÊTE ———
/* Logo (gauche) */
if (file_exists('DattaAble-1.0.0/dist/assets/images/logo1.png')) {
    $pdf->Image('DattaAble-1.0.0/dist/assets/images/logo1.png', 12, 10, 26);
}

/* Bloc titre + établissement */
$pdf->SetFont('Arial', 'B', 14);
$pdf->SetXY(42, 10);
$pdf->Cell(110, 7, t("Centre Hospitalier – Service de Médecine / Laboratoire"), 0, 2);
$pdf->SetFont('Arial', '', 10);
$pdf->Cell(110, 5, t("Brazzaville, Congo"), 0, 2);
$pdf->Ln(1);

/* Bloc méta (droite) */
$pdf->SetXY(150, 10);
$pdf->SetFont('Arial', '', 10);
$pdf->Cell(50, 6, t("Bon n° ") . str_pad($id_bon, 6, '0', STR_PAD_LEFT), 0, 2, 'R');
$pdf->Cell(50, 6, t("Émis le : ") . $dateNow, 0, 2, 'R');

/* Titre centré */
$pdf->Ln(6);
$pdf->SetFont('Arial', 'B', 18);
$pdf->Cell(0, 10, t("BON D'EXAMEN"), 0, 1, 'C');
$pdf->Ln(2);

// Séparateur
$pdf->SetDrawColor(220,220,220);
$pdf->Line(12, $pdf->GetY(), 198, $pdf->GetY());
$pdf->Ln(4);

// ===============
//  PATIENT
// ===============
// ===============
//  PATIENT
// ===============
// =================
//  INFORMATIONS PATIENT
// =================
$pdf->SetFont('Arial', 'B', 11);
$pdf->Cell(0, 7, utf8_decode("Informations Patient"), 0, 1);
$pdf->SetDrawColor(230,230,230);
$pdf->Rect(12, $pdf->GetY(), 186, 34);
$yTop = $pdf->GetY(); 
$pdf->Ln(2);

$pdf->SetFont('Arial', '', 11);

// Nom & prénom seul sur la première ligne
$pdf->SetXY(14, $yTop + 3);
$pdf->MultiCell(182, 6, utf8_decode("Nom & Prénom : " . strtoupper($nom_prenom)), 0);

// Deuxième ligne : âge + poids + date de naissance
$pdf->SetX(14);
$pdf->Cell(60, 6, utf8_decode("Âge : $age ans"), 0, 0);
$pdf->Cell(60, 6, utf8_decode("Poids : $poids"), 0, 0);
$pdf->Cell(60, 6, utf8_decode("Date de naissance : " . date('d/m/Y', strtotime($bon['date_naissance']))), 0, 1);

// Troisième ligne : sexe

$pdf->Ln(5);

// =================
//  SERVICE DEMANDEUR (optionnel)
// =================
if (!empty($service)) {
    $pdf->SetFont('Arial', 'B', 11);
    $pdf->Cell(0, 7, utf8_decode("Service Demandeur"), 0, 1);
    $pdf->SetDrawColor(230,230,230);
    $pdf->Rect(12, $pdf->GetY(), 186, 10);
    $pdf->SetXY(14, $pdf->GetY() + 2);
    $pdf->SetFont('Arial', '', 11);
    $pdf->MultiCell(182, 6, utf8_decode($service), 0);
    $pdf->Ln(5);
}



// ==========================
//  RENSEIGNEMENTS CLINIQUES
// ==========================
$pdf->SetFont('Arial', 'B', 11);
$pdf->Cell(0, 7, t("Renseignements cliniques"), 0, 1);
$hBox = 70; // zone généreuse
$yStart = $pdf->GetY();
$pdf->Rect(12, $yStart, 186, $hBox);
$pdf->SetXY(14, $yStart + 3);
$pdf->SetFont('Arial', '', 11);
$pdf->MultiCell(182, 6, t($clinique !== '' ? $clinique : '-'), 0);

// ===============
//  SIGNATURE
// ===============
$pdf->Ln(4);
$ySigStart = max($pdf->GetY() + 4, $yStart + $hBox + 4);
$pdf->SetY($ySigStart);
$pdf->SetFont('Arial', 'B', 11);
$pdf->Cell(0, 7, t("Signature"), 0, 1, 'R');

$pdf->SetY($pdf->GetY() + 18);
$x1 = 130; $x2 = 195; $y = $pdf->GetY();
$pdf->Line($x1, $y, $x2, $y);
$pdf->SetY($y + 3);
$pdf->SetFont('Arial', '', 10);
$pdf->Cell(0, 5, t("Signature et cachet du médecin"), 0, 1, 'R');

// ——— Sortie PDF ———
if (ob_get_length()) { ob_end_clean(); }
$pdf->Output('I', 'bon_examen_' . $id_bon . '.pdf');
exit;
