<?php
session_start();
require_once 'db.php';

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'admin') {
    header("Location: login.php");
    exit();
}

if (!isset($_GET['id']) || !is_numeric($_GET['id'])) {
    header("Location: liste_medecins.php");
    exit();
}

$id = intval($_GET['id']);
$message = "";

// Récupération des infos
$stmt = $pdo->prepare("SELECT * FROM users WHERE id_utilisateur = ?");
$stmt->execute([$id]);
$medecin = $stmt->fetch();

if (!$medecin) {
    header("Location: liste_medecins.php?error=Médecin introuvable");
    exit();
}

// Traitement
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $nom = $_POST['username'] ?? '';
    $phone_number = $_POST['phone_number'] ?? '';
    $address = $_POST['address'] ?? '';
    $mail = $_POST['mail'] ?? '';
    $statut = $_POST['statut'] ?? 'interimaire';

    if (!empty($nom) && !empty($mail)) {
        $update = $pdo->prepare("UPDATE users SET username = ?, phone_number = ?, address = ?, mail = ?, statut = ? WHERE id_utilisateur = ?");
        $success = $update->execute([$nom, $phone_number, $address, $mail, $statut, $id]);

        if ($success) {
            header("Location: modifier_medecin.php?id=$id&success=1");
            exit();
        } else {
            $message = "Erreur lors de la modification.";
        }
    } else {
        $message = "Le nom et l'email sont requis.";
    }

    // Recharge
    $stmt = $pdo->prepare("SELECT * FROM users WHERE id_utilisateur = ?");
    $stmt->execute([$id]);
    $medecin = $stmt->fetch();
}

include 'includes/header.php';
include 'includes/sidebar-admin.php';
?>

<div class="pc-container">
  <div class="pc-content">
    <h4 class="mb-4">Modifier un Médecin</h4>

    <?php if ($message): ?>
      <div class="alert alert-info"><?= htmlspecialchars($message) ?></div>
    <?php endif; ?>

    <form method="post">
      <div class="grid grid-cols-12 gap-4">

        <!-- Nom -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Nom complet</label>
            <input type="text" name="username" class="form-control mt-1" value="<?= htmlspecialchars($medecin['username']) ?>" required>
          </div>
        </div>

        <!-- Email -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Numero de Téléphone</label>
            <input type="phone_number" name="phone_number" class="form-control mt-1" value="<?= htmlspecialchars($medecin['phone_number']) ?>" required>
          </div>
        </div>

        <!-- Spécialité -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Address</label>
            <input type="text" name="Address" class="form-control mt-1" value="<?= htmlspecialchars($medecin['address']) ?>">
          </div>
        </div>

        <!-- Téléphone -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">mail</label>
            <input type="text" name="mail" class="form-control mt-1" value="<?= htmlspecialchars($medecin['mail']) ?>">
          </div>
        </div>

        <!-- Adresse 
        <div class="col-span-12">
          <div class="card p-4">
            <label class="font-semibold">Adresse</label>
            <textarea name="adresse" class="form-control mt-1"><?= htmlspecialchars($medecin['adresse']) ?></textarea>
          </div>
        </div>-->

        <!-- Statut -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Statut</label>
            <select name="statut" class="form-control mt-1">
              <option value="principal" <?= $medecin['statut'] === 'principal' ? 'selected' : '' ?>>Principal</option>
              <option value="interimaire" <?= $medecin['statut'] === 'interimaire' ? 'selected' : '' ?>>Intérimaire</option>
            </select>
          </div>
        </div>

        <!-- Boutons -->
        <div class="col-span-12 text-end">
          <button type="submit" class="btn btn-primary">💾 Enregistrer les modifications</button>
          <a href="liste_medecins.php" class="btn btn-secondary">↩️ Retour</a>
        </div>
      </div>
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
