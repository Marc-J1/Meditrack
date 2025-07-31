<?php
session_start();
require_once 'db.php';

// Vérifier que l'utilisateur est connecté
if (!isset($_SESSION['user'])) {
    header("Location: login.php");
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header("Location: mon_compte.php");
    exit();
}

$user_id = $_SESSION['user']['id'];
$user_role = $_SESSION['user']['role'];
$is_interimaire = ($user_role === 'medecin_interimaire');

try {
    $pdo->beginTransaction();

    // Traitement de l'upload de photo
    $photo_filename = null;
    if (isset($_FILES['photo']) && $_FILES['photo']['error'] === UPLOAD_ERR_OK) {
        $upload_dir = 'DattaAble-1.0.0/dist/assets/profiles';
        
        // Créer le dossier s'il n'existe pas
        if (!file_exists($upload_dir)) {
            mkdir($upload_dir, 0755, true);
        }

        $file_tmp = $_FILES['photo']['tmp_name'];
        $file_name = $_FILES['photo']['name'];
        $file_ext = strtolower(pathinfo($file_name, PATHINFO_EXTENSION));
        
        // Vérifier le type de fichier
        $allowed_extensions = ['jpg', 'jpeg', 'png', 'gif'];
        if (!in_array($file_ext, $allowed_extensions)) {
            throw new Exception("Type de fichier non autorisé. Utilisez JPG, PNG ou GIF.");
        }

        // Vérifier la taille du fichier (max 5MB)
        if ($_FILES['photo']['size'] > 5 * 1024 * 1024) {
            throw new Exception("Le fichier est trop volumineux. Taille maximale : 5MB.");
        }

        // Générer un nom unique pour le fichier
        $photo_filename = $user_id . '_' . time() . '.' . $file_ext;
        $photo_path = $upload_dir . $photo_filename;

        // Déplacer le fichier uploadé
        if (!move_uploaded_file($file_tmp, $photo_path)) {
            throw new Exception("Erreur lors de l'upload de la photo.");
        }

        // Redimensionner l'image (optionnel)
        if (extension_loaded('gd')) {
            resizeImage($photo_path, 300, 300);
        }
    }

    if ($is_interimaire) {
        // Mise à jour pour médecin intérimaire (table medecins)
        $sql = "UPDATE medecins SET 
                nom_complet = ?, 
                email = ?, 
                telephone = ?, 
                adresse = ?, 
                specialite = ?";
        $params = [
            $_POST['username'],
            $_POST['email'],
            $_POST['telephone'],
            $_POST['adresse'],
            $_POST['specialite']
        ];

        if ($photo_filename) {
            $sql .= ", photo = ?";
            $params[] = $photo_filename;
        }

        $sql .= " WHERE id_medecin = ?";
        $params[] = $user_id;

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);

        // Mettre à jour la session
        $_SESSION['user']['username'] = $_POST['username'];

    } else {
        // Mise à jour pour admin/médecin principal (table users)
        $sql = "UPDATE users SET 
                username = ?, 
                mail = ?, 
                phone_number = ?, 
                address = ?";
        $params = [
            $_POST['username'],
            $_POST['email'],
            $_POST['telephone'],
            $_POST['adresse']
        ];

        if ($photo_filename) {
            $sql .= ", photo = ?";
            $params[] = $photo_filename;
        }

        $sql .= " WHERE id_utilisateur = ?";
        $params[] = $user_id;

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);

        // Mettre à jour la session
        $_SESSION['user']['username'] = $_POST['username'];
    }

    $pdo->commit();
    $_SESSION['success_message'] = "Profil mis à jour avec succès.";

} catch (Exception $e) {
    $pdo->rollBack();
    $_SESSION['error_message'] = "Erreur lors de la mise à jour : " . $e->getMessage();
}

header("Location: mon_compte.php");
exit();

/**
 * Fonction pour redimensionner une image
 */
function resizeImage($filename, $max_width, $max_height) {
    list($orig_width, $orig_height) = getimagesize($filename);
    
    $width = $orig_width;
    $height = $orig_height;
    
    // Calculer les nouvelles dimensions
    if ($width > $max_width || $height > $max_height) {
        $ratio_w = $max_width / $width;
        $ratio_h = $max_height / $height;
        $ratio = min($ratio_w, $ratio_h);
        
        $width = intval($width * $ratio);
        $height = intval($height * $ratio);
    }
    
    $image_p = imagecreatetruecolor($width, $height);
    
    // Créer l'image source selon le type
    $ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
    switch ($ext) {
        case 'jpeg':
        case 'jpg':
            $image = imagecreatefromjpeg($filename);
            break;
        case 'png':
            $image = imagecreatefrompng($filename);
            // Préserver la transparence
            imagealphablending($image_p, false);
            imagesavealpha($image_p, true);
            $transparent = imagecolorallocatealpha($image_p, 255, 255, 255, 127);
            imagefilledrectangle($image_p, 0, 0, $width, $height, $transparent);
            break;
        case 'gif':
            $image = imagecreatefromgif($filename);
            break;
        default:
            return false;
    }
    
    imagecopyresampled($image_p, $image, 0, 0, 0, 0, $width, $height, $orig_width, $orig_height);
    
    // Sauvegarder l'image redimensionnée
    switch ($ext) {
        case 'jpeg':
        case 'jpg':
            imagejpeg($image_p, $filename, 90);
            break;
        case 'png':
            imagepng($image_p, $filename);
            break;
        case 'gif':
            imagegif($image_p, $filename);
            break;
    }
    
    imagedestroy($image);
    imagedestroy($image_p);
    
    return true;
}
?>