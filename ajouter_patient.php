<?php
session_start();

// ✅ Toujours initialiser la base de données avant de l'utiliser
require_once 'db.php';

// ✅ Logger disponible après la base
require_once 'includes/activity_logger.php';
$activityLogger = initActivityLogger($pdo);
logPageVisit(basename($_SERVER['PHP_SELF']), 'Est entrer dans la page Ajouter un patient');

// ✅ Vérification de la session utilisateur
if (!isset($_SESSION['user']) || ($_SESSION['user']['role'] !== 'medecin')) {
    header("Location: login.php");
    exit();
}

// ✅ Auto-tracking doit venir après session et logger
include 'includes/auto_track.php';
logPageVisit(basename($_SERVER['PHP_SELF']), 'Accès à ajouter patient');

include 'includes/header.php';
include 'includes/sidebar-medecin.php';
?>

<style>
    .is-invalid { border: 1px solid red !important; }
    .error-message { color: red; font-size: 0.875rem; margin-top: 4px; display: none; }
    /* Optionnel : ajuste un peu le select d’indicatif */
    #indicatif_mode { max-width: 220px; }
    #indicatif_custom { max-width: 140px; }
</style>

<div class="pc-container">
  <div class="pc-content">
    <div class="page-header mb-4">
      <h4 class="mb-3">Ajouter un patient</h4>
    </div>

    <!-- ✅ TOAST MESSAGE -->
<?php
$type_message = '';
$contenu_message = '';

if (isset($_GET['success'])) {
    $val = (string)$_GET['success'];
    // Si on reçoit "1" ou "true", on affiche un message par défaut
    if ($val === '1' || strtolower($val) === 'true') {
        $type_message = 'success';
        $contenu_message = 'Patient ajouté avec succès.';
    } else {
        $type_message = 'success';
        $contenu_message = htmlspecialchars($val);
    }
} elseif (isset($_GET['error'])) {
    $type_message = 'danger';
    $contenu_message = htmlspecialchars($_GET['error'] ?: 'Une erreur est survenue.');
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
  if (toastEl) new bootstrap.Toast(toastEl, { delay: 3000 }).show();
});
</script>
<?php endif; ?>

    <form action="ajouter_patient_traitement.php" method="POST" id="form-patient" novalidate>
      <div class="grid grid-cols-12 gap-4">

        <?php
        $fields = [
          ['nom', 'Nom', 'text', null, 'placeholder="Ex. NGOMA" maxlength="100"'],
          ['prenom', 'Prénom', 'text', null, 'placeholder="Ex. Christian" maxlength="100"'],
          ['sexe', 'Sexe', 'select', ['Masculin', 'Feminin'], ''],
          // date_naissance : on mettra min/max via JS
          ['date_naissance', 'Date de naissance', 'date', null, ''],
          // ✅ Téléphone: on garde 'telephone' dans le tableau mais on rendra un UI spécial plus bas
          ['telephone', 'Téléphone', 'text', null, 'placeholder="Ex. +242 06 123 45 67" maxlength="20"'],
          ['profession', 'Profession', 'text', null, 'maxlength="100"'],
          // Poids/Taille
          ['poids', 'Poids (kg)', 'number', null, 'step="any" placeholder="Ex. 68.5" min="00" max="300"'],
          ['taille', 'Taille (m)', 'number', null, 'step="any" placeholder="Ex. 1.75" min="0.2" max="2.3"'],
          ['loisirs', 'Loisirs', 'text', null, 'maxlength="255"'],
          ['divers', 'Divers', 'text', null, 'maxlength="255"'],
        ];

        foreach ($fields as $field) {
            [$name, $label, $type, $options, $attrs] = array_pad($field, 5, null);
            $isRequired = in_array($name, ['nom', 'prenom', 'sexe', 'date_naissance', 'telephone', 'profession', 'poids', 'taille']);

            echo '<div class="col-span-12 md:col-span-6"><div class="card p-4">';
            echo "<label class='font-semibold' for='$name'>$label</label>";

            if ($name === 'telephone') {
                // ✅ UI téléphone: indicatif (liste + "Autre") + champ custom + numéro local
                ?>
                <div class="mt-1">
                  <div class="input-group">
                    <select id="indicatif_mode" class="form-select">
                      <option value="+242">🇨🇬 Congo (Brazzaville) +242</option>
                      <option value="+243">🇨🇩 RD Congo +243</option>
                      <option value="+241">🇬🇦 Gabon +241</option>
                      <option value="+237">🇨🇲 Cameroun +237</option>
                      <option value="+236">🇨🇫 Centrafrique +236</option>
                      <option value="+225">🇨🇮 Côte d’Ivoire +225</option>
                      <option value="+33">🇫🇷 France +33</option>
                      <option value="custom">Autre (+…)</option>
                    </select>

                    <input type="text" id="indicatif_custom" class="form-control" placeholder="+XXX"
                           style="display:none;" inputmode="numeric">

                    <input type="tel" id="telephone_local" class="form-control"
                           placeholder="Numéro local (ex. 06 12 34 56 78)" inputmode="numeric">
                  </div>

                  <!-- Champ attendu par le backend (indicatif + numéro sans espaces) -->
                  <input type="hidden" name="telephone" id="telephone" class="required-field">
                  <div class='error-message' id='error-telephone'>Champ obligatoire</div>

                  <small class="text-muted d-block mt-1">
                    Choisissez un indicatif ou “Autre (+…)” pour entrer n’importe quel code pays.
                  </small>
                </div>
                <?php
            } elseif ($type === 'select') {
                echo "<select name='$name' id='$name' class='form-control mt-1 ".($isRequired ? "required-field" : "")."' ".($isRequired ? "required" : "").">";
                echo "<option value=''>-- Sélectionner --</option>";
                foreach ($options as $opt) {
                    echo "<option value='$opt'>$opt</option>";
                }
                echo "</select>";
                if ($isRequired) echo "<div class='error-message' id='error-$name'>Champ obligatoire</div>";
            } elseif ($type === 'date') {
                echo "<input type='date' name='$name' id='$name' class='form-control mt-1 ".($isRequired ? "required-field" : "")."' ".($isRequired ? "required" : "")." $attrs>";
                if ($isRequired) echo "<div class='error-message' id='error-$name'>Champ obligatoire</div>";
            } elseif ($type === 'number') {
                echo "<input type='number' name='$name' id='$name' class='form-control mt-1 ".($isRequired ? "required-field" : "")."' ".($isRequired ? "required" : "")." $attrs>";
                if ($isRequired) echo "<div class='error-message' id='error-$name'>Champ obligatoire</div>";
            } else {
                echo "<input type='text' name='$name' id='$name' class='form-control mt-1 ".($isRequired ? "required-field" : "")."' ".($isRequired ? "required" : "")." $attrs>";
                if ($isRequired) echo "<div class='error-message' id='error-$name'>Champ obligatoire</div>";
            }

            echo '</div></div>';
        }
        ?>

        <!-- Champs textarea -->
        <?php
        $textareas = [
          ['antecedents_medicaux', 'Antécédents médicaux'],
          ['chirurgicaux', 'Antécédents chirurgicaux'],
          ['familiaux', 'Antécédents familiaux'],
          ['mentions_particulieres', 'Mentions particulières']
        ];

        foreach ($textareas as [$name, $label]) {
            echo '<div class="col-span-12 md:col-span-6"><div class="card p-4">';
            echo "<label class='font-semibold' for='$name'>$label</label>";
            echo "<textarea name='$name' id='$name' class='form-control mt-1' rows='2' maxlength='1000'></textarea>";
            echo '</div></div>';
        }
        ?>

        <!-- Bouton -->
        <div class="col-span-12 text-end">
          <button type="submit" class="btn btn-primary">Enregistrer le patient</button>
        </div>
      </div>
    </form>
  </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function () {
  const form = document.getElementById("form-patient");
  const fields = document.querySelectorAll(".required-field");

  // ----- Limites dynamiques Date de naissance -----
  const dob = document.getElementById("date_naissance");
  if (dob) {
    const MIN_DATE = "1900-01-01";
    const today = new Date();
    const yyyy = today.getFullYear();
    const mm = String(today.getMonth()+1).padStart(2, "0");
    const dd = String(today.getDate()).padStart(2, "0");
    const TODAY_STR = `${yyyy}-${mm}-${dd}`;
    dob.setAttribute("min", MIN_DATE);
    dob.setAttribute("max", TODAY_STR);
  }

  fields.forEach(field => {
    field.addEventListener("blur", function () { validateField(field); });
    field.addEventListener("input", function () { clearError(field); });
  });

  function setErr(field, msg) {
    const error = document.getElementById("error-" + field.name);
    field.classList.add("is-invalid");
    if (error) { error.textContent = msg || "Champ obligatoire"; error.style.display = "block"; }
    return false;
  }
  function clearError(field) {
    field.classList.remove("is-invalid");
    const error = document.getElementById("error-" + field.name);
    if (error) error.style.display = "none";
  }

  // =======================
  //   TÉLÉPHONE (souple)
  // =======================
  const modeSel      = document.getElementById('indicatif_mode');
  const codeCustomEl = document.getElementById('indicatif_custom');
  const telLocalEl   = document.getElementById('telephone_local');
  const telHidden    = document.getElementById('telephone');

  function onlyDigits(str){ return (str || '').replace(/\D+/g,''); }
  function normalizeCode(str){
    str = (str || '').trim();
    if (!str) return '';
    if (str[0] !== '+') str = '+' + str;
    str = '+' + onlyDigits(str); // garde uniquement + et chiffres
    return str;
  }
  function getIndicatif(){
    if (!modeSel) return '+242';
    if (modeSel.value === 'custom') {
      return normalizeCode(codeCustomEl.value);
    }
    return modeSel.value; // ex: +242
  }
  function syncTelephone(){
    if (!telHidden) return;
    let code  = getIndicatif();
    let local = onlyDigits(telLocalEl?.value || '');
    if (local.startsWith('0')) local = local.substring(1); // supprime 0 initial
    telHidden.value = (code || '') + local; // ex: +24261234567
  }

  if (modeSel){
    modeSel.addEventListener('change', () => {
      if (modeSel.value === 'custom') {
        codeCustomEl.style.display = '';
        codeCustomEl.focus();
      } else {
        codeCustomEl.style.display = 'none';
      }
      syncTelephone();
      clearError(telHidden);
    });
  }
  codeCustomEl?.addEventListener('input', () => { syncTelephone(); clearError(telHidden); });
  telLocalEl?.addEventListener('input',      () => { syncTelephone(); clearError(telHidden); });

  // première sync au chargement
  syncTelephone();

  // =======================
  //   VALIDATION
  // =======================
  // On garde ta validation existante, on ajoute un cas spécial pour téléphone
  function validateField(field) {
    const v = (field.value || '').trim();
    if (!v) return setErr(field, "Champ obligatoire");

    // Règles spécifiques :
    if (field.name === 'date_naissance') {
      const min = field.getAttribute('min') || '1900-01-01';
      const max = field.getAttribute('max');
      if (max && v > max) return setErr(field, "La date ne peut pas être dans le futur.");
      if (v < min) return setErr(field, "La date ne peut pas être antérieure au " + min.split('-').reverse().join('/'));
      return true;
    }

    if (field.name === 'poids') {
      const n = Number(v.replace(',', '.'));
      if (!isFinite(n)) return setErr(field, "Valeur invalide");
      if (n < 1 || n > 1000) return setErr(field, "Poids hors limites (1–1000 kg)");
      return true;
    }

    if (field.name === 'taille') {
      const n = Number(v.replace(',', '.'));
      if (!isFinite(n)) return setErr(field, "Valeur invalide");
      if (n < 0.2 || n > 4.3) return setErr(field, "Taille hors limites (0.2–4.3 m)");
      // Petit garde-fou avec poids si dispo
      const poidsEl = document.getElementById('poids');
      if (poidsEl && poidsEl.value) {
        const p = Number(poidsEl.value.replace(',', '.'));
        if (isFinite(p)) {
          const bmi = p / Math.pow(n, 2);
          if (bmi > 80) return setErr(field, "Valeurs incohérentes — vérifiez poids/taille.");
        }
      }
      return true;
    }

    if (field.name === 'telephone') {
      syncTelephone();
      const val = (telHidden.value || '').trim();
      if (!val) return setErr(telHidden, "Champ obligatoire");
      if (!val.startsWith('+')) return setErr(telHidden, "Indicatif invalide (ex: +242)");

      const digits = val.replace('+','');
      if (digits.length < 4 || digits.length > 15) {
        return setErr(telHidden, "Numéro invalide (4–15 chiffres au total)");
      }

      // Si mode custom, vérifier taille du code pays (1–4)
      if (modeSel?.value === 'custom') {
        const codeDigits = onlyDigits(codeCustomEl.value);
        if (codeDigits.length < 1 || codeDigits.length > 4) {
          return setErr(telHidden, "Code pays invalide (1–4 chiffres)");
        }
      }
      clearError(telHidden);
      return true;
    }
    return true;
  }

  function clearError(field) {
    field.classList.remove("is-invalid");
    const error = document.getElementById("error-" + field.name);
    if (error) error.style.display = "none";
  }

  form.addEventListener("submit", function (e) {
    let valid = true;
    fields.forEach(field => {
      if (!validateField(field)) valid = false;
    });
    if (!valid) {
      e.preventDefault();
      alert("Veuillez corriger les champs en rouge.");
    }
  });
});
</script>

<?php include 'includes/footer.php'; ?>
