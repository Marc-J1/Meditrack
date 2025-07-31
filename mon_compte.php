<?php
session_start();
require_once 'db.php';

// Vérifier que l'utilisateur est connecté
if (!isset($_SESSION['user'])) {
    header("Location: login.php");
    exit();
}

$user_id = $_SESSION['user']['id'];
$user_role = $_SESSION['user']['role'];

// Récupérer les informations de l'utilisateur
if ($user_role === 'medecin_interimaire') {
    // Pour les médecins intérimaires, récupérer depuis la table medecins
    $stmt = $pdo->prepare("SELECT * FROM medecins WHERE id_medecin = ?");
    $stmt->execute([$user_id]);
    $user_data = $stmt->fetch();
    $is_interimaire = true;
} else {
    // Pour admin et médecin principal, récupérer depuis la table users
    $stmt = $pdo->prepare("SELECT * FROM users WHERE id_utilisateur = ?");
    $stmt->execute([$user_id]);
    $user_data = $stmt->fetch();
    $is_interimaire = false;
}

// Récupérer les statistiques selon le rôle
$stats = [];
if (in_array($user_role, ['medecin', 'medecin_interimaire'])) {
    // Statistiques pour médecins
    $stmt = $pdo->prepare("SELECT COUNT(DISTINCT id_patient) as total_patients FROM consultations WHERE id_utilisateur = ?");
    $stmt->execute([$user_id]);
    $stats['patients'] = $stmt->fetchColumn();
    
    $stmt = $pdo->prepare("SELECT COUNT(*) as total_consultations FROM consultations WHERE id_utilisateur = ?");
    $stmt->execute([$user_id]);
    $stats['consultations'] = $stmt->fetchColumn();
    
    $stmt = $pdo->prepare("SELECT COUNT(*) as total_ordonnances FROM ordonnances WHERE id_utilisateur = ?");
    $stmt->execute([$user_id]);
    $stats['ordonnances'] = $stmt->fetchColumn();
    
    $stmt = $pdo->prepare("SELECT COUNT(*) as total_observations FROM observations WHERE id_utilisateur = ?");
    $stmt->execute([$user_id]);
    $stats['observations'] = $stmt->fetchColumn();
} else {
    // Statistiques pour admin
    $stats['total_users'] = $pdo->query("SELECT COUNT(*) FROM users")->fetchColumn();
    $stats['total_medecins'] = $pdo->query("SELECT COUNT(*) FROM medecins")->fetchColumn();
    $stats['total_patients'] = $pdo->query("SELECT COUNT(*) FROM patients")->fetchColumn();
}

include 'includes/header.php';

// Inclure la sidebar appropriée selon le rôle
if ($user_role === 'admin') {
    include 'includes/sidebar-admin.php';
} elseif ($user_role === 'medecin') {
    include 'includes/sidebar-medecin.php';
} else {
    include 'includes/sidebar-interimaire.php';
}
?>

<style>
.profile-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border-radius: 10px;
    padding: 2rem;
    margin-bottom: 1.5rem;
}

.profile-avatar {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    border: 4px solid rgba(255,255,255,0.3);
    object-fit: cover;
}

.stat-card {
    transition: all 0.3s ease;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.info-card {
    border: none;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    border-radius: 8px;
}

.form-control:focus {
    border-color: #667eea;
    box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
}

.btn-primary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
}

.btn-primary:hover {
    background: linear-gradient(135deg, #5a6fd8 0%, #6a4190 100%);
}
</style>
<style>
.stat-card {
    transition: all 0.3s ease;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
.stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}
.stat-number {
    font-size: 1.75rem;
    font-weight: 700;
}
.stat-title {
    font-size: 0.875rem;
    font-weight: 600;
    color: #374151;
}
.stat-subtitle {
    font-size: 0.75rem;
    color: #9ca3af;
}
</style>


<!-- Contenu principal -->
<div class="pc-container">
    <div class="pc-content">
        <div class="page-header">
            <div class="page-block">
                <div class="page-header-title">
                    <h5 class="mb-0 font-medium">
                        <i class="fas fa-user-circle me-2"></i>Mon compte
                    </h5>
                </div>
                <ul class="breadcrumb">
                    <li class="breadcrumb-item"><a href="#">Accueil</a></li>
                    <li class="breadcrumb-item active">Mon compte</li>
                </ul>
            </div>
        </div>

        <!-- En-tête du profil -->
        <div class="profile-header">
            <div class="row align-items-center">
                <div class="col-auto">
                    <?php 
                    $photo_path = isset($user_data['photo']) && !empty($user_data['photo']) 
    ? 'DattaAble-1.0.0/dist/assets/profiles/' . $user_data['photo'] 
    : 'DattaAble-1.0.0/dist/assets/images/user/avatar-default.png';

                    ?>
                    
               <img src="DattaAble-1.0.0/dist/assets/profiles/<?= htmlspecialchars($user_data['photo']) ?>">

                        </div>
                <div class="col">
                    <h3 class="mb-1">
                        <?= htmlspecialchars($is_interimaire ? $user_data['nom_complet'] : $user_data['username']) ?>
                    </h3>
                    <p class="mb-1 opacity-75">
                        <i class="fas fa-user-tag me-2"></i>
                        <?php
                        $role_display = [
                            'admin' => 'Administrateur',
                            'medecin' => 'Médecin Principal',
                            'medecin_interimaire' => 'Médecin Intérimaire'
                        ];
                        echo $role_display[$user_role] ?? $user_role;
                        ?>
                    </p>
                    <p class="mb-0 opacity-75">
                        <i class="fas fa-calendar me-2"></i>
                        Membre depuis le <?= date('d/m/Y', strtotime($user_data['date_creation'])) ?>
                    </p>
                </div>
            </div>
        </div>

        <!-- Statistiques -->
        <?php if (in_array($user_role, ['medecin', 'medecin_interimaire'])): ?>
  <!-- Statistiques - Style tableau de bord -->
<div class="mb-6">
    <div class="grid grid-cols-4 gap-4 mb-4">

        <!-- Patients suivis -->
        <div class="stat-card bg-white p-4 border-l-4 border-blue-500">
            <div class="flex items-center">
                <div class="p-2 bg-blue-100 rounded-lg mr-3">
                    <i class="fas fa-users text-blue-600"></i>
                </div>
                <div class="flex-1">
                    <p class="stat-title">Patients suivis</p>
                    <p class="stat-number text-blue-600"><?= $stats['patients'] ?? 0 ?></p>
                    <p class="stat-subtitle">Total</p>
                </div>
            </div>
        </div>

        <!-- Consultations -->
        <div class="stat-card bg-white p-4 border-l-4 border-green-500">
            <div class="flex items-center">
                <div class="p-2 bg-green-100 rounded-lg mr-3">
                    <i class="fas fa-stethoscope text-green-600"></i>
                </div>
                <div class="flex-1">
                    <p class="stat-title">Consultations</p>
                    <p class="stat-number text-green-600"><?= $stats['consultations'] ?? 0 ?></p>
                    <p class="stat-subtitle">Total</p>
                </div>
            </div>
        </div>

        <!-- Ordonnances -->
        <div class="stat-card bg-white p-4 border-l-4 border-yellow-500">
            <div class="flex items-center">
                <div class="p-2 bg-yellow-100 rounded-lg mr-3">
                    <i class="fas fa-prescription-bottle-alt text-yellow-600"></i>
                </div>
                <div class="flex-1">
                    <p class="stat-title">Ordonnances</p>
                    <p class="stat-number text-yellow-600"><?= $stats['ordonnances'] ?? 0 ?></p>
                    <p class="stat-subtitle">Émises</p>
                </div>
            </div>
        </div>

        <!-- Observations -->
        <div class="stat-card bg-white p-4 border-l-4 border-purple-500">
            <div class="flex items-center">
                <div class="p-2 bg-purple-100 rounded-lg mr-3">
                    <i class="fas fa-clipboard-list text-purple-600"></i>
                </div>
                <div class="flex-1">
                    <p class="stat-title">Observations</p>
                    <p class="stat-number text-purple-600"><?= $stats['observations'] ?? 0 ?></p>
                    <p class="stat-subtitle">Total</p>
                </div>
            </div>
        </div>

    </div>
</div>


        <?php elseif ($user_role === 'admin'): ?>
 <!-- Statistiques Admin : style compact sur une seule ligne -->
<div class="mb-6">
  <div class="grid grid-cols-3 gap-4 mb-4">

    <!-- Utilisateurs -->
    <div class="stat-card bg-white p-4 border-l-4 border-blue-500">
      <div class="flex items-center">
        <div class="p-2 bg-blue-100 rounded-lg mr-3">
          <i class="fas fa-users-cog text-blue-600"></i>
        </div>
        <div class="flex-1">
          <p class="stat-title">Utilisateurs</p>
          <p class="stat-number text-blue-600"><?= $stats['total_users'] ?? $totalUsers ?></p>
          <p class="stat-subtitle">Total</p>
        </div>
      </div>
    </div>

    <!-- Médecins -->
    <div class="stat-card bg-white p-4 border-l-4 border-green-500">
      <div class="flex items-center">
        <div class="p-2 bg-green-100 rounded-lg mr-3">
          <i class="fas fa-user-md text-green-600"></i>
        </div>
        <div class="flex-1">
          <p class="stat-title">Médecins</p>
          <p class="stat-number text-green-600"><?= $stats['total_medecins'] ?? $totalMedecins ?></p>
          <p class="stat-subtitle">Total</p>
        </div>
      </div>
    </div>

    <!-- Patients -->
    <div class="stat-card bg-white p-4 border-l-4 border-purple-500">
      <div class="flex items-center">
        <div class="p-2 bg-purple-100 rounded-lg mr-3">
          <i class="fas fa-hospital-user text-purple-600"></i>
        </div>
        <div class="flex-1">
          <p class="stat-title">Patients</p>
          <p class="stat-number text-purple-600"><?= $stats['total_patients'] ?? 0 ?></p>
          <p class="stat-subtitle">Total</p>
        </div>
      </div>
    </div>

  </div>
</div>

        <?php endif; ?>

   <div class="row">
    <div class="col-lg-8 mb-4">
        <div class="card info-card">
            <div class="card-header bg-light">
                <h6 class="mb-0">
                    <i class="fas fa-user-edit me-2"></i>Informations personnelles
                </h6>
            </div>
            <div class="card-body">
                <form id="profileForm" method="POST" action="update_profile.php" enctype="multipart/form-data">
                    <div class="grid grid-cols-12 gap-4">

                        <!-- Nom d'utilisateur / Nom complet -->
                        <div class="col-span-12 md:col-span-6">
                            <div class="card p-4">
                                <label class="font-semibold">Nom d'utilisateur</label>
                                <input type="text" name="username" class="form-control mt-1"
                                    value="<?= htmlspecialchars($is_interimaire ? $user_data['nom_complet'] : $user_data['username']) ?>" required>
                            </div>
                        </div>

                        <!-- Email -->
                        <div class="col-span-12 md:col-span-6">
                            <div class="card p-4">
                                <label class="font-semibold">Email</label>
                                <input type="email" name="email" class="form-control mt-1"
                                    value="<?= htmlspecialchars($user_data['email'] ?? $user_data['mail']) ?>" required>
                            </div>
                        </div>

                        <!-- Téléphone -->
                        <div class="col-span-12 md:col-span-6">
                            <div class="card p-4">
                                <label class="font-semibold">Téléphone</label>
                                <input type="text" name="telephone" class="form-control mt-1"
                                    value="<?= htmlspecialchars($user_data['telephone'] ?? $user_data['phone_number']) ?>">
                            </div>
                        </div>

                        <!-- Adresse -->
                        <div class="col-span-12 md:col-span-6">
                            <div class="card p-4">
                                <label class="font-semibold">Adresse</label>
                                <input type="text" name="adresse" class="form-control mt-1"
                                    value="<?= htmlspecialchars($user_data['adresse'] ?? $user_data['address']) ?>">
                            </div>
                        </div>

                        <!-- Spécialité (si médecin intérimaire) -->
                        <?php if ($is_interimaire): ?>
                        <div class="col-span-12">
                            <div class="card p-4">
                                <label class="font-semibold">Spécialité</label>
                                <input type="text" name="specialite" class="form-control mt-1"
                                    value="<?= htmlspecialchars($user_data['specialite']) ?>">
                            </div>
                        </div>
                        <?php endif; ?>
                    </div>

                    <!-- Boutons -->
                    <div class="text-end mt-4">
                        <button type="button" class="btn btn-secondary me-2" onclick="location.reload()">
                            <i class="fas fa-undo me-1"></i>Annuler
                        </button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save me-1"></i>Enregistrer les modifications
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>



           

<!-- Scripts -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Validation du formulaire de mot de passe
    document.getElementById('passwordForm').addEventListener('submit', function(e) {
        const newPassword = document.getElementsByName('new_password')[0].value;
        const confirmPassword = document.getElementsByName('confirm_password')[0].value;
        
        if (newPassword !== confirmPassword) {
            e.preventDefault();
            alert('Les nouveaux mots de passe ne correspondent pas.');
            return false;
        }
        
        if (newPassword.length < 6) {
            e.preventDefault();
            alert('Le nouveau mot de passe doit contenir au moins 6 caractères.');
            return false;
        }
    });

    // Prévisualisation de la photo de profil
    document.getElementsByName('photo')[0].addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                document.querySelector('.profile-avatar').src = e.target.result;
                document.querySelector('.rounded-circle').src = e.target.result;
            };
            reader.readAsDataURL(file);
        }
    });
});
</script>

<?php include 'includes/footer.php'; ?>