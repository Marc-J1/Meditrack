<div class="row">
    <div class="col-lg-8 mb-4">
        <div class="card info-card">
            <div class="card-header bg-light">
                <h6 class="mb-0">
                    <i class="fas fa-user-edit me-2"></i>Informations personnelles
                </h6>
            </div>
            <div class="card-body">
                <form id="profileForm" method="POST" action="update_profile.php" enctype="multipart/form-data">
                    <div class="grid grid-cols-12 gap-4">

                        <!-- Nom d'utilisateur / Nom complet -->
                        <div class="col-span-12 md:col-span-6">
                            <div class="card p-4">
                                <label class="font-semibold">Nom d'utilisateur</label>
                                <input type="text" name="username" class="form-control mt-1"
                                    value="<?= htmlspecialchars($is_interimaire ? $user_data['nom_complet'] : $user_data['username']) ?>" required>
                            </div>
                        </div>

                        <!-- Email -->
                        <div class="col-span-12 md:col-span-6">
                            <div class="card p-4">
                                <label class="font-semibold">Email</label>
                                <input type="email" name="email" class="form-control mt-1"
                                    value="<?= htmlspecialchars($user_data['email'] ?? $user_data['mail']) ?>" required>
                            </div>
                        </div>

                        <!-- Téléphone -->
                        <div class="col-span-12 md:col-span-6">
                            <div class="card p-4">
                                <label class="font-semibold">Téléphone</label>
                                <input type="text" name="telephone" class="form-control mt-1"
                                    value="<?= htmlspecialchars($user_data['telephone'] ?? $user_data['phone_number']) ?>">
                            </div>
                        </div>

                        <!-- Adresse -->
                        <div class="col-span-12 md:col-span-6">
                            <div class="card p-4">
                                <label class="font-semibold">Adresse</label>
                                <input type="text" name="adresse" class="form-control mt-1"
                                    value="<?= htmlspecialchars($user_data['adresse'] ?? $user_data['address']) ?>">
                            </div>
                        </div>

                        <!-- Spécialité (si médecin intérimaire) -->
                        <?php if ($is_interimaire): ?>
                        <div class="col-span-12">
                            <div class="card p-4">
                                <label class="font-semibold">Spécialité</label>
                                <input type="text" name="specialite" class="form-control mt-1"
                                    value="<?= htmlspecialchars($user_data['specialite']) ?>">
                            </div>
                        </div>
                        <?php endif; ?>
                    </div>

                    <!-- Boutons -->
                    <div class="text-end mt-4">
                        <button type="button" class="btn btn-secondary me-2" onclick="location.reload()">
                            <i class="fas fa-undo me-1"></i>Annuler
                        </button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save me-1"></i>Enregistrer les modifications
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
