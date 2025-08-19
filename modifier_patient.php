<?php
session_start();
include 'includes/auto_track.php';
require_once 'db.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);

// 🔐 Vérification de connexion et rôle
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

$id_patient = isset($_GET['id']) ? intval($_GET['id']) : 0;

// 🔍 Récupération du patient
$stmt = $pdo->prepare("SELECT * FROM patients WHERE id_patient = ?");
$stmt->execute([$id_patient]);
$patient = $stmt->fetch();

if (!$patient) {
    echo "<p>Patient introuvable.</p>";
    exit();
}

// 🔒 Autorisation : créateur OU médecin principal
$isCreator   = $patient['id_utilisateur'] == $_SESSION['user']['id'];
$isPrincipal = $_SESSION['user']['statut'] === 'principal';
$acces_non_autorise = (!$isCreator && !$isPrincipal);

// 📥 Traitement du formulaire uniquement si autorisé
if ($_SERVER['REQUEST_METHOD'] === 'POST' && !$acces_non_autorise) {
    $nom = trim($_POST['nom']);
    $prenom = trim($_POST['prenom']);
    $sexe = $_POST['sexe'];
    $date_naissance = $_POST['date_naissance'];
    $loisirs = trim($_POST['loisirs']);
    $divers = trim($_POST['divers']);
    $antecedents_medicaux = trim($_POST['antecedents_medicaux']);
    $chirurgicaux = trim($_POST['chirurgicaux']);
    $familiaux = trim($_POST['familiaux']);
    $mentions = trim($_POST['mentions_particulieres']);
    $telephone = trim($_POST['telephone']);
    $profession = trim($_POST['profession']);
    $poids = trim($_POST['poids']);
    $taille = trim($_POST['taille']);

    // 📊 Enregistrer l'état avant modification
    $donnees_avant = $patient;

    // 🔄 Mise à jour
    $stmtUpdate = $pdo->prepare("
        UPDATE patients 
        SET nom = ?, prenom = ?, sexe = ?, date_naissance = ?, loisirs = ?, divers = ?, 
            antecedents_medicaux = ?, chirurgicaux = ?, familiaux = ?, mentions_particulieres = ?,
            telephone = ?, profession = ?, poids = ?, taille = ?
        WHERE id_patient = ?
    ");
    $success = $stmtUpdate->execute([
        $nom, $prenom, $sexe, $date_naissance, $loisirs, $divers,
        $antecedents_medicaux, $chirurgicaux, $familiaux, $mentions,
        $telephone, $profession, $poids, $taille,
        $id_patient
    ]);

    // Historique
    if ($success) {
        $donnees_apres = [
            'nom' => $nom,
            'prenom' => $prenom,
            'sexe' => $sexe,
            'date_naissance' => $date_naissance,
            'loisirs' => $loisirs,
            'divers' => $divers,
            'antecedents_medicaux' => $antecedents_medicaux,
            'chirurgicaux' => $chirurgicaux,
            'familiaux' => $familiaux,
            'mentions_particulieres' => $mentions,
            'telephone' => $telephone,
            'profession' => $profession,
            'poids' => $poids,
            'taille' => $taille
        ];
        logPatientAction('modification', $id_patient, "$nom $prenom", "Patient modifié", $donnees_avant, $donnees_apres);
        logModification('modifier_patient.php', "Patient modifié: $nom $prenom (ID: $id_patient)");
    }

    // ✅ Redirection avec toast vers la page détail du patient
    header("Location: details_patient.php?id=$id_patient&success=modification");
    exit();
}

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<!-- SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<?php if ($acces_non_autorise): ?>
<script>
document.addEventListener('DOMContentLoaded', function () {
  Swal.fire({
    toast: true,
    position: 'top-end',
    icon: 'error',
    title: "Accès non autorisé : vous n'avez pas les droits pour modifier ce patient.",
    showConfirmButton: false,
    timer: 4000,
    timerProgressBar: true,
    background: '#333',
    color: '#fff'
  });
});
</script>
<?php endif; ?>

<div class="pc-container">
  <div class="pc-content">
    <div class="page-header d-flex justify-content-between align-items-center">
      <h4 class="mb-3">Modifier le Patient</h4>
      <a href="lister_patients.php" class="btn btn-secondary">
        <i class="ti ti-arrow-left"></i> Retour à la liste des patients
      </a>
    </div>

    <?php if ($acces_non_autorise): ?>
      <!-- 🔒 Bloc d’accès refusé avec bouton -->
      <div class="card p-4 text-center">
        <h5 class="mb-3 text-danger">⚠️ Accès refusé</h5>
        <p>Vous n'avez pas les droits pour modifier ce patient.</p>
        <a href="lister_patients.php" class="btn btn-primary mt-2">
          <i class="ti ti-list"></i> Retour à la liste des patients
        </a>
      </div>
    <?php else: ?>

    <!-- ✅ Formulaire (uniquement si autorisé) -->
    <form method="POST">
      <div class="grid grid-cols-12 gap-4">

        <!-- Nom -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Nom</label>
            <input type="text" name="nom" class="form-control mt-1" value="<?= htmlspecialchars($patient['nom']) ?>" required>
          </div>
        </div>

        <!-- Prénom -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Prénom</label>
            <input type="text" name="prenom" class="form-control mt-1" value="<?= htmlspecialchars($patient['prenom']) ?>" required>
          </div>
        </div>

        <!-- Sexe -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Sexe</label>
            <select name="sexe" class="form-control mt-1" required>
              <option value="Homme" <?= $patient['sexe'] === 'Homme' ? 'selected' : '' ?>>Homme</option>
              <option value="Femme" <?= $patient['sexe'] === 'Femme' ? 'selected' : '' ?>>Femme</option>
            </select>
          </div>
        </div>

        <!-- Date de naissance -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Date de naissance</label>
            <input type="date" name="date_naissance" class="form-control mt-1" value="<?= $patient['date_naissance'] ?>" required>
          </div>
        </div>

        <!-- Loisirs -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Loisirs</label>
            <input type="text" name="loisirs" class="form-control mt-1" value="<?= htmlspecialchars($patient['loisirs']) ?>">
          </div>
        </div>

        <!-- Divers -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Divers</label>
            <input type="text" name="divers" class="form-control mt-1" value="<?= htmlspecialchars($patient['divers']) ?>">
          </div>
        </div>

        <!-- Antécédents médicaux -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Antécédents médicaux</label>
            <textarea name="antecedents_medicaux" class="form-control mt-1"><?= htmlspecialchars($patient['antecedents_medicaux']) ?></textarea>
          </div>
        </div>

        <!-- Antécédents chirurgicaux -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Antécédents chirurgicaux</label>
            <textarea name="chirurgicaux" class="form-control mt-1"><?= htmlspecialchars($patient['chirurgicaux']) ?></textarea>
          </div>
        </div>

        <!-- Antécédents familiaux -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Antécédents familiaux</label>
            <textarea name="familiaux" class="form-control mt-1"><?= htmlspecialchars($patient['familiaux']) ?></textarea>
          </div>
        </div>

        <!-- Mentions particulières -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Mentions particulières</label>
            <textarea name="mentions_particulieres" class="form-control mt-1"><?= htmlspecialchars($patient['mentions_particulieres']) ?></textarea>
          </div>
        </div>

        <!-- Téléphone -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Téléphone</label>
            <input type="text" name="telephone" class="form-control mt-1" value="<?= htmlspecialchars($patient['telephone']) ?>">
          </div>
        </div>

        <!-- Profession -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Profession</label>
            <input type="text" name="profession" class="form-control mt-1" value="<?= htmlspecialchars($patient['profession']) ?>">
          </div>
        </div>

        <!-- Poids -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Poids (kg)</label>
            <input type="number" step="0.01" name="poids" class="form-control mt-1" value="<?= htmlspecialchars($patient['poids']) ?>">
          </div>
        </div>

        <!-- Taille -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Taille (m)</label>
            <input type="number" step="0.01" name="taille" class="form-control mt-1" value="<?= htmlspecialchars($patient['taille']) ?>">
          </div>
        </div>

        <!-- Boutons -->
        <div class="col-span-12 text-end">
          <button type="submit" class="btn btn-success">💾 Enregistrer les modifications</button>
          <a href="details_patient.php?id=<?= $id_patient ?>" class="btn btn-secondary">↩️ Annuler</a>
        </div>
      </div>
    </form>

    <?php endif; ?>
  </div>
</div>

<?php include 'includes/footer.php'; ?>
