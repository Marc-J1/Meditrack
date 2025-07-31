
<?php
session_start();
require_once 'db.php';
require('fpdf/fpdf.php');

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    exit("Accès refusé.");
}

if (!isset($_GET['id'])) {
    exit("Ordonnance non spécifiée.");
}

$id_ordonnance = $_GET['id'];
$id_medecin = $_SESSION['user']['id'];

$stmt = $pdo->prepare("
    SELECT o.*, p.nom AS patient_nom, p.prenom AS patient_prenom, p.date_naissance, p.sexe, o.id_utilisateur
    FROM ordonnances o
    JOIN patients p ON o.id_patient = p.id_patient
    WHERE o.id = ?
");
$stmt->execute([$id_ordonnance]);
$ordonnance = $stmt->fetch();

if (!$ordonnance || $ordonnance['id_utilisateur'] != $id_medecin) {
    exit("Ordonnance non trouvée ou accès interdit.");
}

$stmt_medecin = $pdo->prepare("SELECT username, phone_number, mail FROM users WHERE id_utilisateur = ?");
$stmt_medecin->execute([$id_medecin]);
$medecin = $stmt_medecin->fetch();

class PDF extends FPDF {
    function Header() {
        // En-tête épuré avec logo discret
        if (file_exists('logo1.png')) {
            $this->Image('logo1.png', 170, 10, 25);
        }
        $this->Ln(5);
    }

    function Footer() {
        $this->SetY(-15);
        $this->SetFont('Arial', 'I', 8);
        $this->SetTextColor(100, 100, 100);
        $this->Cell(0, 5, utf8_decode("Ordonnance générée le " . date("d/m/Y à H:i")), 0, 0, 'C');
    }

    function DrawLine() {
        $this->SetDrawColor(200, 200, 200);
        $this->Line(20, $this->GetY(), 190, $this->GetY());
        $this->Ln(3);
    }

    function SectionTitle($title) {
        $this->Ln(5);
        $this->SetFont('Arial', 'B', 11);
        $this->SetTextColor(40, 40, 40);
        $this->Cell(0, 6, utf8_decode($title), 0, 1, 'L');
        $this->SetDrawColor(40, 40, 40);
        $this->Line(20, $this->GetY(), 190, $this->GetY());
        $this->Ln(3);
    }

    function InfoLine($label, $value) {
        $this->SetFont('Arial', 'B', 10);
        $this->SetTextColor(60, 60, 60);
        $this->Cell(40, 5, utf8_decode($label . " :"), 0, 0, 'L');
        $this->SetFont('Arial', '', 10);
        $this->SetTextColor(20, 20, 20);
        $this->Cell(0, 5, utf8_decode($value), 0, 1, 'L');
    }

    function ContentBlock($text) {
        $this->SetFont('Arial', '', 10);
        $this->SetTextColor(20, 20, 20);
        $this->MultiCell(0, 5, utf8_decode($text));
        $this->Ln(2);
    }
}

$pdf = new PDF();
$pdf->AddPage();
$pdf->SetMargins(20, 20, 20);

// === EN-TÊTE MÉDECIN ===
$pdf->SetFont('Arial', 'B', 16);
$pdf->SetTextColor(20, 20, 20);
$pdf->Cell(0, 8, utf8_decode("Dr " . strtoupper($medecin['username'])), 0, 1, 'L');

$pdf->SetFont('Arial', '', 10);
$pdf->SetTextColor(80, 80, 80);
$pdf->Cell(0, 5, utf8_decode("Médecin Généraliste - Diplôme d'État"), 0, 1, 'L');

$pdf->Ln(3);
$pdf->InfoLine("Téléphone", $medecin['phone_number'] ?? "Non renseigné");
$pdf->InfoLine("Email", $medecin['mail'] ?? "Non renseigné");

$pdf->Ln(8);
$pdf->DrawLine();

// === TITRE ORDONNANCE ===
$pdf->Ln(5);
$pdf->SetFont('Arial', 'B', 18);
$pdf->SetTextColor(20, 20, 20);
$pdf->Cell(0, 10, "ORDONNANCE", 0, 1, 'C');
$pdf->Ln(8);

// === INFORMATIONS PATIENT ===
$age = date_diff(date_create($ordonnance['date_naissance']), date_create('now'))->y;
$pdf->SectionTitle("PATIENT");

$pdf->InfoLine("Nom", strtoupper($ordonnance['patient_nom']) . " " . ucfirst($ordonnance['patient_prenom']));
$pdf->InfoLine("Date de naissance", date("d/m/Y", strtotime($ordonnance['date_naissance'])) . " (" . $age . " ans)");
$pdf->InfoLine("Sexe", ucfirst($ordonnance['sexe']));
$pdf->InfoLine("Date d'ordonnance", date("d/m/Y", strtotime($ordonnance['date_ordonnance'])));

// === PRESCRIPTION ===
$pdf->SectionTitle("PRESCRIPTION");
$pdf->ContentBlock($ordonnance['medicaments']);

// === POSOLOGIE ===
if (!empty($ordonnance['posologie'])) {
    $pdf->SectionTitle("POSOLOGIE");
    $pdf->ContentBlock($ordonnance['posologie']);
}

// === DURÉE DU TRAITEMENT ===
if (!empty($ordonnance['duree_traitement'])) {
    $pdf->SectionTitle("DURÉE DU TRAITEMENT");
    $pdf->ContentBlock($ordonnance['duree_traitement']);
}

// === NOTES MÉDICALES ===
if (!empty($ordonnance['notes'])) {
    $pdf->SectionTitle("NOTES MÉDICALES");
    $pdf->ContentBlock($ordonnance['notes']);
}

// === SIGNATURE ===
$pdf->Ln(15);
$pdf->SetFont('Arial', '', 10);
$pdf->SetTextColor(80, 80, 80);
$pdf->Cell(0, 5, "Fait le " . date("d/m/Y", strtotime($ordonnance['date_ordonnance'])), 0, 1, 'R');
$pdf->Ln(3);
$pdf->Cell(0, 5, "Signature du médecin", 0, 1, 'R');
$pdf->Ln(8);
$pdf->SetFont('Arial', 'B', 11);
$pdf->SetTextColor(20, 20, 20);
$pdf->Cell(0, 5, utf8_decode("Dr " . strtoupper($medecin['username'])), 0, 1, 'R');

$pdf->Output("I", "ordonnance_" . $ordonnance['id'] . ".pdf");
?>


Style 2 

<?php
session_start();
require_once 'db.php';
require('fpdf/fpdf.php');

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    exit("Accès refusé.");
}

if (!isset($_GET['id'])) {
    exit("Ordonnance non spécifiée.");
}

$id_ordonnance = $_GET['id'];
$id_medecin = $_SESSION['user']['id'];

$stmt = $pdo->prepare("
    SELECT o.*, p.nom AS patient_nom, p.prenom AS patient_prenom, p.date_naissance, p.sexe, o.id_utilisateur
    FROM ordonnances o
    JOIN patients p ON o.id_patient = p.id_patient
    WHERE o.id = ?
");
$stmt->execute([$id_ordonnance]);
$ordonnance = $stmt->fetch();

if (!$ordonnance || $ordonnance['id_utilisateur'] != $id_medecin) {
    exit("Ordonnance non trouvée ou accès interdit.");
}

$stmt_medecin = $pdo->prepare("SELECT username, phone_number, mail FROM users WHERE id_utilisateur = ?");
$stmt_medecin->execute([$id_medecin]);
$medecin = $stmt_medecin->fetch();

class PDF extends FPDF {
    private $primaryColor = array(41, 128, 185);  // Bleu médical
    private $darkColor = array(44, 62, 80);      // Gris foncé
    private $lightColor = array(236, 240, 241);  // Gris clair

    function Header() {
        // Bande supérieure colorée
        $this->SetFillColor($this->primaryColor[0], $this->primaryColor[1], $this->primaryColor[2]);
        $this->Rect(0, 0, 210, 8, 'F');
        
        // Logo si disponible
        if (file_exists('logo1.png')) {
            $this->Image('logo1.png', 175, 12, 20);
        }
        $this->Ln(15);
    }

    function Footer() {
        $this->SetY(-20);
        // Ligne de séparation
        $this->SetDrawColor($this->primaryColor[0], $this->primaryColor[1], $this->primaryColor[2]);
        $this->Line(15, $this->GetY(), 195, $this->GetY());
        $this->Ln(3);
        
        $this->SetFont('Arial', 'I', 8);
        $this->SetTextColor(120, 120, 120);
        $this->Cell(0, 4, utf8_decode("Document confidentiel - Ordonnance générée le " . date("d/m/Y à H:i")), 0, 0, 'C');
    }

    function SectionHeader($title, $icon = '') {
        $this->Ln(8);
        
        // Fond de section
        $this->SetFillColor($this->lightColor[0], $this->lightColor[1], $this->lightColor[2]);
        $this->Rect(15, $this->GetY(), 180, 8, 'F');
        
        // Bordure gauche colorée
        $this->SetFillColor($this->primaryColor[0], $this->primaryColor[1], $this->primaryColor[2]);
        $this->Rect(15, $this->GetY(), 3, 8, 'F');
        
        $this->SetFont('Arial', 'B', 11);
        $this->SetTextColor($this->darkColor[0], $this->darkColor[1], $this->darkColor[2]);
        $this->Cell(180, 8, utf8_decode($title), 0, 1, 'L');
        $this->Ln(3);
    }

    function InfoRow($label, $value, $fullWidth = false) {
        $this->SetFont('Arial', 'B', 9);
        $this->SetTextColor(100, 100, 100);
        
        if ($fullWidth) {
            $this->Cell(180, 5, utf8_decode($label . " :"), 0, 1, 'L');
            $this->SetFont('Arial', '', 10);
            $this->SetTextColor($this->darkColor[0], $this->darkColor[1], $this->darkColor[2]);
            $this->MultiCell(180, 5, utf8_decode($value));
        } else {
            $this->Cell(50, 5, utf8_decode($label . " :"), 0, 0, 'L');
            $this->SetFont('Arial', '', 10);
            $this->SetTextColor($this->darkColor[0], $this->darkColor[1], $this->darkColor[2]);
            $this->Cell(130, 5, utf8_decode($value), 0, 1, 'L');
        }
        $this->Ln(1);
    }

    function ContentBox($content) {
        // Cadre pour le contenu
        $this->SetDrawColor(200, 200, 200);
        $this->SetFillColor(252, 252, 252);
        
        $x = $this->GetX();
        $y = $this->GetY();
        
        $this->SetFont('Arial', '', 10);
        $this->SetTextColor($this->darkColor[0], $this->darkColor[1], $this->darkColor[2]);
        
        // Calculer la hauteur nécessaire
        $lines = explode("\n", $content);
        $height = count($lines) * 5 + 6;
        
        $this->Rect($x, $y, 180, $height, 'DF');
        $this->SetXY($x + 5, $y + 3);
        $this->MultiCell(170, 5, utf8_decode($content));
        $this->Ln(3);
    }
}

$pdf = new PDF();
$pdf->AddPage();
$pdf->SetMargins(15, 15, 15);

// === EN-TÊTE MÉDECIN ===
$pdf->SetFont('Arial', 'B', 18);
$pdf->SetTextColor(41, 128, 185);
$pdf->Cell(0, 10, utf8_decode("Dr " . strtoupper($medecin['username'])), 0, 1, 'L');

$pdf->SetFont('Arial', 'I', 11);
$pdf->SetTextColor(100, 100, 100);
$pdf->Cell(0, 6, utf8_decode("Médecin Généraliste - Diplôme d'État"), 0, 1, 'L');

$pdf->Ln(5);
$pdf->SetFont('Arial', '', 10);
$pdf->SetTextColor(44, 62, 80);
$pdf->Cell(0, 5, utf8_decode("Tél : " . ($medecin['phone_number'] ?? "Non renseigné") . " | Email : " . ($medecin['mail'] ?? "Non renseigné")), 0, 1, 'L');

// === TITRE ORDONNANCE ===
$pdf->Ln(12);
$pdf->SetFont('Arial', 'B', 20);
$pdf->SetTextColor(41, 128, 185);
$pdf->Cell(0, 12, "ORDONNANCE MEDICALE", 0, 1, 'C');

// Ligne décorative
$pdf->SetDrawColor(41, 128, 185);
$pdf->Line(70, $pdf->GetY() + 2, 140, $pdf->GetY() + 2);
$pdf->Ln(8);

// === INFORMATIONS PATIENT ===
$age = date_diff(date_create($ordonnance['date_naissance']), date_create('now'))->y;
$pdf->SectionHeader("INFORMATIONS PATIENT");

$pdf->InfoRow("Nom et Prénom", strtoupper($ordonnance['patient_nom']) . " " . ucfirst($ordonnance['patient_prenom']));
$pdf->InfoRow("Date de naissance", date("d/m/Y", strtotime($ordonnance['date_naissance'])) . " (" . $age . " ans)");
$pdf->InfoRow("Sexe", ucfirst($ordonnance['sexe']));
$pdf->InfoRow("Date de consultation", date("d/m/Y", strtotime($ordonnance['date_ordonnance'])));

// === PRESCRIPTION ===
$pdf->SectionHeader("PRESCRIPTION");
$pdf->ContentBox($ordonnance['medicaments']);

// === POSOLOGIE ===
if (!empty($ordonnance['posologie'])) {
    $pdf->SectionHeader("POSOLOGIE ET MODE D'EMPLOI");
    $pdf->ContentBox($ordonnance['posologie']);
}

// === DURÉE DU TRAITEMENT ===
if (!empty($ordonnance['duree_traitement'])) {
    $pdf->SectionHeader("DURÉE DU TRAITEMENT");
    $pdf->ContentBox($ordonnance['duree_traitement']);
}

// === RECOMMANDATIONS ===
if (!empty($ordonnance['notes'])) {
    $pdf->SectionHeader("RECOMMANDATIONS MÉDICALES");
    $pdf->ContentBox($ordonnance['notes']);
}

// === SIGNATURE ===
$pdf->Ln(15);
$pdf->SetFont('Arial', '', 10);
$pdf->SetTextColor(100, 100, 100);
$pdf->Cell(0, 5, utf8_decode("Fait à [Ville], le " . date("d/m/Y", strtotime($ordonnance['date_ordonnance']))), 0, 1, 'R');

$pdf->Ln(8);
$pdf->SetFont('Arial', 'I', 10);
$pdf->Cell(0, 5, "Signature et cachet du médecin :", 0, 1, 'R');

$pdf->Ln(12);
$pdf->SetFont('Arial', 'B', 12);
$pdf->SetTextColor(41, 128, 185);
$pdf->Cell(0, 6, utf8_decode("Dr " . strtoupper($medecin['username'])), 0, 1, 'R');

$pdf->Output("I", "ordonnance_" . $ordonnance['id'] . ".pdf");
?>