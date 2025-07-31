<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
?>
<!doctype html>

<html lang="fr" data-pc-preset="preset-1" data-pc-sidebar-caption="true" data-pc-direction="ltr" dir="ltr" data-pc-theme="light">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <title>Admin Dashboard</title>
  <link rel="icon" href="DattaAble-1.0.0/dist/assets/images/favicon.svg" type="image/x-icon" />
<link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@300;400;500;600&display=swap" rel="stylesheet" />

  <!-- Icon Fonts -->
  <link rel="stylesheet" href="DattaAble-1.0.0/dist/assets/fonts/phosphor/duotone/style.css" />
  <link rel="stylesheet" href="DattaAble-1.0.0/dist/assets/fonts/tabler-icons.min.css" />
  <link rel="stylesheet" href="DattaAble-1.0.0/dist/assets/fonts/feather.css" />
  <link rel="stylesheet" href="DattaAble-1.0.0/dist/assets/fonts/fontawesome.css" />
  <link rel="stylesheet" href="DattaAble-1.0.0/dist/assets/fonts/material.css" />

  <!-- Main Template CSS -->
  <link rel="stylesheet" href="DattaAble-1.0.0/dist/assets/css/style.css" />

  <!-- ✅ Bootstrap 5 CSS (ajouté) -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1CmrxMRARb6aLqgBO7+Ilz47DkrLJYlFtvnvhDpAdWvM+vNbd9H/z0U8nEJXxK/r" crossorigin="anonymous">

</head>
<body>

<!-- ✅ Bootstrap 5 JS Bundle (à placer avant la fermeture du body dans includes/footer.php si tu en as un) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-QD6B8LpxXPZSv3uPAqAH1FeRaKIOlNsP8rNcZryiE+G9DfihvTQF3upFz3KJjG3C" crossorigin="anonymous"></script>
<!-- ✅ jQuery (obligatoire pour DataTables) -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<!-- ✅ DataTables Core CSS/JS -->
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>

<!-- DataTables Buttons -->
<script src="https://cdn.datatables.net/buttons/2.4.1/js/dataTables.buttons.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.html5.min.js"></script>
<link rel="stylesheet" href="https://cdn.datatables.net/buttons/2.4.1/css/buttons.dataTables.min.css">