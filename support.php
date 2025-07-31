<?php
session_start();
require_once 'db.php';

if (!isset($_SESSION['user'])) {
    header("Location: login.php");
    exit();
}

// Récupérer l'email sans déclencher d'erreur
$user = $_SESSION['user'];
$email = '';

if (!empty($user['mail'])) {
    $email = $user['mail'];
} elseif (!empty($user['email'])) {
    $email = $user['email'];
}

include 'includes/header.php';
include 'includes/sidebar-' . $_SESSION['user']['role'] . '.php';
?>

<div class="pc-container">
  <div class="pc-content">
    <div class="page-header mb-4">
      <div class="page-block">
        <h5 class="mb-0">
          <i class="fas fa-life-ring me-2"></i>Support technique
        </h5>
      </div>
    </div>

    <!-- Message de confirmation -->
    <?php if (isset($_GET['success'])): ?>
      <div class="alert alert-success">Message envoyé avec succès.</div>
    <?php elseif (isset($_GET['error'])): ?>
      <div class="alert alert-danger">Erreur lors de l'envoi. Veuillez réessayer.</div>
    <?php endif; ?>

    <!-- Formulaire de contact -->
    <div class="card p-4">
      <form action="support_traitement.php" method="POST">
        <div class="grid grid-cols-12 gap-4">

          <!-- Destinataire -->
          <div class="col-span-12 md:col-span-6">
            <label class="font-semibold">Destinataire (email)</label>
            <input type="email" name="destinataire" class="form-control mt-1"
                   required placeholder="ex : admin@domain.com">
          </div>

          <!-- Sujet -->
          <div class="col-span-12 md:col-span-6">
            <label class="font-semibold">Sujet</label>
            <input type="text" name="sujet" class="form-control mt-1" required>
          </div>

          <!-- Email de l'expéditeur -->
          <div class="col-span-12 md:col-span-6">
            <label class="font-semibold">Votre adresse email</label>
            <input type="email" name="email" class="form-control mt-1"
                   value="<?= htmlspecialchars($email) ?>" required>
          </div>

          <!-- Message -->
          <div class="col-span-12">
            <label class="font-semibold">Message</label>
            <textarea name="message" class="form-control mt-1" rows="5" required></textarea>
          </div>
        </div>

        <div class="text-end mt-4">
          <button type="submit" class="btn btn-primary">
            <i class="fas fa-paper-plane me-1"></i>Envoyer
          </button>
        </div>
      </form>
    </div>
  </div>
</div>

<?php include 'includes/footer.php'; ?>
