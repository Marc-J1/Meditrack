<?php
session_start();
require_once __DIR__ . '/config.php'; // doit fournir $conn (PDO)

$obligation = isset($_GET['force']); // force=1 => obligation de changer

if (!isset($_SESSION['user'])) {
    header("Location: login.php");
    exit;
}

$message = '';
$type_message = ''; // success | danger | warning
$redirection = false;

// Page de retour selon le rôle
$retour = 'index.php';
if (!empty($_SESSION['user']['role'])) {
    switch ($_SESSION['user']['role']) {
        case 'admin':    $retour = 'dashboard_admin.php';    break;
        case 'medecin':  $retour = 'dashboard_medecin.php';  break;
        case 'secretaire': $retour = 'dashboard_secretaire.php'; break;
    }
}

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $ancien    = $_POST['ancien_mdp'] ?? '';
    $nouveau   = $_POST['nouveau_mdp'] ?? '';
    $confirmer = $_POST['confirmer_mdp'] ?? '';
    $user_id   = $_SESSION['user']['id'];

    // Récup MDP actuel
    $stmt = $conn->prepare("SELECT password FROM users WHERE id_utilisateur = ?");
    $stmt->execute([$user_id]);
    $row = $stmt->fetch();

    if ($row) {
        $oldOk = ($ancien === $row['password']) || password_verify($ancien, $row['password']);
        if (!$oldOk) {
            $message = "Ancien mot de passe incorrect.";
            $type_message = 'danger';
        } elseif ($nouveau !== $confirmer) {
            $message = "Les nouveaux mots de passe ne correspondent pas.";
            $type_message = 'warning';
        } else {
            // ✅ Vérifications serveur identiques à Ajouter médecin
            $lengthOk    = strlen($nouveau) >= 8;
            $upperOk     = preg_match('/[A-Z]/', $nouveau);
            $lowerOk     = preg_match('/[a-z]/', $nouveau);
            $numberOk    = preg_match('/\d/', $nouveau);

            if (!$lengthOk || !$upperOk || !$lowerOk || !$numberOk) {
                $message = "Mot de passe trop faible. (Min. 8 caractères, 1 majuscule, 1 minuscule, 1 chiffre)";
                $type_message = 'warning';
            } else {
                // Mise à jour
                $hash = password_hash($nouveau, PASSWORD_DEFAULT);
                $up = $conn->prepare("UPDATE users SET password = ?, must_change_password = 0 WHERE id_utilisateur = ?");
                $up->execute([$hash, $user_id]);

                $message = "Mot de passe mis à jour avec succès.";
                $type_message = 'success';
                $redirection = true;
            }
        }
    } else {
        $message = "Utilisateur introuvable.";
        $type_message = 'danger';
    }
}
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Changer le mot de passe</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f4f7fa; }
        .card { margin: 80px auto; max-width: 520px; padding: 30px; }
        .toast-container { position: fixed; top: 1rem; right: 1rem; z-index: 9999; }
        #password-hints span { transition: color .25s ease; margin-right: .75rem; }
        .is-invalid { border: 1px solid #dc3545 !important; }
        .hint-title { font-size: .9rem; color: #6c757d; margin-top: .25rem; }
    </style>
</head>
<body>

<div class="container">
    <div class="card shadow">
        <h4 class="mb-3">Changer le mot de passe</h4>

        <?php if ($obligation): ?>
            <div class="alert alert-warning">
                ⚠️ Pour des raisons de sécurité, vous devez changer votre mot de passe avant d'accéder à l'application.
            </div>
        <?php endif; ?>

        <form method="post" id="form-changepwd" novalidate>
            <div class="form-group mb-3">
                <label>Ancien mot de passe</label>
                <input type="password" name="ancien_mdp" id="ancien_mdp" class="form-control" required>
                <div class="invalid-feedback">Veuillez renseigner votre ancien mot de passe.</div>
            </div>

            <div class="form-group mb-2">
                <label>Nouveau mot de passe</label>
                <input type="password" name="nouveau_mdp" id="nouveau_mdp" class="form-control" required autocomplete="new-password">
                <div class="hint-title">Critères requis :</div>
                <div id="password-hints" class="text-sm text-muted mt-1 d-flex flex-wrap gap-2">
                    <span id="hint-length" class="text-danger">• Min. 8 caractères</span>
                    <span id="hint-upper"  class="text-danger">• 1 majuscule</span>
                    <span id="hint-lower"  class="text-danger">• 1 minuscule</span>
                    <span id="hint-number" class="text-danger">• 1 chiffre</span>
                </div>
            </div>

            <div class="form-group mb-4">
                <label>Confirmer le nouveau mot de passe</label>
                <input type="password" name="confirmer_mdp" id="confirmer_mdp" class="form-control" required autocomplete="new-password">
                <div class="invalid-feedback">La confirmation doit correspondre au nouveau mot de passe.</div>
            </div>

            <button type="submit" class="btn btn-primary w-100">Changer</button>
            <a href="<?= htmlspecialchars($retour) ?>" class="btn btn-secondary w-100 mt-2">⬅ Retour au tableau de bord</a>
        </form>
    </div>
</div>

<!-- Toasts -->
<div class="toast-container position-fixed top-0 end-0 p-3">
    <?php if (!empty($message)): ?>
        <div class="toast align-items-center text-bg-<?= $type_message ?> border-0 show" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex">
                <div class="toast-body"><?= htmlspecialchars($message) ?></div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Fermer"></button>
            </div>
        </div>
    <?php endif; ?>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
// === Indicateurs live / validation côté client (mêmes règles que “Ajouter médecin”) ===
document.addEventListener('DOMContentLoaded', function () {
    const form   = document.getElementById('form-changepwd');
    const oldEl  = document.getElementById('ancien_mdp');
    const passEl = document.getElementById('nouveau_mdp');
    const confEl = document.getElementById('confirmer_mdp');

    const hintLength = document.getElementById('hint-length');
    const hintUpper  = document.getElementById('hint-upper');
    const hintLower  = document.getElementById('hint-lower');
    const hintNumber = document.getElementById('hint-number');

    function toggle(el, ok) {
        el.classList.remove('text-success','text-danger');
        el.classList.add(ok ? 'text-success' : 'text-danger');
    }

    function checkPasswordHints(v) {
        toggle(hintLength, v.length >= 8);
        toggle(hintUpper,  /[A-Z]/.test(v));
        toggle(hintLower,  /[a-z]/.test(v));
        toggle(hintNumber, /\d/.test(v));
    }

    passEl.addEventListener('input', () => {
        checkPasswordHints(passEl.value);
        passEl.classList.remove('is-invalid');
        confEl.classList.remove('is-invalid');
    });

    confEl.addEventListener('input', () => {
        confEl.classList.remove('is-invalid');
    });

    form.addEventListener('submit', (e) => {
        let valid = true;
        // ancien
        if (!oldEl.value.trim()) { oldEl.classList.add('is-invalid'); valid = false; }
        // nouveau
        const v = passEl.value;
        const ok = v.length >= 8 && /[A-Z]/.test(v) && /[a-z]/.test(v) && /\d/.test(v);
        if (!ok) { passEl.classList.add('is-invalid'); valid = false; }
        // confirmer
        if (confEl.value !== v || !confEl.value) { confEl.classList.add('is-invalid'); valid = false; }

        if (!valid) e.preventDefault();
    });

    // init
    checkPasswordHints(passEl.value || '');
});
</script>

<?php if ($redirection): ?>
<script>
  setTimeout(function(){ window.location.href = "<?= $retour ?>"; }, 2000);
</script>
<?php endif; ?>
</body>
</html>
