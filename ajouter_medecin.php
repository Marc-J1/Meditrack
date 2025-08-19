<?php 
session_start();
require_once 'db.php'; // nécessaire pour $pdo
include 'includes/header.php';
include 'includes/sidebar-admin.php';
include 'includes/auto_track.php';
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'Accès à ajouter medecin');

?>

<?php
$type_message = '';
$contenu_message = '';

if (isset($_GET['success']) && $_GET['success'] == 1) {
    $type_message = 'success';
    $contenu_message = 'Médecin ajouté avec succès !';
} elseif (isset($_GET['error'])) {
    $type_message = 'danger';
    $contenu_message = htmlspecialchars($_GET['error']);
}
?>

<?php if (!empty($contenu_message)): ?>
<div class="toast-container position-fixed top-0 end-0 p-3">
  <div id="liveToast" class="toast align-items-center text-bg-<?= $type_message ?> border-0 show" role="alert" aria-live="assertive" aria-atomic="true">
    <div class="d-flex">
      <div class="toast-body"><?= $contenu_message ?></div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Fermer"></button>
    </div>
  </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function () {
    const toastEl = document.getElementById('liveToast');
    if (toastEl) {
        const toast = new bootstrap.Toast(toastEl, { delay: 3000 });
        toast.show();
    }
});
</script>
<?php endif; ?>

<style>
#password-hints li { transition: color 0.3s ease; }
.is-invalid { border: 1px solid red !important; }
.error-message { color: red; font-size: 0.875rem; margin-top: 4px; display: none; }
</style>

<div class="pc-container">
  <div class="pc-content">
    <div class="page-header mb-4">
      <h4 class="mb-3">Ajouter un médecin</h4>
    </div>

    <form action="traitement_ajouter_medecin.php" method="POST" id="form-medecin" novalidate>
      <div class="grid grid-cols-12 gap-4">

        <?php
        // name, label, type, placeholder, attrs (string)
        $champs = [
          // 🆕 Identifiant (utilisé pour la connexion)
          ['identifiant', 'Identifiant (login)', 'text', 'Ex. dr.koumba', 'maxlength="50" autocomplete="username"'],
          ['nom', 'Nom complet', 'text', 'Ex. Jean K.', 'maxlength="100" autocomplete="name"'],
          ['password', 'Mot de passe', 'password', 'Min. 8 caractères', 'autocomplete="new-password"'],
          ['phone_number', 'Numéro de téléphone', 'tel', 'Ex. +242 06 123 45 67', 'inputmode="tel" maxlength="20"'],
          ['address', 'Adresse', 'text', 'Ex. Quartier Moungali, Arr. Moungali, Brazzaville (B.P. 1234)', 'maxlength="255" autocomplete="street-address"'],
          ['mail', 'Adresse mail', 'email', 'Ex. nom@example.com', 'maxlength="100" autocomplete="email"'],
        ];

        foreach ($champs as $champ) {
          [$name, $label, $type, $placeholder, $attrs] = $champ;
          echo '<div class="col-span-12 md:col-span-6"><div class="card p-4">';
          echo "<label class='font-semibold' for='$name'>$label</label>";
          echo "<input type='$type' name='$name' id='$name' class='form-control mt-1 required-field' placeholder=\"$placeholder\" $attrs>";

          if ($name === 'password') {
            echo "<div id='password-hints' class='text-sm text-muted mt-2 d-flex flex-wrap gap-3'>";
            echo "<span id='length' class='text-danger'>• Min. 8 caractères</span>";
            echo "<span id='uppercase' class='text-danger'>Min 1 Majuscule</span>";
            echo "<span id='lowercase' class='text-danger'>Min 1 Minuscule</span>";
            echo "<span id='number' class='text-danger'>Min 1 Chiffre</span>";
            echo "</div>";
          }

          echo "<div class='error-message' id='error-$name'>Champ obligatoire</div>";
          echo '</div></div>';
        }
        ?>

        <!-- Statut -->
        <div class="col-span-12 md:col-span-6">
          <div class="card p-4">
            <label for="statut" class="font-semibold">Statut</label>
            <select class="form-control mt-1 required-field" id="statut" name="statut">
              <option value="">-- Sélectionner --</option>
              <option value="principal">Médecin principal</option>
              <option value="interimaire">Intérimaire</option>
            </select>
            <div class="error-message" id="error-statut">Champ obligatoire</div>
          </div>
        </div>

        <div class="col-span-12 text-end">
          <button type="submit" class="btn btn-primary">Ajouter le médecin</button>
        </div>
      </div>
    </form>
  </div>
</div>

<script>
// -------- Validation générique + règles spécifiques ----------
document.addEventListener("DOMContentLoaded", function () {
  const form = document.getElementById("form-medecin");
  const fields = document.querySelectorAll(".required-field");

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
  const e164Regex  = /^\+?[1-9]\d{6,14}$/;
  const idRegex    = /^[a-zA-Z0-9._-]{3,50}$/; // identifiant : 3-50, lettres/chiffres . _ -

  function setError(field, msg) {
    const err = document.getElementById("error-" + field.name);
    field.classList.add("is-invalid");
    if (err) { err.textContent = msg || "Champ obligatoire"; err.style.display = "block"; }
  }
  function clearError(field) {
    const err = document.getElementById("error-" + field.name);
    field.classList.remove("is-invalid");
    if (err) err.style.display = "none";
  }

  function validateSpecific(field) {
    const v = field.value.trim();

    if (!v) { setError(field, "Champ obligatoire"); return false; }

    if (field.name === "identifiant") {
      if (!idRegex.test(v)) { setError(field, "3-50 caractères, lettres/chiffres . _ -"); return false; }
      return true;
    }

    if (field.name === "mail") {
      if (/\r|\n/.test(v)) { setError(field, "Email invalide."); return false; }
      if (!emailRegex.test(v)) { setError(field, "Veuillez saisir un email valide."); return false; }
      return true;
    }

    if (field.name === "phone_number") {
      const cleaned = v.replace(/[^\d+]/g, "");
      if (!e164Regex.test(cleaned)) {
        const cgOk = (/^\+242\d{9}$/.test(cleaned)) || (/^0\d{9}$/.test(cleaned));
        if (!cgOk) {
          setError(field, "Numéro invalide. Ex.: +242 06 123 45 67");
          return false;
        }
      }
      return true;
    }

    if (field.name === "address") {
      if (v.length < 4 || v.length > 255) {
        setError(field, "Adresse : 4 à 255 caractères.");
        return false;
      }
      const addrOk = /^[\p{L}\p{M}\d\s\-\'\/,\.]{4,255}$/u.test(v);
      if (!addrOk) { setError(field, "Caractères non autorisés dans l'adresse."); return false; }
      return true;
    }

    if (field.name === "password") {
      if (v.length < 8 || !/[A-Z]/.test(v) || !/[a-z]/.test(v) || !/\d/.test(v)) {
        setError(field, "Mot de passe trop faible.");
        return false;
      }
      return true;
    }

    return true;
  }

  fields.forEach(field => {
    field.addEventListener("blur", () => { clearError(field); validateSpecific(field); });
    field.addEventListener("input", () => clearError(field));
  });

  form.addEventListener("submit", function (e) {
    let valid = true;
    fields.forEach(field => { if (!validateSpecific(field)) valid = false; });
    if (!valid) {
      e.preventDefault();
      alert("Veuillez corriger les champs en rouge.");
    }
  });
});
</script>

<script>
// Indicateurs mot de passe
document.addEventListener("DOMContentLoaded", function () {
  const passwordInput = document.getElementById("password");
  if (!passwordInput) return;

  passwordInput.addEventListener("input", function () {
    const value = passwordInput.value;
    toggleHint("length", value.length >= 8);
    toggleHint("uppercase", /[A-Z]/.test(value));
    toggleHint("lowercase", /[a-z]/.test(value));
    toggleHint("number", /\d/.test(value));
  });

  function toggleHint(id, valid) {
    const item = document.getElementById(id);
    if (item) {
      item.classList.remove("text-success", "text-danger");
      item.classList.add(valid ? "text-success" : "text-danger");
    }
  }
});
</script>

<?php include 'includes/footer.php'; ?>
