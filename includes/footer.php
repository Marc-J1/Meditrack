<footer class="pc-footer">
  <div class="footer-wrapper container-fluid mx-10">
    <div class="grid grid-cols-12 gap-1.5">
      <div class="col-span-12 sm:col-span-6 my-1">
        <p class="m-0">
          <a href="https://codedthemes.com/" target="_blank">CodedThemes</a>, Built with ♥
        </p>
      </div>
      <div class="col-span-12 sm:col-span-6 my-1 justify-self-end">
        <p class="inline-block max-sm:mr-3 sm:ml-2">Distributed by <a href="https://themewagon.com" target="_blank">Themewagon</a></p>
      </div>
    </div>
  </div>
</footer>

<!-- Required JS -->
<script src="DattaAble-1.0.0/dist/assets/js/plugins/simplebar.min.js"></script>
<script src="DattaAble-1.0.0/dist/assets/js/plugins/popper.min.js"></script>
<script src="DattaAble-1.0.0/dist/assets/js/icon/custom-icon.js"></script>
<script src="DattaAble-1.0.0/dist/assets/js/plugins/feather.min.js"></script>
<script src="DattaAble-1.0.0/dist/assets/js/component.js"></script>
<script src="DattaAble-1.0.0/dist/assets/js/theme.js"></script>
<script src="DattaAble-1.0.0/dist/assets/js/script.js"></script>

<!-- ✅ Bootstrap 5 JS Bundle (inclut Popper) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-QD6B8LpxXPZSv3uPAqAH1FeRaKIOlNsP8rNcZryiE+G9DfihvTQF3upFz3KJjG3C" crossorigin="anonymous"></script>

<script>
  layout_change('false');
  layout_theme_sidebar_change('dark');
  change_box_container('false');
  layout_caption_change('true');
  layout_rtl_change('false');
  preset_change('preset-1');
  main_layout_change('vertical');
</script>
<script>
  document.addEventListener('DOMContentLoaded', function () {
    const toastEl = document.getElementById('welcomeToast');
    if (toastEl) {
      const toast = new bootstrap.Toast(toastEl);
      toast.show();
    }
  });
</script>
<script>
  document.addEventListener('DOMContentLoaded', function () {
    const btn = document.getElementById('sidebar-hide');
    if (btn) {
      btn.addEventListener('click', function (e) {
        e.preventDefault();
        document.body.classList.toggle('pc-sidebar-hide');
      });
    }
  });
</script>
<script>
  document.addEventListener('DOMContentLoaded', function () {
    const desktopBtn = document.getElementById('sidebar-hide');
    const mobileBtn = document.getElementById('mobile-collapse');

    const toggleSidebar = function (e) {
      e.preventDefault();
      document.body.classList.toggle('pc-sidebar-hide');
    };

    if (desktopBtn) {
      desktopBtn.addEventListener('click', toggleSidebar);
    }

    if (mobileBtn) {
      mobileBtn.addEventListener('click', toggleSidebar);
    }
  });
</script>


</body>
</html>