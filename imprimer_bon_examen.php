<?php
require('fpdf/fpdf.php');
require_once 'db.php';

if (!isset($_GET['id'])) {
    die("ID du bon d'examen manquant.");
}

$id_bon = $_GET['id'];

$stmt = $pdo->prepare("
    SELECT b.*, p.nom, p.prenom, p.date_naissance, p.poids, u.username AS medecin
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

// Calcul de l'âge
$birthDate = new DateTime($bon['date_naissance']);
$today = new DateTime();
$age = $today->diff($birthDate)->y;

// Préparation des données
$nom_prenom = $bon['nom'] . ' ' . $bon['prenom'];
$poids = $bon['poids'] . ' kg';
$service = $bon['service_demandeur'];
$clinique = $bon['renseignement_clinique'];
$date = date('d/m/Y H:i');

// Création du PDF
$pdf = new FPDF();
$pdf->AddPage();

// Logo (à ajuster si besoin)
$pdf->Image('DattaAble-1.0.0/dist/assets/images/logo1.png', 160, 10, 40);

// En-tête
$pdf->SetFont('Arial', 'B', 11);
$pdf->Cell(0, 5, 'MediTrack', 0, 1);
$pdf->SetFont('Arial', '', 10);
$pdf->Ln(10);

// Titre principal
$pdf->SetFont('Arial', 'B', 14);
$pdf->Cell(0, 10, utf8_decode("BON D'EXAMEN"), 0, 1, 'C');

// Date
$pdf->SetFont('Arial', '', 10);
$pdf->Cell(0, 5, "Date et heure : $date", 0, 1, 'R');
$pdf->Ln(5);

// Infos patient
$pdf->SetFont('Arial', '', 11);
$pdf->Cell(50, 8, 'Nom et prénom :', 0, 0);
$pdf->Cell(0, 8, utf8_decode($nom_prenom), 0, 1);
$pdf->Cell(25, 8, 'Âge :', 0, 0);
$pdf->Cell(50, 8, $age, 0, 0);
$pdf->Cell(20, 8, 'Poids :', 0, 0);
$pdf->Cell(0, 8, utf8_decode($poids), 0, 1);

// Service demandeur
$pdf->Ln(5);
$pdf->SetFont('Arial', 'B', 11);
$pdf->Cell(0, 8, 'Service Demandeur :', 0, 1);
$pdf->SetFont('Arial', '', 11);
$pdf->MultiCell(0, 8, utf8_decode($service), 1);

// Renseignement clinique
$pdf->Ln(5);
$pdf->SetFont('Arial', 'B', 11);
$pdf->Cell(0, 8, 'Renseignement clinique :', 0, 1);
$pdf->SetFont('Arial', '', 11);
$pdf->MultiCell(0, 8, utf8_decode($clinique), 1);

// Signature
$pdf->Ln(20);
$pdf->Cell(0, 8, 'Docteur ' . utf8_decode($bon['medecin']), 0, 1, 'R');

// Générer le PDF
$pdf->Output('I', 'bon_examen.pdf');
