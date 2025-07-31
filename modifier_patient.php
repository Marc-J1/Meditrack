<?php
session_start();
require_once 'db.php';

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

// 🔒 Autorisation : créateur OU médecin principale
$isCreator = $patient['id_utilisateur'] == $_SESSION['user']['id'];
$isPrincipal = $_SESSION['user']['statut'] === 'principal';

if (!$isCreator && !$isPrincipal) {
    echo "<p>Accès non autorisé. Vous n'avez pas les droits pour modifier ce patient.</p>";
    exit();
}

// 📥 Traitement du formulaire
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
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

    // 🔄 Mise à jour du patient
    $stmtUpdate = $pdo->prepare("
        UPDATE patients 
        SET nom = ?, prenom = ?, sexe = ?, date_naissance = ?, loisirs = ?, divers = ?, 
            antecedents_medicaux = ?, chirurgicaux = ?, familiaux = ?, mentions_particulieres = ?,
            telephone = ?, profession = ?, poids = ?, taille = ?
        WHERE id_patient = ?
    ");

    $stmtUpdate->execute([
        $nom, $prenom, $sexe, $date_naissance, $loisirs, $divers,
        $antecedents_medicaux, $chirurgicaux, $familiaux, $mentions,
        $telephone, $profession, $poids, $taille,
        $id_patient
    ]);

    // ✅ Redirection avec toast
    header("Location: lister_patients.php?success=modification");
    exit();
}

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<!-- ✅ Formulaire -->
<div class="pc-container">
  <div class="pc-content">
    <div class="page-header">
      <h4 class="mb-3">Modifier le Patient</h4>
    </div>

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
              <option value="M" <?= $patient['sexe'] === 'M' ? 'selected' : '' ?>>Masculin</option>
              <option value="F" <?= $patient['sexe'] === 'F' ? 'selected' : '' ?>>Féminin</option>
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
          <a href="lister_patients.php" class="btn btn-secondary">↩️ Annuler</a>
        </div>

      </div>
    </form>
  </div>
</div>

<?php include 'includes/footer.php'; ?>
