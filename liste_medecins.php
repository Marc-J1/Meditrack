<?php 
session_start();
require_once 'db.php';

if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'admin') {
    header("Location: login.php");
    exit();
}

include 'includes/header.php';
include 'includes/sidebar-admin.php';
?>

<!-- Contenu principal -->
<div class="pc-container">
  <div class="pc-content">
    <div class="page-header">
      <h4 class="mb-3">Liste des Utilisateurs</h4>
    </div>

    <div class="card">
      <div class="card-body">
        <div class="table-responsive">
          <table id="table-medecins" class="table table-hover table-bordered nowrap w-100">
            <thead class="thead-dark">
              <tr>
                <th>ID</th>
                <th>Nom</th>
                <th>mot de passe</th>
                <th>Numéro de téléphone</th>
                <th>Addresse</th>
                <th>Email</th>
                <th>Role</th>
                <th>Statut</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              <?php
              $stmt = $pdo->query("SELECT * FROM users");
              while ($row = $stmt->fetch()) {
                  echo "<tr>
                      <td>{$row['id_utilisateur']}</td>
                      <td>{$row['username']}</td>
                      <td>{$row['password']}</td>
                      <td>{$row['phone_number']}</td>
                      <td>{$row['address']}</td>
                      <td>{$row['mail']}</td>
                      <td>{$row['role']}</td>
                      <td>{$row['statut']}</td>
                      <td>
                        <a href='modifier_medecin.php?id={$row['id_utilisateur']}' class='btn btn-sm btn-primary' title='Modifier'><i class='ti ti-edit'></i></a>
                        <a href='supprimer_medecin.php?id={$row['id_utilisateur']}' class='btn btn-sm btn-danger' title='Supprimer' onclick=\"return confirm('Confirmer la suppression ?');\"><i class='ti ti-trash'></i></a>
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

<!-- Style SweetAlert2 -->
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

<!-- Initialisation DataTable et SweetAlert2 -->
<script>
  $(document).ready(function () {
    const table = $('#table-medecins').DataTable({
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

    // Pop-up succès ou erreur depuis l'URL
    <?php if (isset($_GET['success'])): ?>
    Swal.fire({
      title: 'Succès',
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

    // Confirmation suppression dynamique
    $('.btn-supprimer').on('click', function () {
  const id = $(this).data('id');
  Swal.fire({
    title: 'Supprimer ce médecin ?',
    text: "Cette action est irréversible.",
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Oui, supprimer',
    cancelButtonText: 'Annuler',
    background: '#fff',
    customClass: {
      popup: 'swal2-custom-popup',
      title: 'swal2-custom-title',
      htmlContainer: 'swal2-custom-text'
    }
  }).then((result) => {
    if (result.isConfirmed) {
      window.location.href = 'supprimer_medecin.php?id=' + id;
    }
  });
});

  });
</script>
