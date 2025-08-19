<!-- [ Sidebar Menu ] start -->
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
          <a href="dashboard_medecin.php" class="pc-link">
            <span class="pc-micon"><i data-feather="home"></i></span>
            <span class="pc-mtext">Tableau de Bord</span>
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
  <a href="lister_patients.php" class="pc-link">
    <span class="pc-micon"><i data-feather="list"></i></span>
    <span class="pc-mtext">Lister les patients</span>
  </a>
</li>

<li class="pc-item">
  <a href="historique_consultations.php" class="pc-link">
    <span class="pc-micon"><i data-feather="edit"></i></span>
    <span class="pc-mtext">Historique Medicale</span>
  </a>

</li>
<!-- AJOUTER CE CODE dans la sidebar pour les médecins principaux -->
<?php if (isset($_SESSION['user']['statut']) && $_SESSION['user']['statut'] === 'principal'): ?>
    <li class="pc-item">
        <a href="historique_patients.php" class="pc-link">
            <span class="pc-micon">
                <i class="feather icon-clock"></i>
                <!-- ou utilisez une icône emoji si vous préférez -->
                <!-- 📜 -->
            </span>
            <span class="pc-mtext">Historique Patients</span>
        </a>
    </li>
<?php endif; ?>

<!-- Alternative avec emoji si vous n'avez pas d'icônes Feather -->

<!--
<li class="pc-item">
  <a href="supprimer_patient.php" class="pc-link">
    <span class="pc-micon"><i data-feather="trash-2"></i></span>
    <span class="pc-mtext">Supprimer un patient</span>
  </a>
</li>
-->

<!--
<li class="pc-item pc-caption">
  <label>Ordonnances</label>
</li>
<li class="pc-item">
  <a href="prescrire_ordonance.php" class="pc-link">
    <span class="pc-micon"><i data-feather="file-text"></i></span>
    <span class="pc-mtext">Prescrire une ordonnance</span>
  </a>
</li>
<li class="pc-item">
  <a href="historique_ordonnances.php" class="pc-link">
    <span class="pc-micon"><i data-feather="clock"></i></span>
    <span class="pc-mtext">Historique des ordonnances</span> 
  </a>
</li>

<li class="pc-item pc-caption">
  <label>Gestion des médecins intérimaires</label>
</li>

<li class="pc-item">
  <a href="ajouter_medecin_interimaire.php" class="pc-link">
    <span class="pc-micon"><i data-feather="user-plus"></i></span>
    <span class="pc-mtext">Ajouter un médecin</span>
  </a>
</li>
<li class="pc-item">
  <a href="liste_medecins_interimaire.php" class="pc-link">
    <span class="pc-micon"><i data-feather="list"></i></span>
    <span class="pc-mtext">Liste des médecins</span>
  </a>
</li>
     -->

        <!--
          <li class="pc-item pc-caption">
            <label>Pages</label>
            <i data-feather="monitor"></i>
          </li>
          <li class="pc-item">
            <a href="DattaAble-1.0.0/dist/pages/login-v1.html" class="pc-link" target="_blank">
              <span class="pc-micon"><i data-feather="lock"></i></span>
              <span class="pc-mtext">Login</span>
            </a>
          </li>
        -->
        

        

        
      </ul>
    </div>
  </div>
</nav>
<!-- [ Sidebar Menu ] end -->

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
        
      </ul>
    </div>

    <div class="ms-auto">
      <ul class="inline-flex *:min-h-header-height *:inline-flex *:items-center">
        
        
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
              

              <div class="grid my-3">
                 <a href="mon_compte.php" class="dropdown-item" class="ti ti-user"><span> Mon Compte</span></a>
                 <a href="support.php" class="dropdown-item" class="ti ti-headset"><span> Support</span></a>
                 <a href="changer_mot_de_passe.php" class="dropdown-item"><span>Changer le mot de passe</span></a>
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
