<?php
session_start();
include 'includes/header.php';
include 'includes/sidebar-admin.php'; // Menu admin

// Message de succès ou d'erreur
if (isset($_GET['success']) && $_GET['success'] == 1) {
    echo '<div class="alert alert-success">Médecin ajouté avec succès !</div>';
} elseif (isset($_GET['error'])) {
    echo '<div class="alert alert-danger">Erreur : ' . htmlspecialchars($_GET['error']) . '</div>';
}
?>

<div class="pc-container">
  <div class="pc-content">
    <div class="page-header mb-4">
      <h4 class="mb-3">Ajouter un médecin</h4>
    </div>

    <?php if (isset($_GET['success']) && $_GET['success'] == 1): ?>
      <div class="alert alert-success">✅ Médecin ajouté avec succès !</div>
    <?php elseif (isset($_GET['error'])): ?>
      <div class="alert alert-danger">❌ Erreur : <?= htmlspecialchars($_GET['error']) ?></div>
    <?php endif; ?>

    <form action="traitement_ajouter_medecin.php" method="POST">
      <div class="grid grid-cols-12 gap-4">

        <!-- Nom complet -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label for="username" class="font-semibold">Nom complet</label>
            <input type="text" class="form-control mt-1" id="nom" name="nom" required>
          </div>
        </div>

        <!-- Password -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label for="password" class="font-semibold">Mots de passe</label>
            <input type="password" class="form-control mt-1" id="password" name="password" required>
          </div>
        </div>

        <!-- phone number -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label for="phone_number" class="font-semibold">Numero de téléphone</label>
            <input type="phone_number" class="form-control mt-1" id="phone_number" name="phone_number" required>
          </div>
        </div>

        <!-- Spécialité 
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label for="specialite" class="font-semibold">Spécialité</label>
            <input type="text" class="form-control mt-1" id="specialite" name="specialite">
          </div>
        </div> -->

        <!-- Address -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label for="address" class="font-semibold">Address</label>
            <input type="text" class="form-control mt-1" id="address" name="address">
          </div>
        </div>

        <!-- Mail -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label for="mail" class="font-semibold">Address Mail</label>
            <input type="text" class="form-control mt-1" id="mail" name="mail">
          </div>
        </div>

        <!-- Statut -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label for="statut" class="font-semibold">Statut</label>
            <select class="form-control mt-1" id="statut" name="statut">
              <option value="principal">Médecin principal</option>
              <option value="interimaire" selected>Intérimaire</option>
            </select>
          </div>
        </div>

        <!-- Bouton -->
        <div class="col-span-12 text-end">
          <button type="submit" class="btn btn-primary">➕ Ajouter le médecin</button>
        </div>

      </div>
    </form>
  </div>
</div>

<?php include 'includes/footer.php'; ?>
