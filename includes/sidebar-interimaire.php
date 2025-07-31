<!-- [ Sidebar Menu Médecin Intérimaire ] start -->
<nav class="pc-sidebar">
  <div class="navbar-wrapper">
    <div class="m-header flex items-center justify-center py-4 px-6 h-header-height">
  <a href="dashboard_admin.php" class="b-brand flex items-center gap-3">
    <img src="DattaAble-1.0.0/dist/assets/images/logo1.png" 
         alt="Logo"
         style="height: 60px; object-fit: contain;" 
         class="rounded" />
  </a>
</div>

    
    <div class="navbar-content h-[calc(100vh_-_74px)] py-2.5">
      <ul class="pc-navbar">
        <li class="pc-item pc-caption">
          <label>Navigation</label>
        </li>

        <li class="pc-item">
          <a href="dashboard_interimaire.php" class="pc-link">
            <span class="pc-micon"><i data-feather="home"></i></span>
            <span class="pc-mtext">Tableau de bord</span>
          </a>
        </li>

        <li class="pc-item pc-caption">
          <label>Gestion des patients</label>
        </li>

        <li class="pc-item">
          <a href="ajouter_patient.php" class="pc-link">
            <span class="pc-micon"><i data-feather="user-plus"></i></span>
            <span class="pc-mtext">Ajouter un patient</span>
          </a>
        </li>

        <li class="pc-item">
          <a href="listespatient_interimaire.php" class="pc-link">
            <span class="pc-micon"><i data-feather="users"></i></span>
            <span class="pc-mtext">Liste des patients</span>
          </a>
        </li>

       
      
        <li class="pc-item pc-caption">
          <label>Compte</label>
        </li>

        <li class="pc-item">
          <a href="logout.php" class="pc-link">
            <span class="pc-micon"><i data-feather="log-out"></i></span>
            <span class="pc-mtext">Déconnexion</span>
          </a>
        </li>
      </ul>
    </div>
  </div>
</nav>
<!-- [ Sidebar Menu Médecin Intérimaire ] end -->
 <!-- [ Header Topbar ] start -->
<header class="pc-header">
  <div class="header-wrapper flex max-sm:px-[15px] px-[25px] grow">
    <div class="me-auto pc-mob-drp">
      <ul class="inline-flex *:min-h-header-height *:inline-flex *:items-center">
        <li class="pc-h-item pc-sidebar-collapse max-lg:hidden lg:inline-flex">
          <a href="#" class="pc-head-link ltr:!ml-0 rtl:!mr-0" id="sidebar-hide">
            <i data-feather="menu"></i>
          </a>
        </li>
        <li class="pc-h-item pc-sidebar-popup lg:hidden">
          <a href="#" class="pc-head-link ltr:!ml-0 rtl:!mr-0" id="mobile-collapse">
            <i data-feather="menu"></i>
          </a>
        </li>
        <li class="dropdown pc-h-item">
          <a class="pc-head-link dropdown-toggle me-0" data-pc-toggle="dropdown" href="#" role="button">
            <i data-feather="search"></i>
          </a>
          <div class="dropdown-menu pc-h-dropdown drp-search">
            <form class="px-2 py-1">
              <input type="search" class="form-control !border-0 !shadow-none" placeholder="Search here..." />
            </form>
          </div>
        </li>
      </ul>
    </div>

    <div class="ms-auto">
      <ul class="inline-flex *:min-h-header-height *:inline-flex *:items-center">
        <li class="dropdown pc-h-item">
          <a class="pc-head-link dropdown-toggle me-0" data-pc-toggle="dropdown" href="#" role="button">
            <i data-feather="sun"></i>
          </a>
          <div class="dropdown-menu dropdown-menu-end pc-h-dropdown">
            <a href="#!" class="dropdown-item" onclick="layout_change('dark')"><i data-feather="moon"></i> Dark</a>
            <a href="#!" class="dropdown-item" onclick="layout_change('light')"><i data-feather="sun"></i> Light</a>
            <a href="#!" class="dropdown-item" onclick="layout_change_default()"><i data-feather="settings"></i> Default</a>
          </div>
        </li>
        <li class="dropdown pc-h-item">
          <a class="pc-head-link dropdown-toggle me-0" data-pc-toggle="dropdown" href="#" role="button">
            <i data-feather="settings"></i>
          </a>
          <div class="dropdown-menu dropdown-menu-end pc-h-dropdown">
            <a href="#!" class="dropdown-item"><i class="ti ti-user"></i> Mon Compte</a>
            <a href="#!" class="dropdown-item"><i class="ti ti-settings"></i> Paramètres</a>
            <a href="#!" class="dropdown-item"><i class="ti ti-headset"></i> Support</a>
            <a href="#!" class="dropdown-item"><i class="ti ti-lock"></i> Verrouiller</a>
            <a href="logout.php" class="dropdown-item"><i class="ti ti-power"></i> Déconnexion</a>
          </div>
        </li>
        <li class="dropdown pc-h-item header-user-profile">
          <a class="pc-head-link dropdown-toggle arrow-none me-0" data-pc-toggle="dropdown" href="#" role="button">
            <i data-feather="user"></i>
          </a>
          <div class="dropdown-menu dropdown-user-profile dropdown-menu-end pc-h-dropdown p-2">
            <div class="dropdown-header flex items-center justify-between py-4 px-5 bg-primary-500">
              <div class="flex mb-1 items-center">
                <div class="shrink-0">
                  <img src="DattaAble-1.0.0/dist/assets/images/user/avatar-2.jpg" alt="user-image" class="w-10 rounded-full" />
                </div>
                <div class="grow ms-3">
                  <h6 class="mb-1 text-white"><?= $_SESSION['user']['username'] ?? 'Utilisateur' ?></h6>
                  <span class="text-white">Médecin</span>
                </div>
              </div>
            </div>
            <div class="dropdown-body py-4 px-5">
              <a href="#!" class="dropdown-item"><span>Paramètres</span></a>
              <a href="changer_mot_de_passe.php" class="dropdown-item"><span>Changer le mot de passe</span></a>
              <div class="grid my-3">
                <a href="logout.php" class="btn btn-primary flex items-center justify-center">
                  <i class="ti ti-power me-2"></i> Déconnexion
                </a>
              </div>
            </div>
          </div>
        </li>
      </ul>
    </div>
  </div>
</header>
<!-- [ Header Topbar ] end -->

