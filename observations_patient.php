<?php
session_start();
require_once 'db.php';

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

$id_patient = isset($_GET['id']) ? intval($_GET['id']) : 0;

// Vérifie que le patient existe et appartient bien au médecin connecté
$stmt = $pdo->prepare("SELECT * FROM patients WHERE id_patient = ?");
$stmt->execute([$id_patient]);

$patient = $stmt->fetch();

if (!$patient) {
    echo "<p>Patient introuvable ou accès non autorisé.</p>";
    exit();
}

// Récupère les observations du patient
$stmtObs = $pdo->prepare("
    SELECT o.*, u.username AS auteur
    FROM observations o
    LEFT JOIN users u ON o.id_utilisateur = u.id_utilisateur
    WHERE o.id_patient = ?
    ORDER BY o.date_observation DESC
");
$stmtObs->execute([$id_patient]);
$observations = $stmtObs->fetchAll();

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<div class="pc-container">
  <div class="pc-content">
    <h4 class="mb-3">Observations du Patient : <?= htmlspecialchars($patient['nom'] . ' ' . $patient['prenom']) ?></h4>

    <!-- Bouton redirigeant vers la page d’ajout -->
<a href="ajouter_observation.php?id_patient=<?= $id_patient ?>" class="btn btn-success mb-3">
  Nouvelle Observation
</a>


<!-- Bouton retour -->
<a href="details_patient.php?id=<?= $id_patient ?>#actions" class="btn btn-secondary mb-3">
  <i class="ti ti-arrow-left"></i> Retour au patient
</a>

    <div class="card">
      <div class="card-body table-responsive">
        <?php if ($observations): ?>
          <table id="table-observations" class="table table-bordered table-hover nowrap w-100">
            <thead class="table-dark">
              <tr>
                <th>Date</th>
                <th>Type</th>
                <th>Contenu</th>
                <th>Auteur</th>
               <!-- <th>Actions</th> -->
              </tr>
            </thead>
            <tbody>
              <?php foreach ($observations as $obs): ?>
                <tr>
                  <td><?= date('d/m/Y H:i', strtotime($obs['date_observation'])) ?></td>
                  <td><?= htmlspecialchars($obs['type_observation']) ?></td>
                  <td><?= nl2br(htmlspecialchars($obs['contenu'])) ?></td>
                  <td><?= htmlspecialchars($obs['auteur'] ?? 'Inconnu') ?></td>
                  <!-- <td>
                    <?php if ($obs['id_utilisateur'] == $_SESSION['user']['id'] || $_SESSION['user']['role'] === 'medecin'): ?>
                      <a href="modifier_observation.php?id=<?= $obs['id'] ?>" class="btn btn-sm btn-primary">Modifier</a>
                      <a href="supprimer_observation.php?id=<?= $obs['id'] ?>&patient=<?= $id_patient ?>" class="btn btn-sm btn-danger" onclick="return confirm('Supprimer cette observation ?')">Supprimer</a>
                    <?php else: ?>
                      <em>-</em>
                    <?php endif; ?>
                  </td>  -->
                </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        <?php else: ?>
          <p>Aucune observation pour ce patient.</p>
        <?php endif; ?>
      </div>
    </div>
  </div>
</div>
<!-- BROUILLON : Modal Nouvelle Observation
<div class="modal fade" id="modalObservation" tabindex="-1" aria-labelledby="modalObservationLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <form method="POST" action="ajouter_observation.php">
            <input type="hidden" name="id_patient" value="<?= $id_patient ?>">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalObservationLabel">Ajouter une Observation</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fermer"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="type" class="form-label">Type d'observation</label>
                        <select name="type" id="type" class="form-select" required>
                            <option value="Suivi">Suivi</option>
                            <option value="Diagnostic">Diagnostic</option>
                            <option value="Note">Note</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="contenu" class="form-label">Contenu</label>
                        <textarea name="contenu" id="contenu" class="form-control" rows="5" required placeholder="Écrivez ici..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-primary">Enregistrer</button>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Annuler</button>
                </div>
            </div>
        </form>
    </div>
</div>
-->

<?php include 'includes/footer.php'; ?>


<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css">
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script>
    $(document).ready(function () {
        $('#table-observations').DataTable({
            responsive: true,
            language: {
                url: "//cdn.datatables.net/plug-ins/1.13.6/i18n/fr-FR.json"
            }
        });
    });
</script>

