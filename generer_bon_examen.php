<?php
require('fpdf/fpdf.php');
require_once 'db.php';

ob_clean(); // Vide tout contenu envoyé auparavant (important !)

// Vérifier que l'ID est présent
if (!isset($_GET['id'])) {
    die("ID du bon d'examen manquant.");
}

$id_bon = $_GET['id'];

// Requête SQL pour récupérer les données
$stmt = $pdo->prepare("
    SELECT b.*, p.nom, p.prenom, p.date_naissance, p.poids, u.username AS medecin, u.phone_number AS tel_medecin
    FROM bons_examens b
    JOIN patients p ON b.id_patient = p.id_patient
    LEFT JOIN users u ON b.id_utilisateur = u.id_utilisateur
    WHERE b.id = ?
");
$stmt->execute([$id_bon]);
$bon = $stmt->fetch();

if (!$bon) {
    die("Bon d'examen introuvable.");
}

// Préparer les données
$nom_prenom = $bon['nom'] . ' ' . $bon['prenom'];
$poids = $bon['poids'] . ' kg';
$service = $bon['service_demandeur'];
$clinique = $bon['renseignement_clinique'];
$date = date('d/m/Y H:i');
$birthDate = new DateTime($bon['date_naissance']);
$age = (new DateTime())->diff($birthDate)->y;

// Générer le PDF
$pdf = new FPDF();
$pdf->AddPage();

// Logo MediTrack en haut à droite
$pdf->Image('DattaAble-1.0.0/dist/assets/images/logo1.png', 150, 10, 50);

// En-tête gauche - Informations du médecin
$pdf->SetFont('Arial', 'B', 12);
$pdf->SetXY(10, 10);
$pdf->Cell(0, 6, utf8_decode('Dr. ' . $bon['medecin']), 0, 1);
$pdf->SetFont('Arial', '', 10);
$pdf->SetX(10);
$pdf->Cell(0, 5, utf8_decode('Tél : ' . ($bon['tel_medecin'] ?? 'Non renseigné')), 0, 1);
$pdf->Cell(0, 5, utf8_decode("Brazzaville CG "), 0, 1);

$pdf->Ln(15);

// Titre principal
$pdf->SetFont('Arial', 'B', 18);
$pdf->Cell(0, 12, utf8_decode("BON D'EXAMEN"), 0, 1, 'C');

$pdf->Ln(5);

// Date et heure
$pdf->SetFont('Arial', '', 10);
$pdf->Cell(0, 6, "Date et heure : $date", 0, 1, 'R');

$pdf->Ln(10);

// Section informations patient
$pdf->SetFont('Arial', 'B', 11);
$pdf->Cell(60, 8, utf8_decode('NOM ET PRÉNOM :'), 0, 0);
$pdf->SetFont('Arial', '', 11);
$pdf->Cell(0, 8, utf8_decode(strtoupper($nom_prenom)), 0, 1);

$pdf->SetFont('Arial', 'B', 11);
$pdf->Cell(20, 8, utf8_decode('ÂGE :'), 0, 0);
$pdf->SetFont('Arial', '', 11);
$pdf->Cell(40, 8, $age . ' ans', 0, 0);

$pdf->SetFont('Arial', 'B', 11);
$pdf->Cell(20, 8, 'POIDS :', 0, 0);
$pdf->SetFont('Arial', '', 11);
$pdf->Cell(0, 8, utf8_decode($poids), 0, 1);

$pdf->SetFont('Arial', 'B', 11);
$pdf->Cell(60, 8, 'SERVICE DEMANDEUR :', 0, 1);

$pdf->Ln(5);

// Grande zone pour le service demandeur
$pdf->Rect(10, $pdf->GetY(), 190, 40);
$pdf->SetFont('Arial', '', 11);
$pdf->SetXY(12, $pdf->GetY() + 2);
$pdf->MultiCell(186, 6, utf8_decode($service), 0);

$pdf->SetY($pdf->GetY() + 40 - ($pdf->GetY() - ($pdf->GetY() - 40)) + 10);

// Section renseignement clinique
$pdf->SetFont('Arial', 'B', 11);
$pdf->Cell(0, 8, 'Renseignement clinique :', 0, 1);

$pdf->Ln(2);

// Zone de texte pour renseignement clinique
$currentY = $pdf->GetY();
$pdf->Rect(10, $currentY, 190, 60);
$pdf->SetXY(12, $currentY + 2);
$pdf->SetFont('Arial', '', 11);
$pdf->MultiCell(186, 6, utf8_decode($clinique), 0);

// Positionnement en bas pour la signature
$pdf->SetY($currentY + 70);

// Signature du médecin
$pdf->SetFont('Arial', 'B', 12);
$pdf->Cell(0, 10, utf8_decode('Docteur'), 0, 1, 'R');

// Ajout d'une ligne pour la signature
$pdf->SetY($pdf->GetY() + 20);
$pdf->Line(140, $pdf->GetY(), 190, $pdf->GetY());
$pdf->SetY($pdf->GetY() + 3);
$pdf->SetFont('Arial', '', 10);
$pdf->Cell(0, 5, 'Signature et cachet', 0, 1, 'R');

ob_end_clean(); // IMPORTANT : empêche tout texte avant d'envoyer le PDF
$pdf->Output('I', 'bon_examen_' . $id_bon . '.pdf');
exit();
?>