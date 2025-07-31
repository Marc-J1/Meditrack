<?php
session_start();
require_once __DIR__ . '/config.php';

if (!isset($_SESSION['user'])) {
    header("Location: login.php");
    exit;
}

$message = '';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $ancien = $_POST['ancien_mdp'];
    $nouveau = $_POST['nouveau_mdp'];
    $confirmer = $_POST['confirmer_mdp'];
   $user_id = $_SESSION['user']['id'];


    $stmt = $conn->prepare("SELECT password FROM users WHERE id_utilisateur = ?");
    $stmt->execute([$user_id]);
    $result = $stmt->fetch();

    if ($result) {
       if ($ancien === $result['password']) {
            if ($nouveau === $confirmer) {
                $hash = password_hash($nouveau, PASSWORD_DEFAULT);
                $stmt = $conn->prepare("UPDATE users SET password = ? WHERE id_utilisateur = ?");
                $stmt->execute([$hash, $user_id]);
                $message = "<div class='alert alert-success'>Mot de passe mis à jour avec succès.</div>";
            } else {
                $message = "<div class='alert alert-warning'>Les nouveaux mots de passe ne correspondent pas.</div>";
            }
        } else {
            $message = "<div class='alert alert-danger'>Ancien mot de passe incorrect.</div>";
        }
    }
}
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Changer le mot de passe</title>
    <link rel="stylesheet" href="DattaAble-1.0.0/dist/assets/css/style.css">
    <link rel="stylesheet" href="DattaAble-1.0.0/dist/assets/css/custom.css">
    <style>
        body {
            background-color: #f4f7fa;
        }
        .card {
            margin: 80px auto;
            max-width: 500px;
            padding: 30px;
        }
    </style>
</head>
<body>

    <div class="container">
        <div class="card shadow">
            <h4 class="mb-4">Changer le mot de passe</h4>
            <?= $message ?>
            <form method="post">
                <div class="form-group mb-3">
                    <label>Ancien mot de passe</label>
                    <input type="password" name="ancien_mdp" class="form-control" required>
                </div>
                <div class="form-group mb-3">
                    <label>Nouveau mot de passe</label>
                    <input type="password" name="nouveau_mdp" class="form-control" required>
                </div>
                <div class="form-group mb-4">
                    <label>Confirmer le nouveau mot de passe</label>
                    <input type="password" name="confirmer_mdp" class="form-control" required>
                </div>
                <button type="submit" class="btn btn-primary w-100">Changer</button>
                <?php
// Définir la page de retour selon le rôle
$retour = 'index.php'; // par défaut

if (isset($_SESSION['user']['role'])) {
    switch ($_SESSION['user']['role']) {
        case 'admin':
            $retour = 'dashboard_admin.php';
            break;
        case 'medecin':
            $retour = 'dashboard_medecin.php';
            break;
        case 'secretaire':
            $retour = 'dashboard_secretaire.php';
            break;
    }
}
?>

<a href="<?= $retour ?>" class="btn btn-secondary w-100 mt-2">⬅ Retour au tableau de bord</a>

            </form>
        </div>
    </div>

</body>
</html>
