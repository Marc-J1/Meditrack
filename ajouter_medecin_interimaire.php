<?php
session_start();
include 'includes/header.php';
include 'includes/sidebar-medecin.php'; // Menu admin

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
      <h4 class="mb-3">Ajouter un médecin intérimaire</h4>
    </div>

    <?php if (isset($_GET['success']) && $_GET['success'] == 1): ?>
      <div class="alert alert-success">✅ Médecin ajouté avec succès !</div>
    <?php elseif (isset($_GET['error'])): ?>
      <div class="alert alert-danger">❌ Erreur : <?= htmlspecialchars($_GET['error']) ?></div>
    <?php endif; ?>

    <form action="traitement_ajouter_medecin_interimaire.php" method="POST">
      <div class="grid grid-cols-12 gap-4">

        <!-- Nom complet -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label for="nom" class="font-semibold">Nom complet</label>
            <input type="text" class="form-control mt-1" id="nom" name="nom" required>
          </div>
        </div>

        <!-- Adresse email -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label for="email" class="font-semibold">Adresse e-mail</label>
            <input type="email" class="form-control mt-1" id="email" name="email" required>
          </div>
        </div>

        <!-- Mot de passe -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label for="mot_de_passe" class="font-semibold">Mot de passe</label>
            <input type="password" class="form-control mt-1" id="mot_de_passe" name="mot_de_passe" required>
          </div>
        </div>

        <!-- Spécialité -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label for="specialite" class="font-semibold">Spécialité</label>
            <input type="text" class="form-control mt-1" id="specialite" name="specialite">
          </div>
        </div>

        <!-- Téléphone -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label for="telephone" class="font-semibold">Téléphone</label>
            <input type="text" class="form-control mt-1" id="telephone" name="telephone">
          </div>
        </div>

        <!-- Adresse -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label for="adresse" class="font-semibold">Adresse</label>
            <input type="text" class="form-control mt-1" id="adresse" name="adresse">
          </div>
        </div>

        <!-- Statut -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label for="statut" class="font-semibold">Statut</label>
            <select class="form-control mt-1" id="statut" name="statut">
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
