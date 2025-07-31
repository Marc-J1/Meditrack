-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 31, 2025 at 04:32 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `patient_manager`
--

-- --------------------------------------------------------

--
-- Table structure for table `bons_examens`
--

CREATE TABLE `bons_examens` (
  `id` int(11) NOT NULL,
  `id_patient` int(11) NOT NULL,
  `id_utilisateur` int(11) NOT NULL,
  `id_consultation` int(11) NOT NULL,
  `age` int(11) DEFAULT NULL,
  `poids` varchar(10) DEFAULT NULL,
  `service_demandeur` text DEFAULT NULL,
  `renseignement_clinique` text DEFAULT NULL,
  `date_creation` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chat_messages`
--

CREATE TABLE `chat_messages` (
  `id_message` int(11) NOT NULL,
  `id_utilisateur` int(11) NOT NULL,
  `message` text NOT NULL,
  `date_message` datetime DEFAULT current_timestamp(),
  `statut` enum('lu','non_lu') DEFAULT 'non_lu',
  `type_message` enum('text','system') DEFAULT 'text'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chat_message_read`
--

CREATE TABLE `chat_message_read` (
  `id_read` int(11) NOT NULL,
  `id_message` int(11) NOT NULL,
  `id_utilisateur` int(11) NOT NULL,
  `date_lecture` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `consultation`
--

CREATE TABLE `consultation` (
  `id` int(11) NOT NULL,
  `id_patient` int(11) NOT NULL,
  `date_consultation` datetime NOT NULL,
  `motif` text DEFAULT NULL,
  `diagnostic` text DEFAULT NULL,
  `statut` enum('programmee','en_cours','terminee') DEFAULT 'programmee',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `consultations`
--

CREATE TABLE `consultations` (
  `id` int(11) NOT NULL,
  `id_patient` int(11) NOT NULL,
  `id_utilisateur` int(11) NOT NULL,
  `date_consultation` datetime NOT NULL,
  `motif` text DEFAULT NULL,
  `diagnostic` text DEFAULT NULL,
  `statut` enum('programmee','en_cours','terminee') DEFAULT 'programmee',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `consultations`
--

INSERT INTO `consultations` (`id`, `id_patient`, `id_utilisateur`, `date_consultation`, `motif`, `diagnostic`, `statut`, `notes`, `created_at`) VALUES
(24, 37, 2, '2025-07-25 12:24:00', 'Est tombé sur du béton', 'Fracture au pied', 'terminee', 'ça va aller', '2025-07-25 10:25:10'),
(37, 41, 2, '2025-07-29 13:40:00', 'Malade', 'Faim', 'terminee', NULL, '2025-07-29 11:42:05'),
(38, 43, 2, '2025-07-29 19:16:00', 'jyynènjyè', 'yyb', 'programmee', NULL, '2025-07-29 17:16:32');

-- --------------------------------------------------------

--
-- Table structure for table `medecins`
--

CREATE TABLE `medecins` (
  `id_medecin` int(11) NOT NULL,
  `nom_complet` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `mot_de_passe` varchar(255) NOT NULL,
  `specialite` varchar(100) DEFAULT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `adresse` varchar(255) DEFAULT NULL,
  `statut` enum('principal','interimaire') NOT NULL DEFAULT 'interimaire',
  `date_creation` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `observations`
--

CREATE TABLE `observations` (
  `id` int(11) NOT NULL,
  `id_patient` int(11) NOT NULL,
  `id_utilisateur` int(11) DEFAULT NULL,
  `id_consultation` int(11) DEFAULT NULL,
  `type_observation` enum('Suivi','Diagnostic','Note') DEFAULT 'Suivi',
  `contenu` text NOT NULL,
  `date_observation` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `observations`
--

INSERT INTO `observations` (`id`, `id_patient`, `id_utilisateur`, `id_consultation`, `type_observation`, `contenu`, `date_observation`) VALUES
(23, 37, 2, NULL, 'Suivi', 'Apparemment ça ne va pas hein', '2025-07-25 11:26:47');

-- --------------------------------------------------------

--
-- Table structure for table `ordonnances`
--

CREATE TABLE `ordonnances` (
  `id` int(11) NOT NULL,
  `id_patient` int(11) NOT NULL,
  `id_utilisateur` int(11) DEFAULT NULL,
  `date_ordonnance` datetime NOT NULL DEFAULT current_timestamp(),
  `medicaments` text NOT NULL,
  `posologie` text DEFAULT NULL,
  `duree_traitement` varchar(100) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `statut` enum('active','suspendue','terminee') DEFAULT 'active',
  `id_consultation` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ordonnances`
--

INSERT INTO `ordonnances` (`id`, `id_patient`, `id_utilisateur`, `date_ordonnance`, `medicaments`, `posologie`, `duree_traitement`, `notes`, `statut`, `id_consultation`) VALUES
(31, 36, 2, '2025-07-24 17:17:16', 'fhdhr', 'dh', 'gdfh', 'dfhr', 'active', NULL),
(33, 36, 2, '2025-07-25 08:07:22', 'tru', 'uetyj', 'reuyt', 'yjetyj', 'terminee', NULL),
(35, 37, 2, '2025-07-25 11:26:05', 'Paracétamol 200mg', '1 comprimé 3 fois par jours', '7jours', 'Mange avant', 'active', NULL),
(36, 37, 2, '2025-07-25 11:27:49', '1 paracétamole', '3 fois par jours', '7 jours', 'efef', 'active', 24),
(45, 41, 2, '2025-07-29 12:45:50', 'njc,cykg,vh\r\nwtvfynyngycy nc,n\r\nxnhuc,ki;h;ib,;ol', 'byhxb vutx,;-nuuyi\r\nbndhbut; uicy,i,;ui;bho\r\nxnbcu,yi,;uo;ugo;uio', '26256', '\',xtr;d-y_,èk_i;ldftèçtèçtèçtèçtèçtèçkèç-', 'active', NULL),
(46, 43, 2, '2025-07-29 18:16:54', 'th-by', 'tythb', 'buèb', 'thbh-t', 'active', 38);

-- --------------------------------------------------------

--
-- Table structure for table `patients`
--

CREATE TABLE `patients` (
  `id_patient` int(11) NOT NULL,
  `nom` varchar(50) NOT NULL,
  `prenom` varchar(50) NOT NULL,
  `sexe` enum('Homme','Femme') NOT NULL,
  `date_naissance` date NOT NULL,
  `loisirs` text DEFAULT NULL,
  `divers` text DEFAULT NULL,
  `antecedents_medicaux` text DEFAULT NULL,
  `chirurgicaux` text DEFAULT NULL,
  `familiaux` text DEFAULT NULL,
  `mentions_particulieres` text DEFAULT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `profession` varchar(100) DEFAULT NULL,
  `poids` decimal(5,2) DEFAULT NULL,
  `taille` decimal(5,2) DEFAULT NULL,
  `id_utilisateur` int(11) DEFAULT NULL,
  `date_creation` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `patients`
--

INSERT INTO `patients` (`id_patient`, `nom`, `prenom`, `sexe`, `date_naissance`, `loisirs`, `divers`, `antecedents_medicaux`, `chirurgicaux`, `familiaux`, `mentions_particulieres`, `telephone`, `profession`, `poids`, `taille`, `id_utilisateur`, `date_creation`) VALUES
(36, 'premier', 'Achera', 'Homme', '1009-09-20', 'H', 'UYF', 'HG', 'JGC', 'KHG', 'JB JG', '0749068795', 'Artiste', 45.00, 6.00, 2, '2025-07-29 10:37:40'),
(37, 'Ngoy', 'Luck', 'Homme', '2009-07-20', 'Foot, piano, jeux viedeo', 'Auncun', 'Aucun', 'Auncun', 'Aucun', 'N\'aimes pas l\'eau', '05338896517', 'Eleve', 67.00, 1.76, 2, '2025-07-29 10:37:40'),
(40, 'Obana', 'Gerard', 'Homme', '2002-08-20', 'Foot, piano, jeux viedeo', 'manger', 'Aucun', 'Aucun', 'Aucun', 'Aucun', '05338896517', 'Prof d\'anglais', 60.00, 1.91, 2, '2025-07-29 10:37:40'),
(41, 'GOALA ALY', 'Farild S.', 'Homme', '2000-07-29', 'Biere', 'Femme', 'RAS', 'RAS', 'RAS', 'RAS', '66626555955945', 'jvkfvfvftfftvtfvkgi', 999.99, 999.99, 2, '2025-07-29 12:28:31'),
(43, 'N\'KOUNKOU', 'Dysthel Prince Heritier', '', '2000-07-30', 'Vin, femme, decouchement', '', 'RAS', 'RASj', 'RASs', 'RAS', '2466828222', 'bntnyntyndbyydt', 999.99, 1.00, 2, '2025-07-29 12:31:40');

-- --------------------------------------------------------

--
-- Table structure for table `patients_history`
--

CREATE TABLE `patients_history` (
  `id` int(11) NOT NULL,
  `id_patient` int(11) NOT NULL,
  `action` enum('création','modification','consultation') NOT NULL,
  `date_action` datetime DEFAULT current_timestamp(),
  `commentaire` text DEFAULT NULL,
  `id_utilisateur` int(11) DEFAULT NULL,
  `id_medecin` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `patients_history`
--

INSERT INTO `patients_history` (`id`, `id_patient`, `action`, `date_action`, `commentaire`, `id_utilisateur`, `id_medecin`) VALUES
(21, 40, 'modification', '2025-07-28 13:47:47', 'Modification des informations du patient', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `patient_utilisateur`
--

CREATE TABLE `patient_utilisateur` (
  `id_utilisateur` int(11) NOT NULL,
  `id_patient` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `support_messages`
--

CREATE TABLE `support_messages` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `destinataire` varchar(255) NOT NULL,
  `sujet` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `date_envoi` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `support_messages`
--

INSERT INTO `support_messages` (`id`, `email`, `destinataire`, `sujet`, `message`, `date_envoi`) VALUES
(1, 'dr.martin@clinic.cg', 'marckampakol2002@gmail.com', 'Probleme de test', 'alors est ce que ça foncyionne', '2025-07-30 13:51:54'),
(2, 'dr.martin@clinic.cg', 'marckampakol2002@gmail.com', 'Probleme de test', 'alors est ce que ça foncyionne', '2025-07-30 13:51:56'),
(3, 'marcjeremykampakol@gmail.com', 'marckampakol2002@gmail.com', 'Probleme de test', 'LKSDHFKUHZD', '2025-07-30 13:54:34');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id_utilisateur` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `mail` varchar(100) DEFAULT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `role` varchar(30) DEFAULT NULL,
  `statut` enum('principal','interimaire') DEFAULT 'interimaire',
  `date_creation` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id_utilisateur`, `username`, `password`, `phone_number`, `address`, `mail`, `photo`, `role`, `statut`, `date_creation`) VALUES
(1, 'admin', '$2y$10$t2rOumjgB73R6cx6vw02V.8da2bYUGb8MlJqeqhj3mIVJsV0QX10W', '+242 06 123 4567', 'Centre-ville Brazzaville', 'admin@clinic.cg', NULL, 'admin', '', '2025-07-23 10:53:30'),
(2, 'dr_martin', 'martin123', '+242 06 234 5679', '33 rue mbochis', 'dr.martin@clinic.cg', '2_1753866046.jpeg', 'medecin', 'principal', '2025-07-23 10:53:30'),
(18, 'Marc-Antoine', '$2y$10$o6.MtENkTdS4YJGdkT1/ruNzpAYvwd85rcsZcaqYErNN1RPybVT5C', '0644989426', 'Rue de la brioche', 'marckampakol2002@gmail.com', NULL, 'medecin', 'interimaire', '2025-07-23 11:33:02'),
(20, 'Jojo', 'jeremy242', '05338896517', 'Ismet asim court No 1', 'marcjeremykampakol@gmail.com', NULL, 'medecin', 'interimaire', '2025-07-23 16:28:43');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bons_examens`
--
ALTER TABLE `bons_examens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_patient` (`id_patient`),
  ADD KEY `id_utilisateur` (`id_utilisateur`),
  ADD KEY `id_consultation` (`id_consultation`);

--
-- Indexes for table `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD PRIMARY KEY (`id_message`),
  ADD KEY `idx_chat_messages_date` (`date_message`),
  ADD KEY `idx_chat_messages_user` (`id_utilisateur`);

--
-- Indexes for table `chat_message_read`
--
ALTER TABLE `chat_message_read`
  ADD PRIMARY KEY (`id_read`),
  ADD UNIQUE KEY `unique_user_message` (`id_message`,`id_utilisateur`),
  ADD KEY `idx_chat_read_user` (`id_utilisateur`);

--
-- Indexes for table `consultation`
--
ALTER TABLE `consultation`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_patient` (`id_patient`);

--
-- Indexes for table `consultations`
--
ALTER TABLE `consultations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `consultations_ibfk_1` (`id_patient`);

--
-- Indexes for table `medecins`
--
ALTER TABLE `medecins`
  ADD PRIMARY KEY (`id_medecin`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `observations`
--
ALTER TABLE `observations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_utilisateur` (`id_utilisateur`),
  ADD KEY `observations_ibfk_1` (`id_patient`);

--
-- Indexes for table `ordonnances`
--
ALTER TABLE `ordonnances`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ordonnances_ibfk_1` (`id_patient`);

--
-- Indexes for table `patients`
--
ALTER TABLE `patients`
  ADD PRIMARY KEY (`id_patient`),
  ADD KEY `fk_patient_utilisateur` (`id_utilisateur`);

--
-- Indexes for table `patients_history`
--
ALTER TABLE `patients_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_history_utilisateur` (`id_utilisateur`),
  ADD KEY `fk_history_medecin` (`id_medecin`),
  ADD KEY `fk_history_patient` (`id_patient`);

--
-- Indexes for table `patient_utilisateur`
--
ALTER TABLE `patient_utilisateur`
  ADD PRIMARY KEY (`id_utilisateur`,`id_patient`),
  ADD KEY `id_patient` (`id_patient`);

--
-- Indexes for table `support_messages`
--
ALTER TABLE `support_messages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id_utilisateur`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `mail` (`mail`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bons_examens`
--
ALTER TABLE `bons_examens`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `chat_messages`
--
ALTER TABLE `chat_messages`
  MODIFY `id_message` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `chat_message_read`
--
ALTER TABLE `chat_message_read`
  MODIFY `id_read` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `consultation`
--
ALTER TABLE `consultation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `consultations`
--
ALTER TABLE `consultations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `medecins`
--
ALTER TABLE `medecins`
  MODIFY `id_medecin` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `observations`
--
ALTER TABLE `observations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `ordonnances`
--
ALTER TABLE `ordonnances`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT for table `patients`
--
ALTER TABLE `patients`
  MODIFY `id_patient` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT for table `patients_history`
--
ALTER TABLE `patients_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `support_messages`
--
ALTER TABLE `support_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id_utilisateur` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bons_examens`
--
ALTER TABLE `bons_examens`
  ADD CONSTRAINT `bons_examens_ibfk_1` FOREIGN KEY (`id_patient`) REFERENCES `patients` (`id_patient`),
  ADD CONSTRAINT `bons_examens_ibfk_2` FOREIGN KEY (`id_utilisateur`) REFERENCES `users` (`id_utilisateur`),
  ADD CONSTRAINT `bons_examens_ibfk_3` FOREIGN KEY (`id_consultation`) REFERENCES `consultations` (`id`);

--
-- Constraints for table `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD CONSTRAINT `chat_messages_ibfk_1` FOREIGN KEY (`id_utilisateur`) REFERENCES `users` (`id_utilisateur`) ON DELETE CASCADE;

--
-- Constraints for table `chat_message_read`
--
ALTER TABLE `chat_message_read`
  ADD CONSTRAINT `chat_message_read_ibfk_1` FOREIGN KEY (`id_message`) REFERENCES `chat_messages` (`id_message`) ON DELETE CASCADE,
  ADD CONSTRAINT `chat_message_read_ibfk_2` FOREIGN KEY (`id_utilisateur`) REFERENCES `users` (`id_utilisateur`) ON DELETE CASCADE;

--
-- Constraints for table `consultation`
--
ALTER TABLE `consultation`
  ADD CONSTRAINT `consultation_ibfk_1` FOREIGN KEY (`id_patient`) REFERENCES `patients` (`id_patient`);

--
-- Constraints for table `consultations`
--
ALTER TABLE `consultations`
  ADD CONSTRAINT `consultations_ibfk_1` FOREIGN KEY (`id_patient`) REFERENCES `patients` (`id_patient`) ON DELETE CASCADE;

--
-- Constraints for table `observations`
--
ALTER TABLE `observations`
  ADD CONSTRAINT `observations_ibfk_1` FOREIGN KEY (`id_patient`) REFERENCES `patients` (`id_patient`) ON DELETE CASCADE,
  ADD CONSTRAINT `observations_ibfk_2` FOREIGN KEY (`id_utilisateur`) REFERENCES `users` (`id_utilisateur`) ON DELETE SET NULL;

--
-- Constraints for table `ordonnances`
--
ALTER TABLE `ordonnances`
  ADD CONSTRAINT `ordonnances_ibfk_1` FOREIGN KEY (`id_patient`) REFERENCES `patients` (`id_patient`) ON DELETE CASCADE;

--
-- Constraints for table `patients`
--
ALTER TABLE `patients`
  ADD CONSTRAINT `fk_patient_utilisateur` FOREIGN KEY (`id_utilisateur`) REFERENCES `users` (`id_utilisateur`) ON DELETE SET NULL;

--
-- Constraints for table `patients_history`
--
ALTER TABLE `patients_history`
  ADD CONSTRAINT `fk_history_medecin` FOREIGN KEY (`id_medecin`) REFERENCES `medecins` (`id_medecin`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_history_patient` FOREIGN KEY (`id_patient`) REFERENCES `patients` (`id_patient`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_history_utilisateur` FOREIGN KEY (`id_utilisateur`) REFERENCES `users` (`id_utilisateur`) ON DELETE SET NULL;

--
-- Constraints for table `patient_utilisateur`
--
ALTER TABLE `patient_utilisateur`
  ADD CONSTRAINT `patient_utilisateur_ibfk_1` FOREIGN KEY (`id_utilisateur`) REFERENCES `users` (`id_utilisateur`) ON DELETE CASCADE,
  ADD CONSTRAINT `patient_utilisateur_ibfk_2` FOREIGN KEY (`id_patient`) REFERENCES `patients` (`id_patient`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
