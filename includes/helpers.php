<?php
// Helper générique pour afficher Civilité + Nom + Prénom
if (!function_exists('getCiviliteNomPrenom')) {
  function getCiviliteNomPrenom($sexe, $nom, $prenom) {
    $s = strtoupper(trim((string)$sexe));
    $civilite = (in_array($s, ['F', 'FEMME', 'FÉMININ', 'FEMININ'])) ? 'Mme' : 'Ms';
    return trim($civilite . ' ' . $nom . ' ' . $prenom);
  }
}
