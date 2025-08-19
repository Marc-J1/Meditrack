<?php session_start(); ?> 

<!doctype html>
<html lang="en" data-pc-preset="preset-1" data-pc-sidebar-caption="true" data-pc-direction="ltr" dir="ltr" data-pc-theme="light">
  <head>
    <title>Login | Datta Able Dashboard Template</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="description" content="Datta Able is a dashboard template." />
    <meta name="keywords" content="Bootstrap admin template, Dashboard UI" />
    <meta name="author" content="CodedThemes" />

    <link rel="icon" href="DattaAble-1.0.0\dist\assets\images/logo1.png" type="image/x-icon" />
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@300;400;500;600&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="DattaAble-1.0.0/dist/assets/fonts/phosphor/duotone/style.css" />
    <link rel="stylesheet" href="DattaAble-1.0.0/dist/assets/fonts/tabler-icons.min.css" />
    <link rel="stylesheet" href="DattaAble-1.0.0/dist/assets/fonts/feather.css" />
    <link rel="stylesheet" href="DattaAble-1.0.0/dist/assets/fonts/fontawesome.css" />
    <link rel="stylesheet" href="DattaAble-1.0.0/dist/assets/fonts/material.css" />
   <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <link rel="stylesheet" href="DattaAble-1.0.0/dist/assets/css/style.css" id="main-style-link" />
  </head>

  <body>
    <!-- ✅ TOAST (haut droite) -->
    <?php
    $type_message = '';
    $contenu_message = '';

     if (!empty($_SESSION['login_error'])): ?>
  <div class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 9999;">
    <div id="loginToast" class="toast align-items-center text-bg-danger border-0 show" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="d-flex">
        <div class="toast-body">
          <?= htmlspecialchars($_SESSION['login_error']); ?>
        </div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Fermer"></button>
      </div>
    </div>
  </div>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      var el = document.getElementById('loginToast');
      if (el && window.bootstrap) {
        new bootstrap.Toast(el, { delay: 3000 }).show();
      }
    });
  </script>
  <?php unset($_SESSION['login_error']); ?>
<?php endif; ?>


    <!-- Loader -->
    <div class="loader-bg fixed inset-0 bg-white dark:bg-themedark-cardbg z-[1034]">
      <div class="loader-track h-[5px] w-full absolute top-0">
        <div class="loader-fill w-[300px] h-[5px] bg-primary-500 absolute top-0 left-0 animate-[hitZak_0.6s_ease-in-out_infinite_alternate]"></div>
      </div>
    </div>

    <div class="auth-main relative">
      <div class="auth-wrapper v1 flex items-center w-full h-full min-h-screen">
        <div class="auth-form flex items-center justify-center grow flex-col min-h-screen relative p-6">
          <div class="w-full max-w-[350px] relative">
            <div class="auth-bg">
              <span class="absolute top-[-100px] right-[-100px] w-[300px] h-[300px] block rounded-full bg-theme-bg-1 animate-[floating_7s_infinite]"></span>
              <span class="absolute top-[150px] right-[-150px] w-5 h-5 block rounded-full bg-primary-500 animate-[floating_9s_infinite]"></span>
              <span class="absolute left-[-150px] bottom-[150px] w-5 h-5 block rounded-full bg-theme-bg-1 animate-[floating_7s_infinite]"></span>
              <span class="absolute left-[-100px] bottom-[-100px] w-[300px] h-[300px] block rounded-full bg-theme-bg-2 animate-[floating_9s_infinite]"></span>
            </div>

            <div class="card sm:my-12 w-full shadow-none">
              <div class="card-body !p-10">
                <div class="text-center mb-8">
                  <img src="DattaAble-1.0.0/dist/assets/images/logo1.png" 
                       alt="Logo"
                       style="height: 90px; object-fit: contain;" 
                       class="rounded" />
                </div>
                <h4 class="text-center font-medium mb-4">MediTrack</h4>

                <!-- (on n’affiche plus l’alerte centrale ici, c’est géré par le toast) -->

                <form action="login_handler.php" method="POST">
                  <div class="mb-3">
                    <!-- 🆕 identifiant (et non email) -->
                    <input type="text" name="identifiant" class="form-control" placeholder="Identifiant" required />
                  </div>
                  <div class="mb-4">
                    <input type="password" name="password" class="form-control" placeholder="Mot de passe" required />
                  </div>
                  <div class="flex mt-1 justify-between items-center flex-wrap">
                    <div class="form-check">
                      <input class="form-check-input input-primary" type="checkbox" id="remember" />
                      <label class="form-check-label text-muted" for="remember">Se souvenir de moi</label>
                    </div>
                  </div>
                  <div class="mt-4 text-center">
                    <button type="submit" class="btn btn-primary mx-auto shadow-2xl">Connexion</button>
                  </div>
                </form>

              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <script src="DattaAble-1.0.0/dist/assets/js/plugins/simplebar.min.js"></script>
    <script src="DattaAble-1.0.0/dist/assets/js/plugins/popper.min.js"></script>
    <script src="DattaAble-1.0.0/dist/assets/js/icon/custom-icon.js"></script>
    <script src="DattaAble-1.0.0/dist/assets/js/plugins/feather.min.js"></script>
    <script src="DattaAble-1.0.0/dist/assets/js/component.js"></script>
    <script src="DattaAble-1.0.0/dist/assets/js/theme.js"></script>
    <script src="DattaAble-1.0.0/dist/assets/js/script.js"></script>
  </body>
</html>
