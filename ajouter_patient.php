<?php
session_start();
if (!isset($_SESSION['user']) || ($_SESSION['user']['role'] !== 'medecin')) {
    header("Location: login.php");
    exit();
}

include 'includes/header.php';
include 'includes/sidebar-medecin.php'; 
?>

<div class="pc-container">
  <div class="pc-content">
    <div class="page-header mb-4">
      <h4 class="mb-3">Ajouter un patient</h4>
    </div>

    <?php if (isset($_GET['success'])): ?>
      <div class="alert alert-success">✅ Patient ajouté avec succès.</div>
    <?php elseif (isset($_GET['error'])): ?>
      <div class="alert alert-danger">❌ Erreur : <?= htmlspecialchars($_GET['error']) ?></div>
    <?php endif; ?>

    <form action="ajouter_patient_traitement.php" method="POST">
      <div class="grid grid-cols-12 gap-4">

        <!-- Nom -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Nom</label>
            <input type="text" name="nom" class="form-control mt-1" required>
          </div>
        </div>

        <!-- Prénom -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Prénom</label>
            <input type="text" name="prenom" class="form-control mt-1" required>
          </div>
        </div>

        <!-- Sexe -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Sexe</label>
           <select name="sexe" class="form-control mt-1" required>
  <option value="">-- Sélectionner --</option>
  <option value="Homme">Homme</option>
  <option value="Femme">Femme</option>
</select>
          </div>
        </div>

        <!-- Date de naissance -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Date de naissance</label>
            <input type="date" name="date_naissance" class="form-control mt-1" required>
          </div>
        </div>

        <!-- Téléphone -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Téléphone</label>
            <input type="text" name="telephone" class="form-control mt-1"required>
          </div>
        </div>

        <!-- Profession -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Profession</label>
            <input type="text" name="profession" class="form-control mt-1" required>
          </div>
        </div>

        <!-- Poids -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Poids (kg)</label>
            <input type="number" step="0.01" name="poids" class="form-control mt-1" required>
          </div>
        </div>

        <!-- Taille -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Taille (m)</label>
            <input type="number" step="0.01" name="taille" class="form-control mt-1" required>
          </div>
        </div>

        <!-- Loisirs -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Loisirs</label>
            <input type="text" name="loisirs" class="form-control mt-1">
          </div>
        </div>

        <!-- Divers -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Divers</label>
            <input type="text" name="divers" class="form-control mt-1">
          </div>
        </div>

        <!-- Antécédents médicaux -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Antécédents médicaux</label>
            <textarea name="antecedents_medicaux" class="form-control mt-1" rows="2"></textarea>
          </div>
        </div>

        <!-- Chirurgicaux -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Antécédents chirurgicaux</label>
            <textarea name="chirurgicaux" class="form-control mt-1" rows="2"></textarea>
          </div>
        </div>

        <!-- Antécédents familiaux -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Antécédents familiaux</label>
            <textarea name="familiaux" class="form-control mt-1" rows="2"></textarea>
          </div>
        </div>

        <!-- Mentions particulières -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label class="font-semibold">Mentions particulières</label>
            <textarea name="mentions_particulieres" class="form-control mt-1" rows="2"></textarea>
          </div>
        </div>

        <!-- Bouton -->
        <div class="col-span-12 text-end">
          <button type="submit" class="btn btn-primary">Enregistrer le patient</button>
        </div>
      </div>
    </form>
  </div>
</div>



<?php include 'includes/footer.php'; ?>
