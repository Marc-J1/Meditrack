<?php
session_start();
require_once 'db.php';

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'medecin') {
    header("Location: login.php");
    exit();
}

if (!isset($_GET['id']) || !is_numeric($_GET['id'])) {
    header("Location: liste_medecins_interimaire.php");
    exit();
}

$id = intval($_GET['id']);
$message = "";

// Récupération des infos
$stmt = $pdo->prepare("SELECT * FROM medecins WHERE id_medecin = ?");
$stmt->execute([$id]);
$medecin = $stmt->fetch();

if (!$medecin) {
    header("Location: liste_medecins_interimaire.php?error=Médecin introuvable");
    exit();
}

// Traitement
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $nom = $_POST['nom'] ?? '';
    $email = $_POST['email'] ?? '';
    $specialite = $_POST['specialite'] ?? '';
    $telephone = $_POST['telephone'] ?? '';
    $adresse = $_POST['adresse'] ?? '';
    $statut = $_POST['statut'] ?? 'interimaire';

    if (!empty($nom) && !empty($email)) {
        $update = $pdo->prepare("UPDATE medecins SET nom_complet = ?, email = ?, specialite = ?, telephone = ?, adresse = ?, statut = ? WHERE id_medecin = ?");
        $success = $update->execute([$nom, $email, $specialite, $telephone, $adresse, $statut, $id]);

        if ($success) {
            header("Location: modifier_medecin_interimaire.php?id=$id&success=1");
            exit();
        } else {
            $message = "Erreur lors de la modification.";
        }
    } else {
        $message = "Le nom et l'email sont requis.";
    }

    // Recharge
    $stmt = $pdo->prepare("SELECT * FROM medecins WHERE id_medecin = ?");
    $stmt->execute([$id]);
    $medecin = $stmt->fetch();
}

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<div class="pc-container">
  <div class="pc-content">
    <h4 class="mb-4">Modifier un Médecin</h4>

    <?php if ($message): ?>
      <div class="alert alert-info"><?= htmlspecialchars($message) ?></div>
    <?php endif; ?>

    <form method="post">
      <div class="row">
        <div class="col-md-6 mb-3">
          <label>Nom complet</label>
          <input type="text" name="nom_complet" class="form-control" value="<?= htmlspecialchars($medecin['nom']) ?>" required>
        </div>

        <div class="col-md-6 mb-3">
          <label>Email</label>
          <input type="email" name="email" class="form-control" value="<?= htmlspecialchars($medecin['email']) ?>" required>
        </div>

        <div class="col-md-6 mb-3">
          <label>Spécialité</label>
          <input type="text" name="specialite" class="form-control" value="<?= htmlspecialchars($medecin['specialite']) ?>">
        </div>

        <div class="col-md-6 mb-3">
          <label>Téléphone</label>
          <input type="text" name="telephone" class="form-control" value="<?= htmlspecialchars($medecin['telephone']) ?>">
        </div>

        <div class="col-md-12 mb-3">
          <label>Adresse</label>
          <textarea name="adresse" class="form-control"><?= htmlspecialchars($medecin['adresse']) ?></textarea>
        </div>

        <div class="col-md-6 mb-3">
          <label>Statut</label>
          <select name="statut" class="form-control">
           
            <option value="interimaire" <?= $medecin['statut'] === 'interimaire' ? 'selected' : '' ?>>Intérimaire</option>
          </select>
        </div>
      </div>

      <button type="submit" class="btn btn-primary">Enregistrer les modifications</button>
      <a href="liste_medecins_interimaire.php" class="btn btn-secondary">Retour</a>
    </form>
  </div>
</div>

<?php include 'includes/footer.php'; ?>

<!-- SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
<?php if (isset($_GET['success'])): ?>
Swal.fire({
    title: 'Message',
    text: 'Modification réussie.',
    icon: 'success',
    confirmButtonText: 'OK',
    background: '#000',
    color: '#fff',
    confirmButtonColor: '#4da6ff',
    customClass: {
      popup: 'swal2-custom-popup',
      title: 'swal2-custom-title',
      htmlContainer: 'swal2-custom-text'
    }
});
<?php elseif (isset($_GET['error'])): ?>
Swal.fire({
    title: 'Erreur',
    text: '<?= htmlspecialchars($_GET['error']) ?>',
    icon: 'error',
    confirmButtonText: 'OK',
    background: '#000',
    color: '#fff',
    confirmButtonColor: '#e74c3c',
    customClass: {
      popup: 'swal2-custom-popup',
      title: 'swal2-custom-title',
      htmlContainer: 'swal2-custom-text'
    }
});
<?php endif; ?>
</script>

<!-- Optionnel : styles SweetAlert2 -->
<style>
  .swal2-custom-popup {
    width: 350px !important;
    padding: 1.5rem !important;
    font-size: 16px !important;
    border-radius: 8px !important;
  }
  .swal2-custom-title {
    font-size: 20px !important;
    margin-bottom: 10px !important;
  }
  .swal2-custom-text {
    font-size: 16px !important;
  }
</style>
