 <?php
session_start();
require_once 'db.php';
require_once 'includes/activity_logger.php';
include 'includes/auto_track.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'A consulté les détails de un patients ');

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

if (!isset($_GET['id'])) {
    header("Location: lister_patients.php");
    exit();
}

$patient_id = $_GET['id'];

// Récupérer les informations du patient
$stmt = $pdo->prepare("SELECT * FROM patients WHERE id_patient = ?");
$stmt->execute([$patient_id]);

$patient = $stmt->fetch();

if (!$patient) {
    header("Location: lister_patients.php?error=Patient non trouvé");
    exit();
}

// Récupérer les historiques d'observations
// Récupérer les historiques d'observations avec nom du médecin
$stmt_obs = $pdo->prepare("
    SELECT o.*, u.username AS auteur
    FROM observations o
    LEFT JOIN users u ON o.id_utilisateur = u.id_utilisateur
    WHERE o.id_patient = ?
    ORDER BY o.date_observation DESC
");
$stmt_obs->execute([$patient_id]);
$observations = $stmt_obs->fetchAll();


// Récupérer les ordonnances
$stmt_ord = $pdo->prepare("
    SELECT o.*, u.username AS nom_medecin
    FROM ordonnances o
    LEFT JOIN users u ON o.id_utilisateur = u.id_utilisateur
    WHERE o.id_patient = ?
    ORDER BY o.date_ordonnance DESC
");
$stmt_ord->execute([$patient_id]);
$ordonnances = $stmt_ord->fetchAll();


// CORRECTION: Requête corrigée pour les consultations avec ordonnances associées
$stmt_consult = $pdo->prepare("
    SELECT c.*, u.username AS nom_medecin,
        EXISTS (
            SELECT 1 FROM ordonnances o 
            WHERE o.id_patient = c.id_patient 
            AND DATE(o.date_ordonnance) = DATE(c.date_consultation)
        ) AS has_ordonnance
    FROM consultations c
    LEFT JOIN users u ON c.id_utilisateur = u.id_utilisateur
    WHERE c.id_patient = ?
    ORDER BY c.date_consultation DESC
");
$stmt_consult->execute([$patient_id]);
$consultations = $stmt_consult->fetchAll();


// Calculer les statistiques des consultations
$nombre_consultations = count($consultations);
$derniere_consultation = $nombre_consultations > 0 ? $consultations[0]['date_consultation'] : null;

// Statistiques par période pour les filtres
$date_debut = isset($_GET['date_debut']) ? $_GET['date_debut'] : '';
$date_fin = isset($_GET['date_fin']) ? $_GET['date_fin'] : '';

$consultations_periode = $consultations;
if ($date_debut && $date_fin) {
    $consultations_periode = array_filter($consultations, function($consult) use ($date_debut, $date_fin) {
        $date_consult = date('Y-m-d', strtotime($consult['date_consultation']));
        return $date_consult >= $date_debut && $date_consult <= $date_fin;
    });
}

// Calculer l'âge
$date_naissance = new DateTime($patient['date_naissance']);
$aujourd_hui = new DateTime();
$age = $aujourd_hui->diff($date_naissance)->y;

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>
<?php
$type_message = '';
$contenu_message = '';

if (isset($_GET['success']) && $_GET['success'] === 'modification') {
    $type_message = 'success';
    $contenu_message = 'Patient modifié avec succès !';
} elseif (isset($_GET['error'])) {
    $type_message = 'danger';
    $contenu_message = htmlspecialchars($_GET['error']);
}
?>

<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css">


<div class="pc-container">
  <div class="pc-content">
    <?php if (!empty($contenu_message)): ?>
<div class="toast-container position-fixed top-0 end-0 p-3">
  <div class="toast align-items-center text-bg-<?= $type_message ?> border-0 show" role="alert" aria-live="assertive" aria-atomic="true">
    <div class="d-flex">
      <div class="toast-body"><?= $contenu_message ?></div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Fermer"></button>
    </div>
  </div>
</div>
<?php endif; ?>

    <div class="page-header">
      <div class="d-flex justify-content-between align-items-center">
        <h4 class="mb-3">Détails du Patient</h4>
        <a href="lister_patients.php" class="btn btn-secondary">
          <i class="ti ti-arrow-left"></i> Retour à la liste
        </a>
      </div>
    </div>

    <!-- Informations personnelles -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="card-title mb-0">
          <i class="ti ti-user"></i> Informations Personnelles
        </h5>
      </div>
   <div class="grid grid-cols-12 gap-4">
  <!-- Ligne 1 : Nom / Prénom -->
  <div class="col-span-12 md:col-span-6">
    <div class="card p-4">
      <label class="font-semibold">Nom :</label>
      <p class="form-control-plaintext"><?= htmlspecialchars($patient['nom']) ?></p>
    </div>
  </div>
  <div class="col-span-12 md:col-span-6">
    <div class="card p-4">
      <label class="font-semibold">Prénom :</label>
      <p class="form-control-plaintext"><?= htmlspecialchars($patient['prenom']) ?></p>
    </div>
  </div>

 <!-- Ligne 2 : Date de naissance / Âge / Sexe -->
<div class="col-span-12">
  <div class="flex flex-col md:flex-row gap-4">
    <!-- Date de naissance -->
    <div class="flex-1 card p-4">
      <label class="font-semibold">Date de Naissance :</label>
      <p class="form-control-plaintext"><?= date('d/m/Y', strtotime($patient['date_naissance'])) ?></p>
    </div>

    <!-- Âge -->
    <div class="flex-1 card p-4">
      <label class="font-semibold">Âge :</label>
      <p class="form-control-plaintext"><?= $age ?> ans</p>
    </div>

    <!-- Sexe -->
    <div class="flex-1 card p-4">
      <label class="font-semibold">Sexe :</label>
      <p class="form-control-plaintext"><?= htmlspecialchars($patient['sexe']) ?></p>
    </div>
  </div>
</div>


  <!-- Ligne 3 : Téléphone / Profession -->
  <div class="col-span-12 md:col-span-6">
    <div class="card p-4">
      <label class="font-semibold">Téléphone :</label>
      <p class="form-control-plaintext"><?= !empty($patient['telephone']) ? htmlspecialchars($patient['telephone']) : 'Non renseigné' ?></p>
    </div>
  </div>
  <div class="col-span-12 md:col-span-6">
    <div class="card p-4">
      <label class="font-semibold">Profession :</label>
      <p class="form-control-plaintext"><?= !empty($patient['profession']) ? htmlspecialchars($patient['profession']) : 'Non renseignée' ?></p>
    </div>
  </div>

  <!-- Ligne 4 : Poids / Taille -->
  <div class="col-span-12 md:col-span-6">
    <div class="card p-4">
      <label class="font-semibold">Poids :</label>
      <p class="form-control-plaintext"><?= !empty($patient['poids']) ? htmlspecialchars($patient['poids']) . ' kg' : 'Non renseigné' ?></p>
    </div>
  </div>
  <div class="col-span-12 md:col-span-6">
    <div class="card p-4">
      <label class="font-semibold">Taille :</label>
      <p class="form-control-plaintext"><?= !empty($patient['taille']) ? htmlspecialchars($patient['taille']) . ' cm' : 'Non renseignée' ?></p>
    </div>
  </div>
</div>




    </div>

    <!-- Statistiques des consultations avec filtre par période -->
    <div class="card mb-4"id="stats">
      <div class="card-header">
        <h5 class="card-title mb-0">
          <i class="ti ti-calendar-stats"></i> Statistiques des Consultations
        </h5>
      </div>
      <div class="card-body">
        <!-- Filtre par période -->
        <div class="row mb-4">
          <div class="col-md-12">
           <form method="GET" action="#stats" class="d-flex gap-3 align-items-end" id="filterForm">
              <input type="hidden" name="id" value="<?= $patient_id ?>">
              <div class="form-group">
                <label for="date_debut" class="form-label">Date de début :</label>
                <input type="date" id="date_debut" name="date_debut" class="form-control" value="<?= $date_debut ?>">
              </div>
              <div class="form-group">
                <label for="date_fin" class="form-label">Date de fin :</label>
                <input type="date" id="date_fin" name="date_fin" class="form-control" value="<?= $date_fin ?>">
              </div>
              <div class="form-group mt-3">
                <button type="submit" class="btn btn-primary">
                  <i class="ti ti-filter"></i> Filtrer
                </button>
               <a href="?id=<?= $patient_id ?>#stats" class="btn btn-secondary">

                  <i class="ti ti-refresh"></i> Réinitialiser
                </a>
              </div>
            </form>
          </div>
        </div>

        <div class="row">
          <div class="col-md-4">
            <div class="d-flex align-items-center mb-3">
              <div class="flex-shrink-0">
                <div class="avtar avtar-s bg-primary">
                  <i class="ti ti-calendar-event"></i>
                </div>
              </div>
              <div class="flex-grow-1 ms-3">
                <h6 class="mb-0">Total consultations</h6>
                <p class="text-muted mb-0"><?= $nombre_consultations ?> consultation(s)</p>
              </div>
            </div>
          </div>
          <?php if ($date_debut && $date_fin): ?>
<div class="col-md-4">
  <div class="d-flex align-items-center mb-3">
    <div class="flex-shrink-0">
      <div class="avtar avtar-s bg-info">
        <i class="ti ti-calendar-time"></i>
      </div>
    </div>
    <div class="flex-grow-1 ms-3">
      <h6 class="mb-0">Période sélectionnée</h6>
      <p class="text-muted mb-0"><?= count($consultations_periode) ?> consultation(s)</p>
    </div>
  </div>
</div>
<?php endif; ?>

          <div class="col-md-4">
            <div class="d-flex align-items-center mb-3">
              <div class="flex-shrink-0">
                <div class="avtar avtar-s bg-success">
                  <i class="ti ti-clock"></i>
                </div>
              </div>
              <div class="flex-grow-1 ms-3">
                <h6 class="mb-0">Dernière consultation</h6>
                <p class="text-muted mb-0">
                  <?= $derniere_consultation ? date('d/m/Y à H:i', strtotime($derniere_consultation)) : 'Aucune consultation' ?>
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Antécédents médicaux -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="card-title mb-0">
          <i class="ti ti-medical-cross"></i> Antécédents Médicaux
        </h5>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-4">
            <div class="mb-3">
              <label class="form-label fw-bold">Antécédents Médicaux :</label>
              <p class="form-control-plaintext"><?= !empty($patient['antecedents_medicaux']) ? htmlspecialchars($patient['antecedents_medicaux']) : 'Aucun' ?></p>
            </div>
          </div>
          <div class="col-md-4">
            <div class="mb-3">
              <label class="form-label fw-bold">Chirurgicaux :</label>
              <p class="form-control-plaintext"><?= !empty($patient['chirurgicaux']) ? htmlspecialchars($patient['chirurgicaux']) : 'Aucun' ?></p>
            </div>
          </div>
          <div class="col-md-4">
            <div class="mb-3">
              <label class="form-label fw-bold">Familiaux :</label>
              <p class="form-control-plaintext"><?= !empty($patient['familiaux']) ? htmlspecialchars($patient['familiaux']) : 'Aucun' ?></p>
            </div>
          </div>
        </div>
        
        <?php if (!empty($patient['mentions_particulieres'])): ?>
        <div class="mb-3">
          <label class="form-label fw-bold">Mentions Particulières :</label>
          <p class="form-control-plaintext"><?= htmlspecialchars($patient['mentions_particulieres']) ?></p>
        </div>
        <?php endif; ?>
      </div>
    </div>

    <!-- Actions rapides -->
    <div class="card mb-4" id="actions">
      <div class="card-header">
        <h5 class="card-title mb-0">
          <i class="ti ti-settings"></i> Actions
        </h5>
      </div>
      <div class="card-body">
        <div class="d-flex gap-2 flex-wrap">
          <a href="modifier_patient.php?id=<?= $patient['id_patient'] ?>" class="btn btn-primary">
            <i class="ti ti-edit"></i> Modifier
          </a>
          <a href="nouvelle_consultation.php?id=<?= $patient['id_patient'] ?>" class="btn btn-warning">
            <i class="ti ti-calendar-plus"></i> Nouvelle Consultation
          </a>
          <a href="ajouter_observation.php?id_patient=<?= $patient['id_patient'] ?>" class="btn btn-info">
            <i class="ti ti-eye"></i> Ajouter Observation
          </a>
       
          <a href="ordonance_patient.php?id=<?= $patient['id_patient'] ?>" class="btn btn-success">
            <i class="ti ti-file-text"></i> Nouvelle Ordonnance
          </a>
       <!--   <a href="bon_examen.php?id_patient=<?= $patient['id_patient'] ?>" class="btn btn-outline-primary">
  <i class="ti ti-vial"></i> Bon d'examen
</a>-->

          <a href="supprimer_patient.php?id=<?= $patient['id_patient'] ?>" class="btn btn-danger" onclick="return confirm('Confirmer la suppression ?');">
            <i class="ti ti-trash"></i> Supprimer
          </a>
        </div>
      </div>
    </div>

    <!-- Historique des consultations -->
    <div class="card mb-4" id="consul">
      <div class="card-header">
        <h5 class="card-title mb-0">
          <i class="ti ti-calendar"></i> Historique des Consultations
        </h5>
      </div>
      <div class="card-body">
        

        <?php if (count($consultations) > 0): ?>
        <div class="table-responsive">
          <table class="table table-hover" id="consultationsTable">
            <thead class="table-light">
              <tr>
                <th>Date</th>
                <th>Motif</th>
                <th>Diagnostic</th>
                <th>Médecin</th>
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($consultations as $consult): ?>
               <?php
// Vérifie ordonnance
$stmt = $pdo->prepare("SELECT id FROM ordonnances WHERE id_consultation = ?");
$stmt->execute([$consult['id']]);
$ordonnance = $stmt->fetch();


// Vérifie bon d'examen
$stmt = $pdo->prepare("SELECT id FROM bons_examens WHERE id_consultation = ?");
$stmt->execute([$consult['id']]);
$bon_examen = $stmt->fetch();
?>
<?php
// Vérifier s’il y a une observation liée à cette consultation
$stmt = $pdo->prepare("SELECT id FROM observations WHERE id_consultation = ?");
$stmt->execute([$consult['id']]);
$observation = $stmt->fetch();
?>



              <tr>
                <td data-sort="<?= strtotime($consult['date_consultation']) ?>">
                  <?= date('d/m/Y H:i', strtotime($consult['date_consultation'])) ?>
                </td>
                <td><?= htmlspecialchars(substr($consult['motif'], 0, 50)) ?><?= strlen($consult['motif']) > 50 ? '...' : '' ?></td>
                <td><?= htmlspecialchars($consult['diagnostic'] ?? 'En cours') ?></td>
                <td><?= htmlspecialchars($consult['nom_medecin']) ?></td>
                <td>
                  <span class="badge bg-<?= $consult['statut'] === 'terminee' ? 'success' : ($consult['statut'] === 'en_cours' ? 'warning' : 'primary') ?>">
                    <?= htmlspecialchars($consult['statut'] ?? 'Programmée') ?>
                  </span>
                </td>
                <td>
                  <div class="btn-group btn-group-sm">
                    <a href="voir_consultation.php?id=<?= $consult['id'] ?>" class="btn btn-outline-info" title="Voir détails">
                      <i class="ti ti-eye"></i>
                    </a>

            <!-- icône voir ordonnance est sensé etre ici -->
             <?php if ($consult['has_ordonnance']): ?>
  <?php if ($ordonnance): ?>
  <a href="voir_ordonance.php?id=<?= $ordonnance['id'] ?>" class="btn btn-outline-success" title="Voir ordonnance">
    <i class="ti ti-file-text"></i>
  </a>
<?php endif; ?>

<?php endif; ?>
<?php if ($observation): ?>
  <a href="voir_observation.php?id=<?= $observation['id'] ?>" class="btn btn-outline-warning" title="Voir observation">
    <i class="ti ti-eye-check"></i>
  </a>
<?php endif; ?>


<?php if ($bon_examen): ?>
  <a href="voir_bon_examen.php?id=<?= $bon_examen['id'] ?>" class="btn btn-outline-warning" title="Voir bon d'examen">
    <i class="ti ti-file"></i>
    
  </a>
<?php endif; ?>


            <?php if ($consult['statut'] !== 'terminee'): ?>
            <a href="modifier_consultation.php?id=<?= $consult['id'] ?>" class="btn btn-outline-primary" title="Modifier">
                <i class="ti ti-edit"></i>
            </a>
            <?php endif; ?>
            </div>
            </td>
            </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        </div>
        
        <?php else: ?>
        <div class="alert alert-info border-0">
          <div class="d-flex align-items-center">
            <div class="alert-icon me-3">
              <i class="ti ti-info-circle fs-4"></i>
            </div>
            <div>
              <h6 class="alert-heading mb-1">Aucune consultation</h6>
              <p class="mb-0">Aucune consultation enregistrée pour ce patient.</p>
            </div>
          </div>
        </div>
        <?php endif; ?>
      </div>
    </div>

    <!-- Historique des Bons d'examen -->
<div class="card mb-4" id="examens">
  <div class="card-header">
    <h5 class="card-title mb-0">
      <i class="ti ti-vial"></i> Historique des Bons d'examen
    </h5>
  </div>
  <div class="card-body">
    <?php
      $stmt_exam = $pdo->prepare("
        SELECT b.*, u.username AS medecin
        FROM bons_examens b
        LEFT JOIN users u ON b.id_utilisateur = u.id_utilisateur
        WHERE b.id_patient = ?
        ORDER BY b.date_creation DESC
      ");
      $stmt_exam->execute([$patient_id]);
      $bons_examens = $stmt_exam->fetchAll();
    ?>

    <?php if (count($bons_examens) > 0): ?>
    <div class="table-responsive">
      <table class="table table-hover" id="bonsExamensTable">
        <thead class="table-light">
          <tr>
            <th>Date</th>
            <th>Service demandeur</th>
            <th>Renseignement clinique</th>
            <th>Médecin</th>
             <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($bons_examens as $examen): ?>
          <tr>
            <td data-sort="<?= strtotime($examen['date_creation']) ?>">
              <?= date('d/m/Y H:i', strtotime($examen['date_creation'])) ?>
            </td>
            <td><?= htmlspecialchars(substr($examen['service_demandeur'], 0, 50)) ?><?= strlen($examen['service_demandeur']) > 50 ? '...' : '' ?></td>
            <td><?= htmlspecialchars(substr($examen['renseignement_clinique'], 0, 100)) ?><?= strlen($examen['renseignement_clinique']) > 100 ? '...' : '' ?></td>
            <td><?= htmlspecialchars($examen['medecin']) ?></td>
            <td>
                  <a href="voir_bon_examen.php?id=<?= $examen['id'] ?>" class="btn btn-outline-info btn-sm" title="Voir détails">
                    <i class="ti ti-eye"></i>
                  </a>
                </td>
          </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
    <?php else: ?>
    <div class="alert alert-info border-0">
      <div class="d-flex align-items-center">
        <div class="alert-icon me-3">
          <i class="ti ti-info-circle fs-4"></i>
        </div>
        <div>
          <h6 class="alert-heading mb-1">Aucun bon d'examen</h6>
          <p class="mb-0">Aucun bon d'examen enregistré pour ce patient.</p>
        </div>
      </div>
    </div>
    <?php endif; ?>
  </div>
</div>


    <!-- Historique des observations -->
    <div class="card mb-4" id="observe">
      <div class="card-header">
        <h5 class="card-title mb-0">
          <i class="ti ti-clock"></i> Historique des Observations
        </h5>
      </div>
      <div class="card-body">
       

        <?php if (count($observations) > 0): ?>
        <div class="table-responsive">
          <table class="table table-hover" id="observationsTable">
            <thead class="table-light">
              <tr>
                <th>Date</th>
                <th>Observation</th>
                <th>Medecin</th>
                <th>Diagnostic</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($observations as $obs): ?>
              <tr>
                <td data-sort="<?= strtotime($obs['date_observation']) ?>">
                  <?= date('d/m/Y H:i', strtotime($obs['date_observation'])) ?>
                </td>
                <td><?= htmlspecialchars(substr($obs['contenu'], 0, 100)) ?><?= strlen($obs['contenu']) > 100 ? '...' : '' ?></td>
                <td><?= htmlspecialchars($obs['auteur'] ) ?></td>

                <td><?= htmlspecialchars($obs['diagnostic'] ?? 'Non spécifié') ?></td>
                <td>
                  <a href="voir_observation.php?id=<?= $obs['id'] ?>" class="btn btn-outline-info btn-sm" title="Voir détails">
                    <i class="ti ti-eye"></i>
                  </a>
                </td>
              </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        </div>

        
        <?php else: ?>
        <div class="alert alert-info border-0">
          <div class="d-flex align-items-center">
            <div class="alert-icon me-3">
              <i class="ti ti-info-circle fs-4"></i>
            </div>
            <div>
              <h6 class="alert-heading mb-1">Aucune observation</h6>
              <p class="mb-0">Aucune observation enregistrée pour ce patient.</p>
            </div>
          </div>
        </div>
        <?php endif; ?>
      </div>
    </div>

    <!-- Historique des ordonnances -->
    <div class="card mb-4" id="ordo">
      <div class="card-header">
        <h5 class="card-title mb-0">
          <i class="ti ti-file-text"></i> Historique des Ordonnances
        </h5>
      </div>
      <div class="card-body">
      

        <?php if (count($ordonnances) > 0): ?>
        <div class="table-responsive">
          <table class="table table-hover" id="ordonnancesTable">
            <thead class="table-light">
              <tr>
                <th>Date</th>
                <th>Prescriptions</th>
                <th>Médecin</th>
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($ordonnances as $ord): ?>
              <tr>
                <td data-sort="<?= strtotime($ord['date_ordonnance']) ?>">
                  <?= date('d/m/Y', strtotime($ord['date_ordonnance'])) ?>
                </td>
                <td><?= htmlspecialchars(substr($ord['notes'], 0, 100)) ?><?= strlen($ord['notes']) > 100 ? '...' : '' ?></td>
                <td><?= htmlspecialchars($ord['nom_medecin'] ?? 'Inconnu') ?></td>

                <td>
                  <span class="badge bg-<?= $ord['statut'] === 'active' ? 'success' : 'secondary' ?>">
                    <?= htmlspecialchars($ord['statut'] ?? 'Active') ?>
                  </span>
                </td>
                <td>
                  <div class="btn-group btn-group-sm">
                    <a href="voir_ordonance.php?id=<?= $ord['id'] ?>" class="btn btn-outline-info" title="Voir détails">
                      <i class="ti ti-eye"></i>
                    </a>
                    <a href="generer_ordonnance.php?id=<?= $ord['id'] ?>" class="btn btn-outline-primary" title="Imprimer">
                      <i class="ti ti-printer"></i>
                    </a>
                  </div>
                </td>
              </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        </div>

         
        <?php else: ?>
        <div class="alert alert-info border-0">
          <div class="d-flex align-items-center">
            <div class="alert-icon me-3">
              <i class="ti ti-info-circle fs-4"></i>
            </div>
            <div>
              <h6 class="alert-heading mb-1">Aucune ordonnance</h6>
              <p class="mb-0">Aucune ordonnance émise pour ce patient.</p>
            </div>
          </div>
        </div>
        <?php endif; ?>
      </div>
    </div>

  </div>
</div>
<!-- jQuery + DataTables -->
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script>
  $(document).ready(function() {
    $('#consultationsTable, #observationsTable, #ordonnancesTable').DataTable({
      order: [[0, 'desc']],
      language: {
        url: "//cdn.datatables.net/plug-ins/1.13.6/i18n/fr-FR.json"
      }
    });
  });
</script>


<?php include 'includes/footer.php'; ?>

<!-- Styles CSS améliorés -->
<style>
/* Styles généraux */
.card-header {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-bottom: 1px solid #dee2e6;
  padding: 1rem 1.5rem;
}

.card-title {
  color: #495057;
  font-weight: 600;
}

.form-control-plaintext {
  margin-bottom: 0;
  border-bottom: 1px solid #e9ecef;
  padding-bottom: 0.5rem;
  min-height: 1.5rem;
}

.badge {
  font-size: 0.8rem;
  font-weight: 500;
  padding: 0.35em 0.65em;
}

.alert {
  border: none;
  border-radius: 0.75rem;
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
}

.alert-icon {