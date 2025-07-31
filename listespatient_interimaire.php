<?php
session_start();
require_once 'db.php';

if (!isset($_SESSION['user']) || 
   ($_SESSION['user']['role'] !== 'medecin_interimaire')) {
    header("Location: login.php");
    exit();
}

include 'includes/header.php';
include 'includes/sidebar-interimaire.php';
?>

<!-- Contenu principal -->
<div class="pc-container">
  <div class="pc-content">
    <div class="page-header">
      <h4 class="mb-3">Liste des Patients</h4>
    </div>

    <div class="card">
      <div class="card-body">
        <div class="table-responsive">
          <table id="table-patients" class="table table-hover table-bordered nowrap w-100">
            <thead class="thead-dark">
              <tr>
                <th>ID</th>
                <th>Nom</th>
                <th>Prénom</th>
                <th>Sexe</th>
                <th>Date de Naissance</th>
                <th>Âge</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <?php
              $stmt = $pdo->prepare("SELECT * FROM patients WHERE id_utilisateur = ?");
              $stmt->execute([$_SESSION['user']['id']]);

              while ($row = $stmt->fetch()) {
                  // Calculer l'âge
                  $date_naissance = new DateTime($row['date_naissance']);
                  $aujourd_hui = new DateTime();
                  $age = $aujourd_hui->diff($date_naissance)->y;
                  
                  echo "<tr>
                      <td>{$row['id_patient']}</td>
                      <td>{$row['nom']}</td>
                      <td>{$row['prenom']}</td>
                      <td>{$row['sexe']}</td>
                      <td>" . date('d/m/Y', strtotime($row['date_naissance'])) . "</td>
                      <td>{$age} ans</td>
                      <td>
                        <a href='detailspatient_interimaire.php?id={$row['id_patient']}' class='btn btn-sm btn-success' title='Voir détails complets'><i class='ti ti-eye'></i> Détails</a>
                        <a href='modifier_patient.php?id={$row['id_patient']}' class='btn btn-sm btn-primary' title='Modifier'><i class='ti ti-edit'></i></a>
                        <a href='supprimer_patient.php?id={$row['id_patient']}' class='btn btn-sm btn-danger' title='Supprimer' onclick=\"return confirm('Confirmer la suppression ?');\"><i class='ti ti-trash'></i></a>
                      </td>
                  </tr>";
              }
              ?>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

<?php include 'includes/footer.php'; ?>

<!-- DataTables CSS & JS -->
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css">
<link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.dataTables.min.css">
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/responsive/2.5.0/js/dataTables.responsive.min.js"></script>

<!-- SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<!-- SweetAlert2 Custom Style -->
<style>
  .swal2-custom-popup {
    width: 350px !important;
    padding: 1.5rem 1.5rem !important;
    font-size: 16px !important;
    border-radius: 8px !important;
  }

  .swal2-custom-title {
    font-size: 20px !important;
    margin-bottom: 10px !important;
  }

  .swal2-custom-text {
    font-size: 16px !important;
  }

  .swal2-confirm {
    padding: 6px 24px !important;
    font-size: 14px !important;
  }
</style>

<!-- Script d'initialisation + alertes -->
<script>
  $(document).ready(function () {
    const table = $('#table-patients').DataTable({
      responsive: true,
      language: {
        url: "//cdn.datatables.net/plug-ins/1.13.6/i18n/fr-FR.json"
      }
    });

    function redrawTable() {
      setTimeout(() => {
        table.columns.adjust().responsive.recalc();
      }, 400);
    }

    $('#sidebar-hide, #mobile-collapse').on('click', redrawTable);
    window.addEventListener("resize", redrawTable);

    // Affichage des alertes success ou error via GET
    <?php if (isset($_GET['success'])): ?>
      Swal.fire({
        title: 'Message',
        text: '<?= htmlspecialchars($_GET['success']) ?>',
        icon: 'success',
        confirmButtonText: 'OK',
        background: '#000',
        color: '#fff',
        confirmButtonColor: '#4da6ff',
        customClass: {
          popup: 'swal2-custom-popup',
          title: 'swal2-custom-title',
          htmlContainer: 'swal2-custom-text'
        }
      });
    <?php elseif (isset($_GET['error'])): ?>
      Swal.fire({
        title: 'Erreur',
        text: '<?= htmlspecialchars($_GET['error']) ?>',
        icon: 'error',
        confirmButtonText: 'OK',
        background: '#000',
        color: '#fff',
        confirmButtonColor: '#e74c3c',
        customClass: {
          popup: 'swal2-custom-popup',
          title: 'swal2-custom-title',
          htmlContainer: 'swal2-custom-text'
        }
      });
    <?php endif; ?>
  });
</script>