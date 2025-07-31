<?php
session_start();
require_once 'db.php';

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

$id_patient = isset($_GET['id']) ? intval($_GET['id']) : 0;

// Vérifie que le patient appartient bien au médecin connecté
$stmt = $pdo->prepare("SELECT * FROM patients WHERE id_patient = ? AND id_utilisateur = ?");
$stmt->execute([$id_patient, $_SESSION['user']['id']]);
$patient = $stmt->fetch();

if (!$patient) {
    echo "<p>Patient introuvable ou accès non autorisé.</p>";
    exit();
}

// Récupère l'historique
$stmtHist = $pdo->prepare("
    SELECT h.*, 
           m.nom AS nom_medecin,
           CONCAT(u.username) AS id_utilisateur
    FROM patients_history h
    LEFT JOIN medecins m ON h.id_medecin = m.id_medecin
    LEFT JOIN users u ON h.id_utilisateur = u.id_utilisateur
    WHERE h.id_patient = ?
    ORDER BY h.date_action DESC
");
$stmtHist->execute([$id_patient]);
$historiques = $stmtHist->fetchAll();

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<div class="pc-container">
  <div class="pc-content">
    <h4 class="mb-3">Historique du Patient : <?= htmlspecialchars($patient['nom'] . ' ' . $patient['prenom']) ?></h4>

    <div class="card">
      <div class="card-body table-responsive">
        <?php if ($historiques): ?>
          <table class="table table-striped table-bordered">
            <thead class="table-dark">
              <tr>
                <th>Date</th>
                <th>Action</th>
                <th>Commentaire</th>
                <th>Médecin_interimaire</th>
                <th>Medecin</th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($historiques as $histo): ?>
                <tr>
                  <td><?= htmlspecialchars(date('d/m/Y H:i', strtotime($histo['date_action']))) ?></td>
                  <td><?= htmlspecialchars(ucfirst($histo['action'])) ?></td>
                  <td><?= htmlspecialchars($histo['commentaire']) ?></td>
                  <td><?= htmlspecialchars($histo['nom_medecin'] ?? 'Inconnu') ?></td>
                  <td><?= htmlspecialchars($histo['nom_utilisateur'] ?? 'Inconnu') ?></td>
                </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        <?php else: ?>
          <p>Aucun historique disponible pour ce patient.</p>
        <?php endif; ?>
      </div>
    </div>

    <a href="lister_patients.php" class="btn btn-secondary mt-3">Retour</a>
  </div>
</div>

<?php include 'includes/footer.php'; ?>
