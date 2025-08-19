<?php
session_start();
require_once 'db.php';

// 🔐 Vérification de connexion et rôle principal uniquement
if (!isset($_SESSION['user']) || 
    $_SESSION['user']['role'] !== 'medecin' || 
    $_SESSION['user']['statut'] !== 'principal') {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Accès non autorisé']);
    exit();
}

if (!isset($_GET['id']) || !is_numeric($_GET['id'])) {
    echo json_encode(['success' => false, 'message' => 'ID invalide']);
    exit();
}

$id_historique = intval($_GET['id']);

// 🔍 Récupération des détails de l'historique
$stmt = $pdo->prepare("SELECT * FROM historique_patients WHERE id_historique = ?");
$stmt->execute([$id_historique]);
$historique = $stmt->fetch();

if (!$historique) {
    echo json_encode(['success' => false, 'message' => 'Historique introuvable']);
    exit();
}

// 🎨 Génération du HTML des détails
ob_start();
?>

<div class="row">
    <div class="col-md-6">
        <h6>📋 Informations générales</h6>
        <table class="table table-sm">
            <tr>
                <td><strong>Patient:</strong></td>
                <td><?= htmlspecialchars($historique['nom_patient'] . ' ' . $historique['prenom_patient']) ?></td>
            </tr>
            <tr>
                <td><strong>Action:</strong></td>
                <td>
                    <?php
                    $badges = [
                        'ajout' => '<span class="badge bg-success">➕ Ajout</span>',
                        'modification' => '<span class="badge bg-warning">✏️ Modification</span>',
                        'suppression' => '<span class="badge bg-danger">🗑️ Suppression</span>'
                    ];
                    echo $badges[$historique['action_type']] ?? $historique['action_type'];
                    ?>
                </td>
            </tr>
            <tr>
                <td><strong>Utilisateur:</strong></td>
                <td><?= htmlspecialchars($historique['nom_utilisateur']) ?></td>
            </tr>
            <tr>
                <td><strong>Date/Heure:</strong></td>
                <td><?= date('d/m/Y à H:i:s', strtotime($historique['date_action'])) ?></td>
            </tr>
        </table>
    </div>
    <div class="col-md-6">
        <h6>📝 Détails de l'action</h6>
        <p class="text-muted"><?= htmlspecialchars($historique['details_action']) ?></p>
    </div>
</div>

<?php if ($historique['donnees_avant'] || $historique['donnees_apres']): ?>
    <hr>
    <div class="row">
        
        <?php if ($historique['donnees_avant']): ?>
            <div class="col-md-6">
                <h6>📊 Données avant</h6>
                <div class="bg-light p-3 rounded">
                    <?php
                    $donnees_avant = json_decode($historique['donnees_avant'], true);
                    if ($donnees_avant) {
                        foreach ($donnees_avant as $champ => $valeur) {
                            if ($valeur !== null && $valeur !== '') {
                                echo "<strong>" . ucfirst(str_replace('_', ' ', $champ)) . ":</strong> " . htmlspecialchars($valeur) . "<br>";
                            }
                        }
                    }
                    ?>
                </div>
            </div>
        <?php endif; ?>

        <?php if ($historique['donnees_apres']): ?>
            <div class="col-md-6">
                <h6>📊 Données après</h6>
                <div class="bg-light p-3 rounded">
                    <?php
                    $donnees_apres = json_decode($historique['donnees_apres'], true);
                    if ($donnees_apres) {
                        foreach ($donnees_apres as $champ => $valeur) {
                            if ($valeur !== null && $valeur !== '') {
                                // Surligner les changements
                                $class = '';
                                if ($historique['donnees_avant']) {
                                    $avant = json_decode($historique['donnees_avant'], true);
                                    if (isset($avant[$champ]) && $avant[$champ] !== $valeur) {
                                        $class = 'text-success fw-bold';
                                    }
                                }
                                echo "<strong>" . ucfirst(str_replace('_', ' ', $champ)) . ":</strong> <span class='$class'>" . htmlspecialchars($valeur) . "</span><br>";
                            }
                        }
                    }
                    ?>
                </div>
            </div>
        <?php endif; ?>

    </div>

    <?php if ($historique['action_type'] === 'modification' && $historique['donnees_avant'] && $historique['donnees_apres']): ?>
        <hr>
        <h6>🔄 Résumé des changements</h6>
        <div class="bg-info bg-opacity-10 p-3 rounded">
            <?php
            $avant = json_decode($historique['donnees_avant'], true);
            $apres = json_decode($historique['donnees_apres'], true);
            $changements = [];
            
            foreach ($apres as $champ => $nouvelle_valeur) {
                if (isset($avant[$champ]) && $avant[$champ] !== $nouvelle_valeur) {
                    $changements[] = [
                        'champ' => ucfirst(str_replace('_', ' ', $champ)),
                        'avant' => $avant[$champ],
                        'apres' => $nouvelle_valeur
                    ];
                }
            }
            
            if (!empty($changements)) {
                echo "<ul class='mb-0'>";
                foreach ($changements as $changement) {
                    echo "<li><strong>{$changement['champ']}:</strong> ";
                    echo "<span class='text-danger'>" . htmlspecialchars($changement['avant'] ?: 'Vide') . "</span>";
                    echo " → ";
                    echo "<span class='text-success'>" . htmlspecialchars($changement['apres'] ?: 'Vide') . "</span>";
                    echo "</li>";
                }
                echo "</ul>";
            } else {
                echo "<p class='mb-0 text-muted'>Aucun changement détecté.</p>";
            }
            ?>
        </div>
    <?php endif; ?>

<?php endif; ?>

<?php
$html = ob_get_clean();

echo json_encode([
    'success' => true,
    'html' => $html
]);
?>