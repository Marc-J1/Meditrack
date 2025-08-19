-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 14, 2025 at 09:38 AM
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

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CleanOldActivityData` ()   BEGIN
    -- Nettoyer les activités de plus de 6 mois
    DELETE FROM user_activity WHERE date_action < DATE_SUB(NOW(), INTERVAL 6 MONTH);
    
    -- Nettoyer les sessions expirées de plus de 1 mois
    DELETE FROM user_sessions WHERE statut_session != 'active' AND derniere_activite < DATE_SUB(NOW(), INTERVAL 1 MONTH);
    
    -- Marquer les sessions inactives depuis plus de 24h comme expirées
    UPDATE user_sessions 
    SET statut_session = 'expiree' 
    WHERE statut_session = 'active' 
    AND derniere_activite < DATE_SUB(NOW(), INTERVAL 24 HOUR);
END$$

DELIMITER ;

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

--
-- Dumping data for table `bons_examens`
--

INSERT INTO `bons_examens` (`id`, `id_patient`, `id_utilisateur`, `id_consultation`, `age`, `poids`, `service_demandeur`, `renseignement_clinique`, `date_creation`) VALUES
(5, 44, 2, 39, 26, '67.00', 'Docteur Martin', 'Radio ou echographie de son estomac pour voir s\'il y\'a des complication grave', '2025-08-01 09:33:46'),
(9, 48, 2, 44, 21, '80.00', 'dfg', 'dfgdf', '2025-08-01 13:20:42'),
(14, 44, 2, 53, 26, '67.00', 'svs', 'sfvd', '2025-08-08 09:02:00'),
(15, 44, 2, 53, 26, '67.00', 'df', 'dsfs', '2025-08-08 09:05:30'),
(16, 60, 42, 54, 25, '30.00', 'Méédecine générale', 'GERH\r\nNumération...', '2025-08-08 10:28:55'),
(17, 61, 20, 55, 22, '72.00', 'Je ne sais pas', 'Radio je pense', '2025-08-08 11:08:33'),
(18, 48, 2, 44, 21, '80.00', 'dsf', 'sdfsd', '2025-08-08 14:46:01'),
(19, 48, 2, 44, 21, '80.00', NULL, 'dsfsd', '2025-08-08 14:47:50');

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
(39, 44, 2, '2025-08-01 11:31:00', 'A tres mal au ventre', 'Je pense que c\'est du a une colopathie et une accumulation de ver ', 'terminee', NULL, '2025-08-01 09:32:54'),
(44, 48, 2, '2025-08-01 15:17:00', 'Mal au dos', 'Torsion', 'terminee', 'fdfe', '2025-08-01 13:18:53'),
(49, 44, 2, '2025-08-08 10:14:00', 'sddf', 'sfgd', 'programmee', 'vf', '2025-08-08 08:14:57'),
(50, 44, 2, '2025-08-08 10:18:00', 'dvsfv', 'dfvdf', 'terminee', 'dfbd', '2025-08-08 08:18:24'),
(51, 44, 2, '2025-08-08 10:18:00', 'sdvs', 'sv', 'terminee', 'sdvs', '2025-08-08 08:19:00'),
(52, 44, 2, '2025-08-08 10:24:00', 'fdd', 'dfg', 'terminee', 'dfgd', '2025-08-08 08:24:58'),
(53, 44, 2, '2025-08-08 10:25:00', 'fdg', 'dfgd', 'en_cours', 'dfgdfgfd', '2025-08-08 08:25:10'),
(54, 60, 42, '2025-08-08 12:15:00', 'Mal de tete ', 'Paludisme aigü', 'terminee', 'Un suivi stricte est nécessaire', '2025-08-08 10:19:10'),
(55, 61, 20, '2025-08-08 13:04:00', 'Mal de tete ', 'Grippe', 'terminee', 'Doit boire beaucoup d\'eau', '2025-08-08 11:05:10'),
(56, 44, 2, '2025-08-08 16:32:00', 'sdgdf', 'fdgfg', 'terminee', 'fgfd', '2025-08-08 14:32:06');

-- --------------------------------------------------------

--
-- Table structure for table `historique_patients`
--

CREATE TABLE `historique_patients` (
  `id_historique` int(11) NOT NULL,
  `id_patient` int(11) NOT NULL,
  `nom_patient` varchar(100) NOT NULL,
  `prenom_patient` varchar(100) NOT NULL,
  `action_type` enum('ajout','modification','suppression') NOT NULL,
  `details_action` text DEFAULT NULL,
  `id_utilisateur` int(11) NOT NULL,
  `nom_utilisateur` varchar(100) NOT NULL,
  `date_action` datetime DEFAULT current_timestamp(),
  `donnees_avant` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`donnees_avant`)),
  `donnees_apres` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`donnees_apres`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `historique_patients`
--

INSERT INTO `historique_patients` (`id_historique`, `id_patient`, `nom_patient`, `prenom_patient`, `action_type`, `details_action`, `id_utilisateur`, `nom_utilisateur`, `date_action`, `donnees_avant`, `donnees_apres`) VALUES
(1, 53, 'Niambi', 'Edmée Anne-Marie', 'ajout', 'Patient ajouté: Niambi Edmée Anne-Marie', 2, 'dr_martin', '2025-08-04 09:09:59', NULL, '{\"nom\": \"Niambi\", \"prenom\": \"Edmée Anne-Marie\", \"sexe\": \"Homme\", \"date_naissance\": \"1990-08-20\", \"telephone\": \"0749068795\", \"profession\": \"Artiste\", \"poids\": 60.00, \"taille\": 1.90}'),
(5, 44, 'KAMPAKOL OBANA MIYOULO', 'Marc-Jeremy', 'modification', 'Patient modifié: KAMPAKOL OBANA MIYOULO Marc-Jeremy', 2, 'dr_martin', '2025-08-04 16:32:23', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Homme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}', '{\"nom\": \"KAMPAKOL OBANA MIYOULO\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}'),
(7, 54, 'Mac', 'Malocha', 'ajout', 'Patient ajouté: Mac Malocha', 2, 'dr_martin', '2025-08-05 12:28:19', NULL, '{\"nom\": \"Mac\", \"prenom\": \"Malocha\", \"sexe\": \"Homme\", \"date_naissance\": \"2002-09-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 0.03, \"taille\": 0.56}'),
(9, 55, 'Mac', 'Oba', 'ajout', 'Patient ajouté: Mac Oba', 27, 'Aujou', '2025-08-06 08:36:00', NULL, '{\"nom\": \"Mac\", \"prenom\": \"Oba\", \"sexe\": \"Femme\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Rapeur\", \"poids\": 0.03, \"taille\": 0.56}'),
(11, 44, 'KAMPAKOL OBANA MIYOULOU', 'Marc-Jeremy', 'modification', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy', 2, 'dr_martin', '2025-08-06 08:49:34', '{\"nom\": \"KAMPAKOL OBANA MIYOULO\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}'),
(12, 44, 'KAMPAKOL OBANA MIYOULOU', 'Marc-Jeremy', 'modification', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy', 27, 'Aujou', '2025-08-06 08:49:34', '{\"nom\":\"KAMPAKOL OBANA MIYOULO\",\"prenom\":\"Marc-Jeremy\",\"sexe\":\"\",\"date_naissance\":\"1998-08-20\",\"loisirs\":\"Foot, piano, jeux video\",\"divers\":\"Freelanceur sur internet\",\"antecedents_medicaux\":\"RAS\",\"chirurgicaux\":\"RAS\",\"familiaux\":\"Son p\\u00e8re \\u00e9tait concereg\\u00e8ne\",\"mentions_particulieres\":\"Aucun\",\"telephone\":\"05338896517\",\"profession\":\"Artiste\",\"poids\":\"67.00\",\"taille\":\"1.60\"}', '{\"nom\":\"KAMPAKOL OBANA MIYOULOU\",\"prenom\":\"Marc-Jeremy\",\"sexe\":\"M\",\"date_naissance\":\"1998-08-20\",\"loisirs\":\"Foot, piano, jeux video\",\"divers\":\"Freelanceur sur internet\",\"antecedents_medicaux\":\"RAS\",\"chirurgicaux\":\"RAS\",\"familiaux\":\"Son p\\u00e8re \\u00e9tait concereg\\u00e8ne\",\"mentions_particulieres\":\"Aucun\",\"telephone\":\"05338896517\",\"profession\":\"Artiste\",\"poids\":\"67.00\",\"taille\":\"1.60\"}'),
(13, 56, 'Benie', 'LMk', 'ajout', 'Patient ajouté: Benie LMk', 27, 'Aujou', '2025-08-06 09:00:07', NULL, '{\"nom\": \"Benie\", \"prenom\": \"LMk\", \"sexe\": \"Femme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Eleve\", \"poids\": 0.03, \"taille\": 0.56}'),
(14, 56, 'Benie', 'LMk', 'modification', 'Patient modifié: Benie LMk', 27, 'Aujou', '2025-08-06 09:00:59', '{\"nom\": \"Benie\", \"prenom\": \"LMk\", \"sexe\": \"Femme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Eleve\", \"poids\": 0.03, \"taille\": 0.56}', '{\"nom\": \"Benie\", \"prenom\": \"LMk\", \"sexe\": \"\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Eleve\", \"poids\": 0.03, \"taille\": 0.56}'),
(15, 56, 'Benie', 'LMk', 'modification', 'Patient modifié: Benie LMk', 27, 'Aujou', '2025-08-06 09:00:59', '{\"nom\":\"Benie\",\"prenom\":\"LMk\",\"sexe\":\"Femme\",\"date_naissance\":\"1998-08-20\",\"loisirs\":\"DF\",\"divers\":\"\",\"antecedents_medicaux\":\"\",\"chirurgicaux\":\"\",\"familiaux\":\"\",\"mentions_particulieres\":\"\",\"telephone\":\"05338896517\",\"profession\":\"Eleve\",\"poids\":\"0.03\",\"taille\":\"0.56\"}', '{\"nom\":\"Benie\",\"prenom\":\"LMk\",\"sexe\":\"M\",\"date_naissance\":\"1998-08-20\",\"loisirs\":\"DFN\",\"divers\":\"\",\"antecedents_medicaux\":\"\",\"chirurgicaux\":\"\",\"familiaux\":\"\",\"mentions_particulieres\":\"\",\"telephone\":\"05338896517\",\"profession\":\"Eleve\",\"poids\":\"0.03\",\"taille\":\"0.56\"}'),
(16, 56, 'Benie', 'LMk', 'suppression', 'Patient supprimé: Benie LMk', 27, 'Aujou', '2025-08-06 09:05:57', '{\"nom\":\"Benie\",\"prenom\":\"LMk\",\"sexe\":\"\",\"date_naissance\":\"1998-08-20\",\"telephone\":\"05338896517\",\"profession\":\"Eleve\",\"poids\":\"0.03\",\"taille\":\"0.56\",\"loisirs\":\"DFN\",\"divers\":\"\",\"antecedents_medicaux\":\"\",\"chirurgicaux\":\"\",\"familiaux\":\"\",\"mentions_particulieres\":\"\"}', NULL),
(17, 56, 'Benie', 'LMk', 'suppression', 'Patient supprimé: Benie LMk', 27, 'Aujou', '2025-08-06 09:05:57', '{\"nom\": \"Benie\", \"prenom\": \"LMk\", \"sexe\": \"\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Eleve\", \"poids\": 0.03, \"taille\": 0.56}', NULL),
(18, 44, 'KAMPAKOL OBANA MIYOULOU', 'Marc-Jeremy', 'modification', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy', 2, 'dr_martin', '2025-08-06 09:11:12', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Femme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}'),
(19, 55, 'Mac', 'Oba', 'suppression', 'Patient supprimé: Mac Oba', 27, 'Aujou', '2025-08-06 09:11:49', '{\"nom\": \"Mac\", \"prenom\": \"Oba\", \"sexe\": \"Femme\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Rapeur\", \"poids\": 0.03, \"taille\": 0.56}', NULL),
(20, 57, 'Benie', 'LMk', 'ajout', 'Patient ajouté: Benie LMk', 27, 'Aujou', '2025-08-07 11:48:32', NULL, '{\"nom\": \"Benie\", \"prenom\": \"LMk\", \"sexe\": \"Homme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Eleve\", \"poids\": 0.03, \"taille\": 0.56}'),
(21, 57, 'Benie', 'LMk', 'suppression', 'Patient supprimé: Benie LMk', 27, 'Aujou', '2025-08-07 11:49:21', '{\"nom\": \"Benie\", \"prenom\": \"LMk\", \"sexe\": \"Homme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Eleve\", \"poids\": 0.03, \"taille\": 0.56}', NULL),
(22, 54, 'Mac', 'Malocha', 'suppression', 'Patient supprimé: Mac Malocha', 2, 'dr_martin', '2025-08-07 12:07:53', '{\"nom\": \"Mac\", \"prenom\": \"Malocha\", \"sexe\": \"Homme\", \"date_naissance\": \"2002-09-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 0.03, \"taille\": 0.56}', NULL),
(23, 44, 'KAMPAKOL OBANA MIYOULOU', 'Marc-Jeremy', 'modification', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy', 2, 'dr_martin', '2025-08-07 17:12:11', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Femme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Homme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}'),
(24, 44, 'KAMPAKOL OBANA MIYOULOU', 'Marc-Jeremy', 'modification', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy', 2, 'dr_martin', '2025-08-07 17:15:18', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Homme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Femme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}'),
(25, 44, 'KAMPAKOL OBANA MIYOULOU', 'Marc-Jeremy', 'modification', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy', 2, 'dr_martin', '2025-08-07 17:17:32', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Femme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Homme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}'),
(26, 53, 'Niambi', 'Edmée Anne-Marie', 'suppression', 'Patient supprimé: Niambi Edmée Anne-Marie', 2, 'dr_martin', '2025-08-07 17:20:09', '{\"nom\": \"Niambi\", \"prenom\": \"Edmée Anne-Marie\", \"sexe\": \"Homme\", \"date_naissance\": \"1990-08-20\", \"telephone\": \"0749068795\", \"profession\": \"Artiste\", \"poids\": 60.00, \"taille\": 1.90}', NULL),
(27, 44, 'KAMPAKOL OBANA MIYOULOU', 'Marc-Jeremy', 'modification', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy', 2, 'dr_martin', '2025-08-07 17:21:01', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Homme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Femme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}'),
(28, 58, 'Benie', 'LMk', 'ajout', 'Patient ajouté: Benie LMk', 2, 'dr_martin', '2025-08-07 17:22:08', NULL, '{\"nom\": \"Benie\", \"prenom\": \"LMk\", \"sexe\": \"Homme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Eleve\", \"poids\": 0.03, \"taille\": 0.56}'),
(29, 58, 'Benie', 'LMk', 'suppression', 'Patient supprimé: Benie LMk', 2, 'dr_martin', '2025-08-07 17:22:21', '{\"nom\": \"Benie\", \"prenom\": \"LMk\", \"sexe\": \"Homme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Eleve\", \"poids\": 0.03, \"taille\": 0.56}', NULL),
(30, 44, 'KAMPAKOL OBANA MIYOULOU', 'Marc-Jeremy', 'modification', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy', 2, 'dr_martin', '2025-08-07 17:27:18', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Femme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Homme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}'),
(31, 59, 'Bakala', 'Joe', 'ajout', 'Patient ajouté: Bakala Joe', 2, 'dr_martin', '2025-08-08 08:47:14', NULL, '{\"nom\": \"Bakala\", \"prenom\": \"Joe\", \"sexe\": \"Homme\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Rapeur\", \"poids\": 30.00, \"taille\": 1.60}'),
(32, 44, 'KAMPAKOL OBANA MIYOULOU', 'Marc-Jeremy', 'modification', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy', 2, 'dr_martin', '2025-08-08 09:14:10', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Homme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Homme\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}'),
(33, 60, 'NKOUNKOU', 'Prince', 'ajout', 'Patient ajouté: NKOUNKOU Prince', 42, 'GOALA Farild', '2025-08-08 11:11:38', NULL, '{\"nom\": \"NKOUNKOU\", \"prenom\": \"Prince\", \"sexe\": \"Homme\", \"date_naissance\": \"2000-08-08\", \"telephone\": \"05338896517\", \"profession\": \"Rapeur\", \"poids\": 30.00, \"taille\": 1.60}'),
(34, 60, 'NKOUNKOU', 'Prince', 'modification', 'Patient modifié: NKOUNKOU Prince', 42, 'GOALA Farild', '2025-08-08 11:56:53', '{\"nom\": \"NKOUNKOU\", \"prenom\": \"Prince\", \"sexe\": \"Homme\", \"date_naissance\": \"2000-08-08\", \"telephone\": \"05338896517\", \"profession\": \"Rapeur\", \"poids\": 30.00, \"taille\": 1.60}', '{\"nom\": \"NKOUNKOU\", \"prenom\": \"Prince\", \"sexe\": \"Homme\", \"date_naissance\": \"2018-09-20\", \"telephone\": \"05338896517\", \"profession\": \"Rapeur\", \"poids\": 30.00, \"taille\": 1.60}'),
(35, 46, 'premier', 'Achera', 'suppression', 'Patient supprimé: premier Achera', 2, 'dr_martin', '2025-08-08 11:57:47', '{\"nom\": \"premier\", \"prenom\": \"Achera\", \"sexe\": \"Homme\", \"date_naissance\": \"1990-05-18\", \"telephone\": \"0749068795\", \"profession\": \"Prof d\'anglais\", \"poids\": 100.00, \"taille\": 1.60}', NULL),
(36, 61, 'Ebara', 'Beni', 'ajout', 'Patient ajouté: Ebara Beni', 20, 'Jojo', '2025-08-08 12:04:05', NULL, '{\"nom\": \"Ebara\", \"prenom\": \"Beni\", \"sexe\": \"Homme\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"+242O65133445\", \"profession\": \"Informaticien\", \"poids\": 72.00, \"taille\": 1.72}'),
(37, 62, 'Kong', 'King', 'ajout', 'Patient ajouté: Kong King', 20, 'Jojo', '2025-08-08 12:40:38', NULL, '{\"nom\": \"Kong\", \"prenom\": \"King\", \"sexe\": \"Homme\", \"date_naissance\": \"1990-08-20\", \"telephone\": \"+905338896517\", \"profession\": \"Prof d\'anglais\", \"poids\": 49.00, \"taille\": 2.20}'),
(38, 63, 'Kong', 'King', 'ajout', 'Patient ajouté: Kong King', 2, 'dr_martin', '2025-08-08 15:14:36', NULL, '{\"nom\": \"Kong\", \"prenom\": \"King\", \"sexe\": \"Homme\", \"date_naissance\": \"1990-08-20\", \"telephone\": \"+905338896517\", \"profession\": \"Prof d\'anglais\", \"poids\": 49.00, \"taille\": 2.20}'),
(39, 64, 'KAMPAKOL OBANA MIYOULOU', 'Marc-Jeremy', 'ajout', 'Patient ajouté: KAMPAKOL OBANA MIYOULOU Marc-Jeremy', 2, 'dr_martin', '2025-08-08 15:15:08', NULL, '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Homme\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"+2425338896517\", \"profession\": \"EFZGF\", \"poids\": 30.00, \"taille\": 1.20}'),
(40, 60, 'NKOUNKOU', 'Prince', 'modification', 'Patient modifié: NKOUNKOU Prince', 42, 'GOALA Farild', '2025-08-08 16:18:26', '{\"nom\": \"NKOUNKOU\", \"prenom\": \"Prince\", \"sexe\": \"Homme\", \"date_naissance\": \"2018-09-20\", \"telephone\": \"05338896517\", \"profession\": \"Rapeur\", \"poids\": 30.00, \"taille\": 1.60}', '{\"nom\": \"NKOUNKOU\", \"prenom\": \"Prince\", \"sexe\": \"Femme\", \"date_naissance\": \"2018-09-20\", \"telephone\": \"05338896517\", \"profession\": \"Rapeur\", \"poids\": 30.00, \"taille\": 1.60}'),
(41, 62, 'Kong', 'KingC', 'modification', 'Patient modifié: Kong KingC', 20, 'Jojo', '2025-08-08 16:18:56', '{\"nom\": \"Kong\", \"prenom\": \"King\", \"sexe\": \"Homme\", \"date_naissance\": \"1990-08-20\", \"telephone\": \"+905338896517\", \"profession\": \"Prof d\'anglais\", \"poids\": 49.00, \"taille\": 2.20}', '{\"nom\": \"Kong\", \"prenom\": \"KingC\", \"sexe\": \"Homme\", \"date_naissance\": \"1990-08-20\", \"telephone\": \"+905338896517\", \"profession\": \"Prof d\'anglais\", \"poids\": 49.00, \"taille\": 2.20}'),
(42, 61, 'Ebara', 'Beni', 'modification', 'Patient modifié: Ebara Beni', 20, 'Jojo', '2025-08-08 16:27:25', '{\"nom\": \"Ebara\", \"prenom\": \"Beni\", \"sexe\": \"Homme\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"+242O65133445\", \"profession\": \"Informaticien\", \"poids\": 72.00, \"taille\": 1.72}', '{\"nom\": \"Ebara\", \"prenom\": \"Beni\", \"sexe\": \"Homme\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"+242O65133445\", \"profession\": \"Informaticie\", \"poids\": 72.00, \"taille\": 1.72}'),
(43, 65, 'OBANA', 'Marc-Jeremy', 'ajout', 'Patient ajouté: OBANA Marc-Jeremy', 2, 'dr_martin', '2025-08-08 21:20:32', NULL, '{\"nom\": \"OBANA\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Homme\", \"date_naissance\": \"1990-08-20\", \"telephone\": \"+905338896517\", \"profession\": \"Artiste\", \"poids\": 36.00, \"taille\": 2.20}'),
(44, 66, 'gdnfgng', 'fgnf', 'ajout', 'Patient ajouté: gdnfgng fgnf', 2, 'dr_martin', '2025-08-12 08:40:40', NULL, '{\"nom\": \"gdnfgng\", \"prenom\": \"fgnf\", \"sexe\": \"\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"+2425338896517\", \"profession\": \"gfbf\", \"poids\": 36.00, \"taille\": 2.20}'),
(45, 67, 'gdnfgng', 'Edmée Anne-Marie', 'ajout', 'Patient ajouté: gdnfgng Edmée Anne-Marie', 2, 'dr_martin', '2025-08-12 08:42:29', NULL, '{\"nom\": \"gdnfgng\", \"prenom\": \"Edmée Anne-Marie\", \"sexe\": \"Masculin\", \"date_naissance\": \"2006-09-24\", \"telephone\": \"+242749068795\", \"profession\": \"Rapeur\", \"poids\": 36.00, \"taille\": 2.20}'),
(46, 66, 'gdnfgng', 'fgnf', 'modification', 'Patient modifié: gdnfgng fgnf', 2, 'dr_martin', '2025-08-12 08:43:20', '{\"nom\": \"gdnfgng\", \"prenom\": \"fgnf\", \"sexe\": \"\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"+2425338896517\", \"profession\": \"gfbf\", \"poids\": 36.00, \"taille\": 2.20}', '{\"nom\": \"gdnfgng\", \"prenom\": \"fgnf\", \"sexe\": \"Masculin\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"+2425338896517\", \"profession\": \"gfbf\", \"poids\": 36.00, \"taille\": 2.20}'),
(47, 44, 'KAMPAKOL OBANA MIYOULOU', 'Marc-Jeremy', 'modification', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy', 2, 'dr_martin', '2025-08-12 08:44:45', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Masculin\", \"date_naissance\": \"1998-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Artiste\", \"poids\": 67.00, \"taille\": 1.60}'),
(48, 48, 'Miyoulou', 'Malocha', 'modification', 'Patient modifié: Miyoulou Malocha', 2, 'dr_martin', '2025-08-12 08:44:45', '{\"nom\": \"Miyoulou\", \"prenom\": \"Malocha\", \"sexe\": \"\", \"date_naissance\": \"2003-09-20\", \"telephone\": \"0749068795\", \"profession\": \"Rapeur\", \"poids\": 80.00, \"taille\": 1.90}', '{\"nom\": \"Miyoulou\", \"prenom\": \"Malocha\", \"sexe\": \"Masculin\", \"date_naissance\": \"2003-09-20\", \"telephone\": \"0749068795\", \"profession\": \"Rapeur\", \"poids\": 80.00, \"taille\": 1.90}'),
(49, 59, 'Bakala', 'Joe', 'modification', 'Patient modifié: Bakala Joe', 2, 'dr_martin', '2025-08-12 08:44:45', '{\"nom\": \"Bakala\", \"prenom\": \"Joe\", \"sexe\": \"\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Rapeur\", \"poids\": 30.00, \"taille\": 1.60}', '{\"nom\": \"Bakala\", \"prenom\": \"Joe\", \"sexe\": \"Feminin\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"05338896517\", \"profession\": \"Rapeur\", \"poids\": 30.00, \"taille\": 1.60}'),
(50, 60, 'NKOUNKOU', 'Prince', 'modification', 'Patient modifié: NKOUNKOU Prince', 42, 'GOALA Farild', '2025-08-12 08:44:45', '{\"nom\": \"NKOUNKOU\", \"prenom\": \"Prince\", \"sexe\": \"\", \"date_naissance\": \"2018-09-20\", \"telephone\": \"05338896517\", \"profession\": \"Rapeur\", \"poids\": 30.00, \"taille\": 1.60}', '{\"nom\": \"NKOUNKOU\", \"prenom\": \"Prince\", \"sexe\": \"Masculin\", \"date_naissance\": \"2018-09-20\", \"telephone\": \"05338896517\", \"profession\": \"Rapeur\", \"poids\": 30.00, \"taille\": 1.60}'),
(51, 61, 'Ebara', 'Beni', 'modification', 'Patient modifié: Ebara Beni', 20, 'Jojo', '2025-08-12 08:44:45', '{\"nom\": \"Ebara\", \"prenom\": \"Beni\", \"sexe\": \"\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"+242O65133445\", \"profession\": \"Informaticie\", \"poids\": 72.00, \"taille\": 1.72}', '{\"nom\": \"Ebara\", \"prenom\": \"Beni\", \"sexe\": \"Masculin\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"+242O65133445\", \"profession\": \"Informaticie\", \"poids\": 72.00, \"taille\": 1.72}'),
(52, 62, 'Kong', 'KingC', 'modification', 'Patient modifié: Kong KingC', 20, 'Jojo', '2025-08-12 08:44:45', '{\"nom\": \"Kong\", \"prenom\": \"KingC\", \"sexe\": \"\", \"date_naissance\": \"1990-08-20\", \"telephone\": \"+905338896517\", \"profession\": \"Prof d\'anglais\", \"poids\": 49.00, \"taille\": 2.20}', '{\"nom\": \"Kong\", \"prenom\": \"KingC\", \"sexe\": \"Feminin\", \"date_naissance\": \"1990-08-20\", \"telephone\": \"+905338896517\", \"profession\": \"Prof d\'anglais\", \"poids\": 49.00, \"taille\": 2.20}'),
(53, 63, 'Kong', 'King', 'modification', 'Patient modifié: Kong King', 2, 'dr_martin', '2025-08-12 08:44:45', '{\"nom\": \"Kong\", \"prenom\": \"King\", \"sexe\": \"\", \"date_naissance\": \"1990-08-20\", \"telephone\": \"+905338896517\", \"profession\": \"Prof d\'anglais\", \"poids\": 49.00, \"taille\": 2.20}', '{\"nom\": \"Kong\", \"prenom\": \"King\", \"sexe\": \"Masculin\", \"date_naissance\": \"1990-08-20\", \"telephone\": \"+905338896517\", \"profession\": \"Prof d\'anglais\", \"poids\": 49.00, \"taille\": 2.20}'),
(54, 64, 'KAMPAKOL OBANA MIYOULOU', 'Marc-Jeremy', 'modification', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy', 2, 'dr_martin', '2025-08-12 08:44:45', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"+2425338896517\", \"profession\": \"EFZGF\", \"poids\": 30.00, \"taille\": 1.20}', '{\"nom\": \"KAMPAKOL OBANA MIYOULOU\", \"prenom\": \"Marc-Jeremy\", \"sexe\": \"Masculin\", \"date_naissance\": \"2002-08-20\", \"telephone\": \"+2425338896517\", \"profession\": \"EFZGF\", \"poids\": 30.00, \"taille\": 1.20}'),
(55, 67, 'gdnfgng', 'Edmée Anne-Marie', 'suppression', 'Patient supprimé: gdnfgng Edmée Anne-Marie', 2, 'dr_martin', '2025-08-12 09:18:58', '{\"nom\": \"gdnfgng\", \"prenom\": \"Edmée Anne-Marie\", \"sexe\": \"Masculin\", \"date_naissance\": \"2006-09-24\", \"telephone\": \"+242749068795\", \"profession\": \"Rapeur\", \"poids\": 36.00, \"taille\": 2.20}', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `historique_utilisateurs`
--

CREATE TABLE `historique_utilisateurs` (
  `id` int(11) NOT NULL,
  `id_utilisateur_cible` int(11) NOT NULL,
  `nom_utilisateur_cible` varchar(100) NOT NULL,
  `prenom_utilisateur_cible` varchar(100) DEFAULT NULL,
  `id_utilisateur_auteur` int(11) NOT NULL,
  `nom_utilisateur_auteur` varchar(100) NOT NULL,
  `action_type` enum('ajout','modification','suppression','changement_statut','reinitialisation_mdp') NOT NULL,
  `details_action` text NOT NULL,
  `donnees_avant` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`donnees_avant`)),
  `donnees_apres` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`donnees_apres`)),
  `adresse_ip` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `date_action` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `historique_utilisateurs`
--

INSERT INTO `historique_utilisateurs` (`id`, `id_utilisateur_cible`, `nom_utilisateur_cible`, `prenom_utilisateur_cible`, `id_utilisateur_auteur`, `nom_utilisateur_auteur`, `action_type`, `details_action`, `donnees_avant`, `donnees_apres`, `adresse_ip`, `user_agent`, `date_action`) VALUES
(1, 1, 'Dr. Martin', NULL, 1, 'Admin', 'ajout', 'Création du compte médecin principal Dr. Martin', NULL, '{\"username\": \"Dr. Martin\", \"role\": \"medecin\", \"statut\": \"principal\"}', NULL, NULL, '2025-08-05 08:30:17'),
(2, 2, 'Dr. Durand', NULL, 1, 'Admin', 'ajout', 'Création du compte médecin intérimaire Dr. Durand', NULL, '{\"username\": \"Dr. Durand\", \"role\": \"medecin\", \"statut\": \"interimaire\"}', NULL, NULL, '2025-08-05 08:30:17'),
(3, 2, 'Dr. Durand', NULL, 1, 'Admin', 'changement_statut', 'Changement de statut: intérimaire → principal', NULL, '{\"statut\": \"interimaire\"}', NULL, NULL, '2025-08-05 08:30:17'),
(28, 37, 'ETOU Brisnel', NULL, 1, 'System', 'ajout', 'Nouvel utilisateur créé: ETOU Brisnel (medecin)', NULL, '{\"username\": \"ETOU Brisnel\", \"role\": \"medecin\", \"statut\": \"principal\"}', NULL, NULL, '2025-08-07 11:36:48'),
(29, 37, 'ETOU Brisnel', NULL, 1, 'admin', 'ajout', 'Nouveau médecin créé avec le statut: principal', NULL, '{\"username\":\"ETOU Brisnel\",\"statut\":\"principal\",\"mail\":\"marcjeremy.miyoulou@final.edu.tr\",\"phone_number\":\"05338896517\",\"address\":\"Ismet asim court No 1\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 11:36:48'),
(30, 37, 'ETOU Brisnel', NULL, 1, 'admin', 'suppression', 'Suppression du médecin ID 37 : ETOU Brisnel', '{\"username\":\"ETOU Brisnel\",\"role\":\"medecin\",\"statut\":\"principal\",\"mail\":\"marcjeremy.miyoulou@final.edu.tr\",\"photo\":null}', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 11:37:09'),
(31, 37, 'ETOU Brisnel', NULL, 1, 'admin', 'suppression', 'Suppression de l\'utilisateur: ETOU Brisnel (medecin)', '{\"username\": \"ETOU Brisnel\", \"role\": \"medecin\", \"statut\": \"principal\"}', NULL, '::1', NULL, '2025-08-07 11:37:09'),
(32, 38, 'ETOU Brisnel', NULL, 1, 'System', 'ajout', 'Nouvel utilisateur créé: ETOU Brisnel (medecin)', NULL, '{\"username\": \"ETOU Brisnel\", \"role\": \"medecin\", \"statut\": \"principal\"}', NULL, NULL, '2025-08-07 15:00:01'),
(33, 38, 'ETOU Brisnel', NULL, 1, 'admin', 'ajout', 'Nouveau médecin créé avec le statut: principal', NULL, '{\"username\":\"ETOU Brisnel\",\"statut\":\"principal\",\"mail\":\"marcjeremy.miyoulou@final.edu.tr\",\"phone_number\":\"05338896517\",\"address\":\"Ismet asim court No 1\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 15:00:01'),
(34, 38, 'ETOU Brisnel', NULL, 1, 'admin', 'suppression', 'Suppression du médecin ID 38 : ETOU Brisnel', '{\"username\":\"ETOU Brisnel\",\"role\":\"medecin\",\"statut\":\"principal\",\"mail\":\"marcjeremy.miyoulou@final.edu.tr\",\"photo\":null}', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 15:54:50'),
(35, 38, 'ETOU Brisnel', NULL, 1, 'admin', 'suppression', 'Suppression de l\'utilisateur: ETOU Brisnel (medecin)', '{\"username\": \"ETOU Brisnel\", \"role\": \"medecin\", \"statut\": \"principal\"}', NULL, '::1', NULL, '2025-08-07 15:54:50'),
(36, 39, 'ETOU Brisnel', NULL, 1, 'System', 'ajout', 'Nouvel utilisateur créé: ETOU Brisnel (medecin)', NULL, '{\"username\": \"ETOU Brisnel\", \"role\": \"medecin\", \"statut\": \"principal\"}', NULL, NULL, '2025-08-07 15:55:09'),
(37, 39, 'ETOU Brisnel', NULL, 1, 'admin', 'ajout', 'Nouveau médecin créé avec le statut: principal', NULL, '{\"username\":\"ETOU Brisnel\",\"statut\":\"principal\",\"mail\":\"marcjeremy.miyoulou@final.edu.tr\",\"phone_number\":\"05338896517\",\"address\":\".\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 15:55:09'),
(38, 39, 'ETOU Brisnel', NULL, 1, 'admin', 'suppression', 'Suppression du médecin ID 39 : ETOU Brisnel', '{\"username\":\"ETOU Brisnel\",\"role\":\"medecin\",\"statut\":\"principal\",\"mail\":\"marcjeremy.miyoulou@final.edu.tr\",\"photo\":null}', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 15:55:31'),
(39, 39, 'ETOU Brisnel', NULL, 1, 'admin', 'suppression', 'Suppression de l\'utilisateur: ETOU Brisnel (medecin)', '{\"username\": \"ETOU Brisnel\", \"role\": \"medecin\", \"statut\": \"principal\"}', NULL, '::1', NULL, '2025-08-07 15:55:31'),
(40, 1, 'admin', NULL, 1, 'System', 'changement_statut', 'Changement de statut pour admin:  → principal', '{\"statut\": \"\"}', '{\"statut\": \"principal\"}', NULL, NULL, '2025-08-07 16:01:23'),
(41, 1, 'admin', NULL, 1, 'System', 'modification', 'Modification utilisateur admin: Statut:  → principal; ', '{\"username\": \"admin\", \"role\": \"admin\", \"statut\": \"\"}', '{\"username\": \"admin\", \"role\": \"admin\", \"statut\": \"principal\"}', NULL, NULL, '2025-08-07 16:01:23'),
(42, 1, 'admin', NULL, 1, 'admin', 'modification', 'Modification du profil médecin', '{\"id_utilisateur\":1,\"username\":\"admin\",\"password\":\"$2y$10$39.uHiU4F35yYm16TnL0jeqSUphVsbMWlkMuuZtT5y9ntfBpLj1iS\",\"phone_number\":\"+242 06 123 4567\",\"address\":\"Centre-ville Brazzaville\",\"mail\":\"admin@clinic.cg\",\"photo\":null,\"role\":\"admin\",\"statut\":\"\",\"date_creation\":\"2025-07-23 10:53:30\",\"must_change_password\":0}', '{\"id_utilisateur\":1,\"username\":\"admin\",\"password\":\"$2y$10$39.uHiU4F35yYm16TnL0jeqSUphVsbMWlkMuuZtT5y9ntfBpLj1iS\",\"phone_number\":\"+242 06 123 4567\",\"address\":\"\",\"mail\":\"admin@clinic.cg\",\"photo\":null,\"role\":\"admin\",\"statut\":\"principal\",\"date_creation\":\"2025-07-23 10:53:30\",\"must_change_password\":0}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 16:01:23'),
(43, 1, 'admin', NULL, 1, 'admin', 'modification', 'Modification du profil médecin', '{\"id_utilisateur\":1,\"username\":\"admin\",\"password\":\"$2y$10$39.uHiU4F35yYm16TnL0jeqSUphVsbMWlkMuuZtT5y9ntfBpLj1iS\",\"phone_number\":\"+242 06 123 4567\",\"address\":\"\",\"mail\":\"admin@clinic.cg\",\"photo\":null,\"role\":\"admin\",\"statut\":\"principal\",\"date_creation\":\"2025-07-23 10:53:30\",\"must_change_password\":0}', '{\"id_utilisateur\":1,\"username\":\"admin\",\"password\":\"$2y$10$39.uHiU4F35yYm16TnL0jeqSUphVsbMWlkMuuZtT5y9ntfBpLj1iS\",\"phone_number\":\"+242 06 123 4567\",\"address\":\"\",\"mail\":\"admin@clinic.cg\",\"photo\":null,\"role\":\"admin\",\"statut\":\"principal\",\"date_creation\":\"2025-07-23 10:53:30\",\"must_change_password\":0}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 16:01:34'),
(44, 40, 'ETOU Brisnel', NULL, 1, 'System', 'ajout', 'Nouvel utilisateur créé: ETOU Brisnel (medecin)', NULL, '{\"username\": \"ETOU Brisnel\", \"role\": \"medecin\", \"statut\": \"principal\"}', NULL, NULL, '2025-08-07 16:02:35'),
(45, 40, 'ETOU Brisnel', NULL, 1, 'admin', 'ajout', 'Nouveau médecin créé avec le statut: principal', NULL, '{\"username\":\"ETOU Brisnel\",\"statut\":\"principal\",\"mail\":\"marcjeremy.miyoulou@final.edu.tr\",\"phone_number\":\"05338896517\",\"address\":\".\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 16:02:35'),
(46, 40, 'ETOU Brisnel', NULL, 1, 'admin', 'suppression', 'Suppression du médecin ID 40 : ETOU Brisnel', '{\"username\":\"ETOU Brisnel\",\"role\":\"medecin\",\"statut\":\"principal\",\"mail\":\"marcjeremy.miyoulou@final.edu.tr\",\"photo\":null}', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 16:02:44'),
(47, 40, 'ETOU Brisnel', NULL, 1, 'admin', 'suppression', 'Suppression de l\'utilisateur: ETOU Brisnel (medecin)', '{\"username\": \"ETOU Brisnel\", \"role\": \"medecin\", \"statut\": \"principal\"}', NULL, '::1', NULL, '2025-08-07 16:02:44'),
(48, 1, 'admin', NULL, 1, 'admin', 'modification', 'Modification du profil médecin', '{\"id_utilisateur\":1,\"username\":\"admin\",\"password\":\"$2y$10$39.uHiU4F35yYm16TnL0jeqSUphVsbMWlkMuuZtT5y9ntfBpLj1iS\",\"phone_number\":\"+242 06 123 4567\",\"address\":\"\",\"mail\":\"admin@clinic.cg\",\"photo\":null,\"role\":\"admin\",\"statut\":\"principal\",\"date_creation\":\"2025-07-23 10:53:30\",\"must_change_password\":0}', '{\"id_utilisateur\":1,\"username\":\"admin\",\"password\":\"$2y$10$39.uHiU4F35yYm16TnL0jeqSUphVsbMWlkMuuZtT5y9ntfBpLj1iS\",\"phone_number\":\"+242 06 123 4567\",\"address\":\"\",\"mail\":\"admin@clinic.cg\",\"photo\":null,\"role\":\"admin\",\"statut\":\"principal\",\"date_creation\":\"2025-07-23 10:53:30\",\"must_change_password\":0}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 16:02:50'),
(49, 1, 'admin', NULL, 1, 'admin', 'modification', 'Modification du profil médecin', '{\"id_utilisateur\":1,\"username\":\"admin\",\"password\":\"$2y$10$39.uHiU4F35yYm16TnL0jeqSUphVsbMWlkMuuZtT5y9ntfBpLj1iS\",\"phone_number\":\"+242 06 123 4567\",\"address\":\"\",\"mail\":\"admin@clinic.cg\",\"photo\":null,\"role\":\"admin\",\"statut\":\"principal\",\"date_creation\":\"2025-07-23 10:53:30\",\"must_change_password\":0}', '{\"id_utilisateur\":1,\"username\":\"admin\",\"password\":\"$2y$10$39.uHiU4F35yYm16TnL0jeqSUphVsbMWlkMuuZtT5y9ntfBpLj1iS\",\"phone_number\":\"+242 06 123 4567\",\"address\":\"Ismet asim court No 2\",\"mail\":\"admin@clinic.cg\",\"photo\":null,\"role\":\"admin\",\"statut\":\"principal\",\"date_creation\":\"2025-07-23 10:53:30\",\"must_change_password\":0}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 16:11:03'),
(50, 2, 'dr_martin', NULL, 1, 'admin', 'modification', 'Modification du profil médecin', '{\"id_utilisateur\":2,\"username\":\"dr_martin\",\"password\":\"martin123\",\"phone_number\":\"+242 06 234 5679\",\"address\":\"\",\"mail\":\"dr.martin@clinic.cg\",\"photo\":\"2_1753866046.jpeg\",\"role\":\"medecin\",\"statut\":\"principal\",\"date_creation\":\"2025-07-23 10:53:30\",\"must_change_password\":1}', '{\"id_utilisateur\":2,\"username\":\"dr_martin\",\"password\":\"martin123\",\"phone_number\":\"+242 06 234 5679\",\"address\":\"Ismet asim court No 2\",\"mail\":\"dr.martin@clinic.cg\",\"photo\":\"2_1753866046.jpeg\",\"role\":\"medecin\",\"statut\":\"principal\",\"date_creation\":\"2025-07-23 10:53:30\",\"must_change_password\":1}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 16:11:13'),
(51, 26, 'Luc Joe', NULL, 1, 'admin', 'modification', 'Modification du profil médecin', '{\"id_utilisateur\":26,\"username\":\"Luc Joe\",\"password\":\"martin123\",\"phone_number\":\"0749068795\",\"address\":\"\",\"mail\":\"marcjeremyk@gmail.com\",\"photo\":null,\"role\":\"medecin\",\"statut\":\"interimaire\",\"date_creation\":\"2025-08-01 14:14:21\",\"must_change_password\":1}', '{\"id_utilisateur\":26,\"username\":\"Luc Joe\",\"password\":\"martin123\",\"phone_number\":\"0749068795\",\"address\":\"Ismet asim court No 1\",\"mail\":\"marcjeremyk@gmail.com\",\"photo\":null,\"role\":\"medecin\",\"statut\":\"interimaire\",\"date_creation\":\"2025-08-01 14:14:21\",\"must_change_password\":1}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 16:11:25'),
(52, 18, 'Marc-Antoine', NULL, 1, 'admin', 'suppression', 'Suppression du médecin ID 18 : Marc-Antoine', '{\"username\":\"Marc-Antoine\",\"role\":\"medecin\",\"statut\":\"interimaire\",\"mail\":\"marckampakol2002@gmail.com\",\"photo\":null}', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 07:27:31'),
(53, 18, 'Marc-Antoine', NULL, 1, 'admin', 'suppression', 'Suppression de l\'utilisateur: Marc-Antoine (medecin)', '{\"username\": \"Marc-Antoine\", \"role\": \"medecin\", \"statut\": \"interimaire\"}', NULL, '::1', NULL, '2025-08-08 07:27:31'),
(54, 41, 'Marc-Jeremy KAMPAKOL OBANA MIYOULOU', NULL, 1, 'System', 'ajout', 'Nouvel utilisateur créé: Marc-Jeremy KAMPAKOL OBANA MIYOULOU (medecin)', NULL, '{\"username\": \"Marc-Jeremy KAMPAKOL OBANA MIYOULOU\", \"role\": \"medecin\", \"statut\": \"principal\"}', NULL, NULL, '2025-08-08 07:28:21'),
(55, 41, 'Marc-Jeremy KAMPAKOL OBANA MIYOULOU', NULL, 1, 'admin', 'ajout', 'Nouveau médecin créé avec le statut: principal', NULL, '{\"username\":\"Marc-Jeremy KAMPAKOL OBANA MIYOULOU\",\"statut\":\"principal\",\"mail\":\"marckampakol2002@gmail.com\",\"phone_number\":\"+242061220905\",\"address\":\"Quartier moungali rue kanda 23\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 07:28:21'),
(56, 26, 'Luc Joe', NULL, 1, 'System', 'suppression', 'Suppression de l\'utilisateur: Luc Joe (medecin)', '{\"username\": \"Luc Joe\", \"role\": \"medecin\", \"statut\": \"interimaire\"}', NULL, NULL, NULL, '2025-08-08 07:29:08'),
(57, 42, 'GOALA Farild', NULL, 1, 'System', 'ajout', 'Nouvel utilisateur créé: GOALA Farild (medecin)', NULL, '{\"username\": \"GOALA Farild\", \"role\": \"medecin\", \"statut\": \"principal\"}', NULL, NULL, '2025-08-08 09:53:49'),
(58, 42, 'GOALA Farild', NULL, 1, 'admin', 'ajout', 'Nouveau médecin créé avec le statut: principal', NULL, '{\"username\":\"GOALA Farild\",\"statut\":\"principal\",\"mail\":\"f@gmail.com\",\"phone_number\":\"+242065117478\",\"address\":\"ll,mugkknuhmyhlyigk\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 09:53:49'),
(59, 43, 'YUMBA Gloire', NULL, 1, 'System', 'ajout', 'Nouvel utilisateur créé: YUMBA Gloire (medecin)', NULL, '{\"username\": \"YUMBA Gloire\", \"role\": \"medecin\", \"statut\": \"principal\"}', NULL, NULL, '2025-08-08 09:57:08'),
(60, 43, 'YUMBA Gloire', NULL, 1, 'admin', 'ajout', 'Nouveau médecin créé avec le statut: principal', NULL, '{\"username\":\"YUMBA Gloire\",\"statut\":\"principal\",\"mail\":\"y@gmail.com\",\"phone_number\":\"+242069178069\",\"address\":\",lkgndfjgnlihkyjfnlhiguyk\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 09:57:08'),
(61, 44, 'Robert Franklin', NULL, 1, 'admin', 'ajout', 'Nouveau médecin créé avec le statut: interimaire', NULL, '{\"identifiant\":\"Robert\",\"username\":\"Robert Franklin\",\"statut\":\"interimaire\",\"mail\":\"non@gmail.com\",\"phone_number\":\"+242064989426\",\"address\":\"Quartier moungali rue kanda 23\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 07:50:11'),
(62, 44, 'Robert Franklin', NULL, 1, 'admin', 'suppression', 'Suppression du médecin ID 44 : Robert Franklin', '{\"username\":\"Robert Franklin\",\"role\":\"medecin\",\"statut\":\"interimaire\",\"mail\":\"non@gmail.com\",\"photo\":null}', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 07:51:08'),
(63, 44, 'Robert Franklin', NULL, 1, 'admin', 'suppression', 'Suppression de l\'utilisateur: Robert Franklin (medecin)', '{\"username\": \"Robert Franklin\", \"role\": \"medecin\", \"statut\": \"interimaire\"}', NULL, '::1', NULL, '2025-08-11 07:51:08'),
(64, 45, 'Robert Franklin', NULL, 1, 'admin', 'ajout', 'Nouveau médecin créé avec le statut: principal', NULL, '{\"identifiant\":\"Robert\",\"username\":\"Robert Franklin\",\"statut\":\"principal\",\"mail\":\"non@gmail.com\",\"phone_number\":\"+242064989426\",\"address\":\"Quartier moungali rue kanda 23\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 07:52:57'),
(65, 45, 'Robert Franklin', NULL, 1, 'admin', 'suppression', 'Suppression du médecin ID 45 : Robert Franklin', '{\"username\":\"Robert Franklin\",\"role\":\"medecin\",\"statut\":\"principal\",\"mail\":\"non@gmail.com\",\"photo\":null}', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 07:53:15'),
(66, 43, 'YUMBA Gloire', NULL, 1, 'admin', 'modification', 'Modification du profil médecin', '{\"id_utilisateur\":43,\"username\":\"YUMBA Gloire\",\"identifiant\":\"Gloire\",\"password\":\"12345678Ab\",\"phone_number\":\"+242069178069\",\"address\":\",lkgndfjgnlihkyjfnlhiguyk\",\"mail\":\"y@gmail.com\",\"photo\":null,\"role\":\"medecin\",\"statut\":\"principal\",\"date_creation\":\"2025-08-08 10:57:08\",\"must_change_password\":1}', '{\"id_utilisateur\":43,\"username\":\"YUMBA Gloire\",\"identifiant\":\"Gloire\",\"password\":\"12345678Ab\",\"phone_number\":\"+242069178069\",\"address\":\",lkgndfjgnlihkyjfnlhiguy\",\"mail\":\"y@gmail.com\",\"photo\":null,\"role\":\"medecin\",\"statut\":\"principal\",\"date_creation\":\"2025-08-08 10:57:08\",\"must_change_password\":1}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 07:53:56'),
(67, 46, 'Robert Franklin', NULL, 1, 'admin', 'ajout', 'Nouveau médecin créé avec le statut: principal', NULL, '{\"identifiant\":\"Robert\",\"username\":\"Robert Franklin\",\"statut\":\"principal\",\"mail\":\"non@gmail.com\",\"phone_number\":\"+242064989426\",\"address\":\"Quartier moungali rue kanda 23\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 08:25:09'),
(68, 46, 'Robert Franklin', NULL, 1, 'admin', 'suppression', 'Suppression du médecin ID 46 : Robert Franklin', '{\"username\":\"Robert Franklin\",\"role\":\"medecin\",\"statut\":\"principal\",\"mail\":\"non@gmail.com\",\"photo\":null}', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 08:35:28'),
(69, 47, 'Robert Franklin', NULL, 1, 'admin', 'ajout', 'Nouveau médecin créé avec le statut: interimaire', NULL, '{\"identifiant\":\"Robert\",\"username\":\"Robert Franklin\",\"statut\":\"interimaire\",\"mail\":\"non@gmail.com\",\"phone_number\":\"+242064989426\",\"address\":\"Quartier moungali rue kanda 23\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 08:36:32'),
(70, 47, 'Robert Franklin', NULL, 1, 'admin', 'suppression', 'Suppression du médecin ID 47 : Robert Franklin', '{\"username\":\"Robert Franklin\",\"role\":\"medecin\",\"statut\":\"interimaire\",\"mail\":\"non@gmail.com\",\"photo\":null}', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 08:40:32');

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
(37, 44, NULL, NULL, 'Diagnostic', 'C\'est compliqué mais bon il va s\'en sortir', '2025-08-01 10:34:19'),
(38, 44, NULL, 39, 'Note', 'Je dois le surveiller de plus pres', '2025-08-01 10:36:15'),
(41, 48, NULL, 44, 'Diagnostic', 'kvjhchd', '2025-08-01 14:27:26'),
(44, 44, NULL, NULL, 'Suivi', 'dd', '2025-08-07 14:10:53'),
(45, 44, 27, NULL, 'Suivi', 'j;:j', '2025-08-07 14:18:14'),
(46, 44, 2, 53, 'Suivi', 'sdfsdfs', '2025-08-08 10:00:14'),
(47, 60, 42, 54, 'Suivi', 'Patient allergique au pollen', '2025-08-08 11:22:05'),
(48, 61, 20, 55, 'Suivi', 'Il ne se couvre pas assez', '2025-08-08 12:05:29');

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
(47, 44, 2, '2025-08-01 10:35:43', 'Paracétamol 500 mg', '1 comprimé 3fois par jour', '7 jours', 'Pas d\'alcool je vous connais', 'active', 39),
(53, 48, 2, '2025-08-01 14:20:30', 'fdgdf', 'dfgdf', 'dfgd', 'dfgdf', 'active', 44),
(57, 44, 2, '2025-08-08 09:29:19', 'dfs', 'sgdfg', 'dfgd', 'fdgd', 'active', 53),
(58, 44, 2, '2025-08-08 09:29:34', 'dfs', 'sgdfg', 'dfgd', 'fdgd', 'active', 53),
(59, 44, 2, '2025-08-08 09:34:26', 'dsg', 'dg', 'dgf', 'df', 'active', 53),
(60, 44, 2, '2025-08-08 09:35:46', 'sdgs', 'sfd', 'xcv', 'xgs', 'active', 53),
(61, 44, 2, '2025-08-08 09:38:53', 'sqfqd', 'qfs', 'dfs', 'sdg', 'active', 53),
(62, 44, 2, '2025-08-08 09:40:54', 'h,ghg', 'gngh', 'ghng', 'gng', 'active', 53),
(63, 44, 2, '2025-08-08 09:43:31', 'zgfrg', 'sfgdg', 'dfgd', 'dfgd', 'active', 53),
(64, 60, 42, '2025-08-08 11:48:20', '-Paracetamole 500mg\r\n-Dolipranne 400mg\r\n-jfjkgkgblglg\r\n-jfkifklvglkkhb\r\n-kfgjgjgkgk-\r\n,gfjghjkghjkhkhkh\r\n-jkgikgjghkghkhkh\r\n-khkihjhljhkljolkl', '- 1 comprimé par jour \r\n-2 par jour matin soir', '30 jrs', 'Patient à surveiller', 'terminee', 54),
(65, 60, 42, '2025-08-08 11:50:53', 'jfdfhjfghjgjngfjhnjh\r\njhfguhhhhhhhhhhhhh\r\ndkkkkkkkkkkkkkkkkkk\r\nfffffffffffffffffffffffffffff\r\nbftguddddddddddddddd\r\nddddddddddddddddff\r\nujujujujujujujujujujujujujujujrt\r\ndfffffffffffffffffffffffffffffffffffffff\r\nduifffffffffffffffffffffffffffffffffff\r\noyiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii', 'iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii\r\ngggggggggggggggggggggggggggggg\r\nhjhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh\r\njjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj\r\nkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk\r\nllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll\r\nssssssssssssssssssssssssssssssssssssssssssss\r\nfffffffffffffffffffffffffffffffffffffffffffffffffffffffff\r\nvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv\r\nbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', '30 jrs', 'A risques', 'terminee', NULL),
(66, 60, 42, '2025-08-08 11:51:10', 'jfdfhjfghjgjngfjhnjh\r\njhfguhhhhhhhhhhhhh\r\ndkkkkkkkkkkkkkkkkkk\r\nfffffffffffffffffffffffffffff\r\nbftguddddddddddddddd\r\nddddddddddddddddff\r\nujujujujujujujujujujujujujujujrt\r\ndfffffffffffffffffffffffffffffffffffffff\r\nduifffffffffffffffffffffffffffffffffff\r\noyiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii', 'iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii\r\ngggggggggggggggggggggggggggggg\r\nhjhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh\r\njjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj\r\nkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk\r\nllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll\r\nssssssssssssssssssssssssssssssssssssssssssss\r\nfffffffffffffffffffffffffffffffffffffffffffffffffffffffff\r\nvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv\r\nbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', '30 jrs', 'A risques', 'terminee', NULL),
(67, 60, 42, '2025-08-08 11:53:15', ',dnvvvvvvfbbbbbbbbbb\r\ndfhgggfhhhddgghdg\r\ndhsjfjdhjd\r\nfgfjdfgj\r\nfsgjdfjd\r\nfgjdfjd\r\nfdjdghj\r\ndfjdghj\r\nfgjdghj\r\ndgjdfhg', 'dfhsfghdfghs\r\nsghsfghsfghfsg\r\nsghsfghsfh\r\nsghsghfst\r\nsfgjfgjdgh\r\nsfghdfgh\r\nsghdfjd\r\ngfhfdhj\r\nsghsf', '30 jours', 'hdhsd', 'terminee', 54),
(68, 60, 42, '2025-08-08 11:53:28', ',dnvvvvvvfbbbbbbbbbb\r\ndfhgggfhhhddgghdg\r\ndhsjfjdhjd\r\nfgfjdfgj\r\nfsgjdfjd\r\nfgjdfjd\r\nfdjdghj\r\ndfjdghj\r\nfgjdghj\r\ndgjdfhg', 'dfhsfghdfghs\r\nsghsfghsfghfsg\r\nsghsfghsfh\r\nsghsghfst\r\nsfgjfgjdgh\r\nsfghdfgh\r\nsghdfjd\r\ngfhfdhj\r\nsghsf', '30 jours', 'hdhsd', 'terminee', 54),
(69, 61, 20, '2025-08-08 12:07:36', 'Pacacétamole', '1 comprimé par jour', '7 jours', 'Prends de l\'eau', 'terminee', 55),
(70, 61, 20, '2025-08-08 12:08:13', 'Dolipranne', '1 comprimé par jour', '2 semaines', 'Manges bien', 'terminee', 55),
(71, 48, 2, '2025-08-08 15:56:22', 'Paracetamole \r\nDoliprane', 'Paracetamole : 1 par jour\nDoliprane : 3 par jour', '4 jours', 'frgerg', 'active', NULL),
(72, 48, 2, '2025-08-08 15:58:07', 'Paracetamole', 'Paracetamole : 1 comprimer par jour', '2 jours', 'dfdzs', 'active', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `patients`
--

CREATE TABLE `patients` (
  `id_patient` int(11) NOT NULL,
  `nom` varchar(50) NOT NULL,
  `prenom` varchar(50) NOT NULL,
  `sexe` enum('Masculin','Feminin') NOT NULL,
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
(44, 'KAMPAKOL OBANA MIYOULOU', 'Marc-Jeremy', 'Masculin', '1998-08-20', 'Foot, piano, jeux video', 'Freelanceur sur internet', 'RAS', 'RAS', 'Son père était conceregène', 'Aucun', '05338896517', 'Artiste', 67.00, 1.60, 2, '2025-08-01 10:31:00'),
(48, 'Miyoulou', 'Malocha', 'Masculin', '2003-09-20', 'Dormir', 'RAS', 'Rien du tout', 'Tout va bien', 'Parfait', 'Wahou', '0749068795', 'Rapeur', 80.00, 1.90, 2, '2025-08-01 14:17:32'),
(59, 'Bakala', 'Joe', 'Feminin', '2002-08-20', 'Play', 'aucuna', '', '', '', '', '05338896517', 'Rapeur', 30.00, 1.60, 2, '2025-08-08 08:47:14'),
(60, 'NKOUNKOU', 'Prince', 'Masculin', '2018-09-20', 'Play', 'aucuna', '', '', '', '', '05338896517', 'Rapeur', 30.00, 1.60, 42, '2025-08-08 11:11:38'),
(61, 'Ebara', 'Beni', 'Masculin', '2002-08-20', 'Foot, piano, jeux viedeo', 'manger', 'GFFG', 'fbfb', 'bcbcg', 'cvcvb', '+242O65133445', 'Informaticie', 72.00, 1.72, 20, '2025-08-08 12:04:05'),
(62, 'Kong', 'KingC', 'Feminin', '1990-08-20', 'SDFSDF', '', '', '', '', '', '+905338896517', 'Prof d\'anglais', 49.00, 2.20, 20, '2025-08-08 12:40:38'),
(63, 'Kong', 'King', 'Masculin', '1990-08-20', 'SDFSDF', '', '', '', '', '', '+905338896517', 'Prof d\'anglais', 49.00, 2.20, 2, '2025-08-08 15:14:36'),
(64, 'KAMPAKOL OBANA MIYOULOU', 'Marc-Jeremy', 'Masculin', '2002-08-20', '', '', '', '', '', '', '+2425338896517', 'EFZGF', 30.00, 1.20, 2, '2025-08-08 15:15:08'),
(65, 'OBANA', 'Marc-Jeremy', '', '1990-08-20', '', '', '', '', '', '', '+905338896517', 'Artiste', 36.00, 2.20, 2, '2025-08-08 21:20:32'),
(66, 'gdnfgng', 'fgnf', 'Masculin', '2002-08-20', 'FDGD', 'DFGD', '', '', '', '', '+2425338896517', 'gfbf', 36.00, 2.20, 2, '2025-08-12 08:40:40');

--
-- Triggers `patients`
--
DELIMITER $$
CREATE TRIGGER `trigger_ajout_patient` AFTER INSERT ON `patients` FOR EACH ROW BEGIN
    DECLARE user_name VARCHAR(100);
    
    -- Récupérer le nom de l'utilisateur
    SELECT username INTO user_name 
    FROM users 
    WHERE id_utilisateur = NEW.id_utilisateur;
    
    INSERT INTO historique_patients (
        id_patient, 
        nom_patient, 
        prenom_patient, 
        action_type, 
        details_action,
        id_utilisateur, 
        nom_utilisateur,
        donnees_apres
    ) VALUES (
        NEW.id_patient,
        NEW.nom,
        NEW.prenom,
        'ajout',
        CONCAT('Patient ajouté: ', NEW.nom, ' ', NEW.prenom),
        NEW.id_utilisateur,
        IFNULL(user_name, 'Utilisateur inconnu'),
        JSON_OBJECT(
            'nom', NEW.nom,
            'prenom', NEW.prenom,
            'sexe', NEW.sexe,
            'date_naissance', NEW.date_naissance,
            'telephone', NEW.telephone,
            'profession', NEW.profession,
            'poids', NEW.poids,
            'taille', NEW.taille
        )
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trigger_modification_patient` AFTER UPDATE ON `patients` FOR EACH ROW BEGIN
    DECLARE user_name VARCHAR(100);
    DECLARE user_id INT DEFAULT 0;
    
    -- Essayer de récupérer l'utilisateur depuis la session (à adapter selon votre système)
    -- Pour le moment, on utilisera l'id_utilisateur du patient
    SET user_id = NEW.id_utilisateur;
    
    SELECT username INTO user_name 
    FROM users 
    WHERE id_utilisateur = user_id;
    
    INSERT INTO historique_patients (
        id_patient, 
        nom_patient, 
        prenom_patient, 
        action_type, 
        details_action,
        id_utilisateur, 
        nom_utilisateur,
        donnees_avant,
        donnees_apres
    ) VALUES (
        NEW.id_patient,
        NEW.nom,
        NEW.prenom,
        'modification',
        CONCAT('Patient modifié: ', NEW.nom, ' ', NEW.prenom),
        user_id,
        IFNULL(user_name, 'Utilisateur inconnu'),
        JSON_OBJECT(
            'nom', OLD.nom,
            'prenom', OLD.prenom,
            'sexe', OLD.sexe,
            'date_naissance', OLD.date_naissance,
            'telephone', OLD.telephone,
            'profession', OLD.profession,
            'poids', OLD.poids,
            'taille', OLD.taille
        ),
        JSON_OBJECT(
            'nom', NEW.nom,
            'prenom', NEW.prenom,
            'sexe', NEW.sexe,
            'date_naissance', NEW.date_naissance,
            'telephone', NEW.telephone,
            'profession', NEW.profession,
            'poids', NEW.poids,
            'taille', NEW.taille
        )
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trigger_suppression_patient` BEFORE DELETE ON `patients` FOR EACH ROW BEGIN
    DECLARE user_name VARCHAR(100);
    DECLARE user_id INT DEFAULT 0;
    
    -- Pour la suppression, vous devrez passer l'ID utilisateur via une variable de session
    -- ou l'adapter selon votre système
    SET user_id = OLD.id_utilisateur;
    
    SELECT username INTO user_name 
    FROM users 
    WHERE id_utilisateur = user_id;
    
    INSERT INTO historique_patients (
        id_patient, 
        nom_patient, 
        prenom_patient, 
        action_type, 
        details_action,
        id_utilisateur, 
        nom_utilisateur,
        donnees_avant
    ) VALUES (
        OLD.id_patient,
        OLD.nom,
        OLD.prenom,
        'suppression',
        CONCAT('Patient supprimé: ', OLD.nom, ' ', OLD.prenom),
        user_id,
        IFNULL(user_name, 'Utilisateur inconnu'),
        JSON_OBJECT(
            'nom', OLD.nom,
            'prenom', OLD.prenom,
            'sexe', OLD.sexe,
            'date_naissance', OLD.date_naissance,
            'telephone', OLD.telephone,
            'profession', OLD.profession,
            'poids', OLD.poids,
            'taille', OLD.taille
        )
    );
END
$$
DELIMITER ;

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

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id_utilisateur` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `identifiant` varchar(50) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `mail` varchar(100) DEFAULT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `role` varchar(30) DEFAULT NULL,
  `statut` enum('principal','interimaire') DEFAULT 'interimaire',
  `date_creation` datetime NOT NULL DEFAULT current_timestamp(),
  `must_change_password` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id_utilisateur`, `username`, `identifiant`, `password`, `phone_number`, `address`, `mail`, `photo`, `role`, `statut`, `date_creation`, `must_change_password`) VALUES
(1, 'admin', 'Admin', '$2y$10$39.uHiU4F35yYm16TnL0jeqSUphVsbMWlkMuuZtT5y9ntfBpLj1iS', '+242 06 123 4567', 'Ismet asim court No 2', 'admin@clinic.cg', NULL, 'admin', 'principal', '2025-07-23 10:53:30', 0),
(2, 'dr_martin', 'martin', '$2y$10$nhl7CMquTIn3SswwOrdbj.A8WPbL5DVV7TAlYIbif8H9HEhoX3L3W', '+242 06 234 5679', 'Ismet asim court No 2', 'dr.martin@clinic.cg', '2_1753866046.jpeg', 'medecin', 'principal', '2025-07-23 10:53:30', 0),
(20, 'Jojo', 'jojo', 'jeremy242', '05338896517', 'Ismet asim court No 1', 'marcjeremykampakol@gmail.com', NULL, 'medecin', 'interimaire', '2025-07-23 16:28:43', 1),
(27, 'Aujou', 'Aujou', 'andy@gmail.com', '0749068795', 'Ismet asim court No 7', 'admin@gmail.com', NULL, 'medecin', 'principal', '2025-08-01 14:34:43', 1),
(41, 'Marc-Jeremy KAMPAKOL OBANA MIYOULOU', 'Marc', '123456789Ab', '+242061220905', 'Quartier moungali rue kanda 23', 'marckampakol2002@gmail.com', NULL, 'medecin', 'principal', '2025-08-08 08:28:21', 1),
(42, 'GOALA Farild', 'Farild', '12345678Ab', '+242065117478', 'll,mugkknuhmyhlyigk', 'f@gmail.com', NULL, 'medecin', 'principal', '2025-08-08 10:53:49', 1),
(43, 'YUMBA Gloire', 'Gloire', '12345678Ab', '+242069178069', ',lkgndfjgnlihkyjfnlhiguy', 'y@gmail.com', NULL, 'medecin', 'principal', '2025-08-08 10:57:08', 1);

--
-- Triggers `users`
--
DELIMITER $$
CREATE TRIGGER `after_user_update` AFTER UPDATE ON `users` FOR EACH ROW BEGIN
    DECLARE details TEXT DEFAULT '';
    
    -- Construire les détails des changements
    IF OLD.username != NEW.username THEN
        SET details = CONCAT(details, 'Username: ', OLD.username, ' → ', NEW.username, '; ');
    END IF;
    
    IF OLD.role != NEW.role THEN
        SET details = CONCAT(details, 'Rôle: ', OLD.role, ' → ', NEW.role, '; ');
    END IF;
    
    IF OLD.statut != NEW.statut THEN
        SET details = CONCAT(details, 'Statut: ', OLD.statut, ' → ', NEW.statut, '; ');
        
        -- Action spécifique pour changement de statut
        INSERT INTO historique_utilisateurs (
            id_utilisateur_cible, nom_utilisateur_cible, id_utilisateur_auteur, nom_utilisateur_auteur,
            action_type, details_action, donnees_avant, donnees_apres, adresse_ip
        ) VALUES (
            NEW.id_utilisateur, NEW.username,
            COALESCE(@current_user_id, 1), COALESCE(@current_username, 'System'),
            'changement_statut',
            CONCAT('Changement de statut pour ', NEW.username, ': ', OLD.statut, ' → ', NEW.statut),
            JSON_OBJECT('statut', OLD.statut),
            JSON_OBJECT('statut', NEW.statut),
            @current_user_ip
        );
    END IF;
    
    -- Enregistrement général de modification
    IF details != '' THEN
        INSERT INTO historique_utilisateurs (
            id_utilisateur_cible, nom_utilisateur_cible, id_utilisateur_auteur, nom_utilisateur_auteur,
            action_type, details_action, donnees_avant, donnees_apres, adresse_ip
        ) VALUES (
            NEW.id_utilisateur, NEW.username,
            COALESCE(@current_user_id, 1), COALESCE(@current_username, 'System'),
            'modification',
            CONCAT('Modification utilisateur ', NEW.username, ': ', details),
            JSON_OBJECT('username', OLD.username, 'role', OLD.role, 'statut', OLD.statut),
            JSON_OBJECT('username', NEW.username, 'role', NEW.role, 'statut', NEW.statut),
            @current_user_ip
        );
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `user_activity`
--

CREATE TABLE `user_activity` (
  `id` int(11) NOT NULL,
  `id_utilisateur` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `action_type` enum('connexion','deconnexion','consultation','creation','modification','suppression') NOT NULL,
  `page_visitee` varchar(255) DEFAULT NULL,
  `details_action` text DEFAULT NULL,
  `adresse_ip` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `duree_session` int(11) DEFAULT NULL,
  `date_action` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_activity`
--

INSERT INTO `user_activity` (`id`, `id_utilisateur`, `username`, `action_type`, `page_visitee`, `details_action`, `adresse_ip`, `user_agent`, `session_id`, `duree_session`, `date_action`) VALUES
(1, 1, 'Dr. Martin', 'connexion', 'login.php', 'Connexion réussie', '192.168.1.100', NULL, NULL, NULL, '2025-08-05 08:30:17'),
(2, 1, 'Dr. Martin', 'consultation', 'dashboard.php', 'Accès au tableau de bord', '192.168.1.100', NULL, NULL, NULL, '2025-08-05 08:30:17'),
(3, 1, 'Dr. Martin', 'creation', 'ajouter_patient.php', 'Ajout d\'un nouveau patient: Jean Dupont', '192.168.1.100', NULL, NULL, NULL, '2025-08-05 08:30:17'),
(4, 2, 'Dr. Durand', 'connexion', 'login.php', 'Connexion réussie', '192.168.1.101', NULL, NULL, NULL, '2025-08-05 08:30:17'),
(5, 2, 'Dr. Durand', 'consultation', 'liste_patients.php', 'Consultation de la liste des patients', '192.168.1.101', NULL, NULL, NULL, '2025-08-05 08:30:17'),
(6, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:12:48'),
(7, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:12:52'),
(8, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:12:53'),
(9, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:17:56'),
(10, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:17:57'),
(11, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:19:34'),
(12, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:19:34'),
(13, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'Accès au tableau du medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:20:39'),
(14, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:27:30'),
(15, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:27:30'),
(16, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Accès à la liste des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:27:39'),
(17, 2, 'dr_martin', 'consultation', 'historique_consultations.php', 'Accès à historique medicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:27:46'),
(18, 2, 'dr_martin', 'consultation', 'historique_patients.php', 'Accès à historique patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:27:49'),
(19, 2, 'dr_martin', 'consultation', 'historique_consultations.php', 'Accès à historique medicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:27:51'),
(20, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:27:52'),
(21, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:27:52'),
(22, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:28:19'),
(23, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:28:19'),
(24, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Accès à la liste des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:28:21'),
(25, 2, 'dr_martin', 'consultation', 'details_patient.php', 'Accès au d\"tails du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:28:26'),
(26, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:28:30'),
(27, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:28:37'),
(28, 2, 'dr_martin', 'creation', 'consultation.php', 'Nouvelle consultation pour  (ID patient: 54)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:28:37'),
(29, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Accès à la liste des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:28:37'),
(30, 2, 'dr_martin', 'consultation', 'details_patient.php', 'Accès au d\"tails du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:28:44'),
(31, 2, 'dr_martin', 'consultation', 'details_patient.php', 'Accès au d\"tails du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:30:29'),
(32, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:31:21'),
(33, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:31:28'),
(34, 2, 'dr_martin', 'creation', 'consultation.php', 'Nouvelle consultation pour  (ID patient: 54)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:31:28'),
(35, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Accès à la liste des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:31:28'),
(36, 2, 'dr_martin', 'consultation', 'details_patient.php', 'Accès au d\"tails du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:31:33'),
(37, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:32:23'),
(38, 2, 'dr_martin', 'consultation', 'details_patient.php', 'Accès au d\"tails du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:32:30'),
(39, 2, 'dr_martin', 'consultation', 'details_patient.php', 'Accès au d\"tails du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:37:48'),
(40, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:37:51'),
(41, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:37:58'),
(42, 2, 'dr_martin', 'creation', 'consultation.php', 'Nouvelle consultation pour Mac Malocha (ID patient: 54)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:37:58'),
(43, 2, 'dr_martin', 'consultation', 'ajouter_observation.php', 'Accès à ajouter observation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:44:10'),
(44, 2, 'dr_martin', 'consultation', 'ajouter_observation.php', 'Accès à ajouter observation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:44:15'),
(45, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:44:20'),
(46, 2, 'dr_martin', 'consultation', 'details_patient.php', 'Accès au d\"tails du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:44:24'),
(47, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'Accès à ordonnance patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:44:41'),
(48, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'Accès à ordonnance patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:44:50'),
(49, 2, 'dr_martin', 'creation', 'ordonnance.php', 'Ordonnance créée: zzf pour Mac Malocha (ID ordonnance: 56)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:44:50'),
(50, 2, 'dr_martin', 'consultation', 'bon_examen.php', 'Accès à bon examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:44:55'),
(51, 2, 'dr_martin', 'consultation', 'details_patient.php', 'Accès au d\"tails du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:44:59'),
(52, 2, 'dr_martin', 'consultation', 'bon_examen.php', 'Accès à bon examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:48:08'),
(53, 2, 'dr_martin', 'consultation', 'details_patient.php', 'Accès au d\"tails du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:48:11'),
(54, 2, 'dr_martin', 'consultation', 'details_patient.php', 'Accès au d\"tails du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:48:35'),
(55, 2, 'dr_martin', 'consultation', 'bon_examen.php', 'Accès à bon examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:53:01'),
(56, 2, 'dr_martin', 'consultation', 'bon_examen.php', 'Accès à bon examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:53:04'),
(57, 2, 'dr_martin', 'consultation', 'details_patient.php', 'Accès au d\"tails du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:53:07'),
(58, 2, 'dr_martin', 'consultation', 'details_patient.php', 'Accès au d\"tails du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:53:47'),
(59, 2, 'dr_martin', 'consultation', 'bon_examen.php', 'Accès à bon examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:53:55'),
(60, 2, 'dr_martin', 'consultation', 'bon_examen.php', 'Accès à bon examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:53:59'),
(61, 2, 'dr_martin', 'consultation', 'details_patient.php', 'Accès au d\"tails du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:54:03'),
(62, 2, 'dr_martin', 'consultation', 'bon_examen.php', 'Accès à bon examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:54:17'),
(63, 2, 'dr_martin', 'consultation', 'details_patient.php', 'Accès au d\"tails du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:54:20'),
(64, 2, 'dr_martin', 'consultation', 'details_patient.php', 'Accès au d\"tails du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:55:12'),
(65, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 11:55:53'),
(66, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 13:22:45'),
(67, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'Accès au tableau du medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 13:32:45'),
(68, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'Accès au tableau du medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 13:32:57'),
(69, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 13:33:11'),
(70, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 13:35:57'),
(71, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 13:35:57'),
(72, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 13:36:03'),
(73, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 13:36:13'),
(74, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'Accès au tableau du medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 13:36:18'),
(75, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', 'bmieqasq6djq1us715ebpj3lbl', NULL, '2025-08-05 13:36:55'),
(76, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', 'bmieqasq6djq1us715ebpj3lbl', NULL, '2025-08-05 13:37:01'),
(77, 2, 'dr_martin', 'consultation', 'historique_consultations.php', 'Accès à historique medicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 13:37:29'),
(78, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 13:38:20'),
(79, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 13:48:37'),
(80, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'Accès au tableau du medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', 'bmieqasq6djq1us715ebpj3lbl', NULL, '2025-08-05 15:28:47'),
(81, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'Accès au tableau du medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', 'bmieqasq6djq1us715ebpj3lbl', NULL, '2025-08-05 15:28:50'),
(82, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'Accès au tableau du medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', 'bmieqasq6djq1us715ebpj3lbl', NULL, '2025-08-05 15:28:52'),
(83, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Accès à la liste des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', 'bmieqasq6djq1us715ebpj3lbl', NULL, '2025-08-05 15:28:53'),
(84, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'Accès au tableau du medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', 'bmieqasq6djq1us715ebpj3lbl', NULL, '2025-08-05 15:29:29'),
(85, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'Accès au tableau du medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', 'bmieqasq6djq1us715ebpj3lbl', NULL, '2025-08-05 15:29:30'),
(86, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 15:31:01'),
(87, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'Accès au tableau du medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 15:56:58'),
(88, 2, 'dr_martin', 'consultation', 'historique_patients.php', 'Accès à historique patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-05 15:57:00'),
(89, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:10:29'),
(90, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:12:22'),
(91, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'Accès au tableau du medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:12:35'),
(92, 2, 'dr_martin', 'consultation', 'historique_consultations.php', 'Accès à historique medicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:12:46'),
(93, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'Accès au tableau du medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:12:47'),
(94, 2, 'dr_martin', 'consultation', 'historique_consultations.php', 'Accès à historique medicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:12:49'),
(95, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'Accès au tableau du medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:12:51'),
(96, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'Accès au tableau du medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:13:00'),
(97, 2, 'dr_martin', 'consultation', 'historique_consultations.php', 'Accès à historique medicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:13:05'),
(98, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:13:19'),
(99, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:21:41'),
(100, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:31:21'),
(101, 27, 'Aujou', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:35:34'),
(102, 27, 'Aujou', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:35:39'),
(103, 27, 'Aujou', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:35:39'),
(104, 27, 'Aujou', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:35:39'),
(105, 27, 'Aujou', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:36:00'),
(106, 27, 'Aujou', 'consultation', 'ajouter_patient.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:36:00'),
(107, 27, 'Aujou', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:36:00'),
(108, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:36:15'),
(109, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:47:20'),
(110, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:47:22'),
(111, 27, 'Aujou', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:48:56'),
(112, 27, 'Aujou', 'consultation', 'historique_patients.php', 'Accès à historique patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:48:58'),
(113, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:49:22'),
(114, 27, 'Aujou', 'modification', 'modifier_patient.php', 'Patient:  (ID: ) - Informations mises à jour', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:49:34'),
(115, 27, 'Aujou', 'consultation', 'historique_patients.php', 'Accès à historique patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:59:33'),
(116, 27, 'Aujou', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:59:38'),
(117, 27, 'Aujou', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:59:38'),
(118, 27, 'Aujou', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 07:59:38'),
(119, 27, 'Aujou', 'consultation', 'ajouter_patient.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:00:08'),
(120, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:00:48'),
(121, 27, 'Aujou', 'modification', 'modifier_patient.php', 'Patient:  (ID: ) - Informations mises à jour', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:00:59'),
(122, 27, 'Aujou', 'consultation', 'historique_patients.php', 'Accès à historique patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:01:01'),
(123, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:05:47'),
(124, 27, 'Aujou', 'consultation', 'supprimer_patient.php', 'Accès a la suppression patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:05:57'),
(125, 27, 'Aujou', 'suppression', 'supprimer_patient.php', 'Patient: Benie LMk (ID: 56) - Patient supprimé avec succès', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:05:57'),
(126, 27, 'Aujou', 'creation', 'supprimer_patient.php', 'Suppression du patient ID 56 : Benie LMk', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:05:57'),
(127, 27, 'Aujou', 'consultation', 'historique_patients.php', 'Accès à historique patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:06:02'),
(128, 27, 'Aujou', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:07:13'),
(129, 27, 'Aujou', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:07:14'),
(130, 27, 'Aujou', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:07:15'),
(131, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:10:54'),
(132, 27, 'Aujou', 'modification', 'modifier_patient.php', 'Patient: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 44) - Patient modifié', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:11:12'),
(133, 27, 'Aujou', 'modification', 'modifier_patient.php', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 44)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:11:12'),
(134, 27, 'Aujou', 'consultation', 'historique_patients.php', 'Accès à historique patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:11:17'),
(135, 27, 'Aujou', 'consultation', 'historique_consultations.php', 'Accès à historique medicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:11:34'),
(136, 27, 'Aujou', 'consultation', 'supprimer_patient.php', 'Accès a la suppression patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:11:49'),
(137, 27, 'Aujou', 'suppression', 'supprimer_patient.php', 'Patient: Mac Oba (ID: 55) - Patient supprimé avec succès', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:11:49'),
(138, 27, 'Aujou', 'suppression', 'supprimer_patient.php', 'Suppression du patient ID 55 : Mac Oba', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:11:49'),
(139, 27, 'Aujou', 'suppression', 'supprimer_patient.php', 'Patient: Mac Oba (ID: 55) - Patient supprimé avec succès', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:11:49'),
(140, 27, 'Aujou', 'creation', 'supprimer_patient.php', 'Suppression du patient ID 55 : Mac Oba', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:11:49'),
(141, 1, 'admin', 'consultation', 'dashboard_admin.php', 'Accès au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:14:44'),
(142, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:52:36'),
(143, 27, 'Aujou', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:52:38'),
(144, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:52:42'),
(145, 27, 'Aujou', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:52:44'),
(146, 27, 'Aujou', 'consultation', 'historique_patients.php', 'Consulte l\'historique des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:52:47'),
(147, 27, 'Aujou', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:52:52'),
(148, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:53:07'),
(149, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:54:31'),
(150, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:54:31'),
(151, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:55:11'),
(152, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:55:11'),
(153, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 08:55:13'),
(154, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:14:48'),
(155, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:26:55'),
(156, 27, 'Aujou', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:26:58'),
(157, 27, 'Aujou', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:27:03'),
(158, 27, 'Aujou', 'consultation', 'historique_patients.php', 'Consulte l\'historique des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:30:45'),
(159, 27, 'Aujou', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:30:48'),
(160, 27, 'Aujou', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:31:11'),
(161, 27, 'Aujou', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:32:24'),
(162, 27, 'Aujou', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:33:26'),
(163, 27, 'Aujou', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:33:26'),
(164, 27, 'Aujou', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:33:26'),
(165, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:34:53'),
(166, 27, 'Aujou', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:37:02'),
(167, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:37:52'),
(168, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:39:23'),
(169, 27, 'Aujou', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:40:08'),
(170, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:44:23'),
(171, 27, 'Aujou', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:44:38'),
(172, 27, 'Aujou', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:44:42'),
(173, 27, 'Aujou', 'consultation', 'ajouter_observation.php', 'Accès à ajouter observation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:45:03'),
(174, 27, 'Aujou', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:46:16'),
(175, 27, 'Aujou', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:46:28'),
(176, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:46:40');
INSERT INTO `user_activity` (`id`, `id_utilisateur`, `username`, `action_type`, `page_visitee`, `details_action`, `adresse_ip`, `user_agent`, `session_id`, `duree_session`, `date_action`) VALUES
(177, 27, 'Aujou', 'consultation', 'ajouter_observation.php', 'Accès à ajouter observation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:52:52'),
(178, 27, 'Aujou', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:53:14'),
(179, 27, 'Aujou', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:53:18'),
(180, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:53:41'),
(181, 27, 'Aujou', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:53:48'),
(182, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:55:32'),
(183, 27, 'Aujou', 'consultation', 'historique_patients.php', 'Consulte l\'historique des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:56:06'),
(184, 27, 'Aujou', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:58:56'),
(185, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 09:59:08'),
(186, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 10:02:55'),
(187, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 10:04:10'),
(188, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 10:04:10'),
(189, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 10:11:53'),
(190, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 10:11:53'),
(191, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 10:11:53'),
(192, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: error=Email+d%C3%A9j%C3%A0+utilis%C3%A9', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 10:11:53'),
(193, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'mc77k7u77kn26rq4iv3fgu4r8j', NULL, '2025-08-06 11:33:08'),
(194, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 07:40:48'),
(195, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:03:26'),
(196, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:03:26'),
(197, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:03:39'),
(198, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:03:39'),
(199, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:03:39'),
(200, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:03:41'),
(201, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:50:30'),
(202, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:50:30'),
(203, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:50:40'),
(204, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:50:40'),
(205, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: error=Email+d%C3%A9j%C3%A0+utilis%C3%A9', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:50:40'),
(206, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:50:42'),
(207, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:50:49'),
(208, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:51:09'),
(209, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:51:22'),
(210, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: error=Erreur+lors+de+l%27ajout', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:51:22'),
(211, 1, 'admin', 'consultation', 'supprimer_medecin.php', 'Supprimer un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:51:33'),
(212, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:51:40'),
(213, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:51:40'),
(214, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:51:52'),
(215, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:51:52'),
(216, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:51:52'),
(217, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:51:53'),
(218, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:52:04'),
(219, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:52:27'),
(220, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: error=Email+d%C3%A9j%C3%A0+utilis%C3%A9', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:52:27'),
(221, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:53:39'),
(222, 1, 'admin', 'consultation', 'supprimer_medecin.php', 'Supprimer un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:53:53'),
(223, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:54:02'),
(224, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:54:02'),
(225, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:54:14'),
(226, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:54:14'),
(227, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 08:54:14'),
(228, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 09:00:17'),
(229, 1, 'admin', 'consultation', 'modifier_medecin.php', 'Est entrer dans la page modifier medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 09:00:22'),
(230, 1, 'admin', 'consultation', 'supprimer_medecin.php', 'Supprimer un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 09:01:08'),
(231, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 09:01:12'),
(232, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 09:01:12'),
(233, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 09:41:29'),
(234, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 09:44:17'),
(235, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:17:49'),
(236, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:27:00'),
(237, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:27:01'),
(238, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:27:01'),
(239, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:27:15'),
(240, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:27:15'),
(241, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:27:15'),
(242, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:28:22'),
(243, 1, 'admin', 'consultation', 'supprimer_medecin.php', 'Supprimer un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:28:27'),
(244, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:41:50'),
(245, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:44:03'),
(246, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:44:05'),
(247, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:44:07'),
(248, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:44:07'),
(249, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:44:34'),
(250, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:44:43'),
(251, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:44:43'),
(252, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:44:43'),
(253, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:45:11'),
(254, 1, 'admin', 'consultation', 'supprimer_medecin.php', 'Supprimer un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:45:17'),
(255, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:48:18'),
(256, 27, 'Aujou', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:48:20'),
(257, 27, 'Aujou', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:48:21'),
(258, 27, 'Aujou', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:48:21'),
(259, 27, 'Aujou', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:48:21'),
(260, 27, 'Aujou', 'consultation', 'ajouter_patient.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:48:32'),
(261, 27, 'Aujou', 'consultation', 'historique_patients.php', 'Consulte l\'historique des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:48:34'),
(262, 27, 'Aujou', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:48:49'),
(263, 27, 'Aujou', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:48:55'),
(264, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:49:06'),
(265, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:49:15'),
(266, 27, 'Aujou', 'consultation', 'supprimer_patient.php', 'Accès a la suppression patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:49:21'),
(267, 27, 'Aujou', 'suppression', 'supprimer_patient.php', 'Patient: Benie LMk (ID: 57) - Patient supprimé avec succès', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:49:21'),
(268, 27, 'Aujou', 'suppression', 'supprimer_patient.php', 'Suppression du patient ID 57 : Benie LMk', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:49:21'),
(269, 27, 'Aujou', 'suppression', 'supprimer_patient.php', 'Patient: Benie LMk (ID: 57) - Patient supprimé avec succès', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:49:21'),
(270, 27, 'Aujou', 'creation', 'supprimer_patient.php', 'Suppression du patient ID 57 : Benie LMk', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 10:49:21'),
(271, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:07:43'),
(272, 27, 'Aujou', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:07:44'),
(273, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:07:47'),
(274, 27, 'Aujou', 'consultation', 'supprimer_patient.php', 'Accès a la suppression patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:07:53'),
(275, 27, 'Aujou', 'suppression', 'supprimer_patient.php', 'Patient: Mac Malocha (ID: 54) - Patient supprimé avec succès', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:07:53'),
(276, 27, 'Aujou', 'suppression', 'supprimer_patient.php', 'Patient: Mac Malocha (ID: 54) - Patient supprimé avec succès', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:07:53'),
(277, 27, 'Aujou', 'creation', 'supprimer_patient.php', 'Suppression du patient ID 54 : Mac Malocha', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:07:53'),
(278, 27, 'Aujou', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:07:57'),
(279, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:08:08'),
(280, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:28:38'),
(281, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:28:38'),
(282, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:28:55'),
(283, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:28:55'),
(284, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:28:55'),
(285, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:28:57'),
(286, 1, 'admin', 'consultation', 'supprimer_medecin.php', 'Supprimer un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:29:02'),
(287, 1, 'admin', 'consultation', 'supprimer_medecin.php', 'Supprimer un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:30:09'),
(288, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:30:09'),
(289, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:30:24'),
(290, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:30:24'),
(291, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:30:34'),
(292, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:30:34'),
(293, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:30:34'),
(294, 1, 'admin', 'consultation', 'modifier_medecin.php', 'Est entrer dans la page modifier medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:31:04'),
(295, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:31:10'),
(296, 1, 'admin', 'consultation', 'supprimer_medecin.php', 'Supprimer un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:31:31'),
(297, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:36:39'),
(298, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:36:39'),
(299, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:36:48'),
(300, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:36:48'),
(301, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:36:48'),
(302, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:36:56'),
(303, 1, 'admin', 'consultation', 'supprimer_medecin.php', 'Supprimer un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 11:37:09'),
(304, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:02:14'),
(305, 27, 'Aujou', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:02:17'),
(306, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:02:24'),
(307, 27, 'Aujou', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:02:31'),
(308, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:04:26'),
(309, 27, 'Aujou', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:04:28'),
(310, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:07:53'),
(311, 27, 'Aujou', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:07:55'),
(312, 27, 'Aujou', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:08:14'),
(313, 27, 'Aujou', 'consultation', 'ajouter_observation.php', 'Accès à ajouter observation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:08:29'),
(314, 27, 'Aujou', 'consultation', 'ajouter_observation.php', 'Accès à ajouter observation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:10:39'),
(315, 27, 'Aujou', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:10:41'),
(316, 27, 'Aujou', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:11:01'),
(317, 27, 'Aujou', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:14:58'),
(318, 27, 'Aujou', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:16:15'),
(319, 27, 'Aujou', 'consultation', 'ajouter_observation.php', 'Accès à ajouter observation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:18:11'),
(320, 27, 'Aujou', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:18:14'),
(321, 27, 'Aujou', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:18:47'),
(322, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:18:58'),
(323, 27, 'Aujou', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:21:10'),
(324, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:21:20'),
(325, 27, 'Aujou', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:30:16'),
(326, 27, 'Aujou', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:34:03'),
(327, 27, 'Aujou', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:34:07'),
(328, 27, 'Aujou', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:35:40'),
(329, 27, 'Aujou', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 13:37:13'),
(330, 27, 'Aujou', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 14:57:24'),
(331, 27, 'Aujou', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 14:57:29'),
(332, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 14:58:56'),
(333, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 14:59:00'),
(334, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 14:59:46'),
(335, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 14:59:46'),
(336, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:00:01'),
(337, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:00:01'),
(338, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:00:01'),
(339, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:00:06'),
(340, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:00:16'),
(341, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:00:39'),
(342, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:01:21'),
(343, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:01:21'),
(344, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:01:21'),
(345, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: error=Email+d%C3%A9j%C3%A0+utilis%C3%A9', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:01:21'),
(346, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:01:22'),
(347, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:01:28'),
(348, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:02:15'),
(349, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:02:23'),
(352, 27, 'Aujou', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:05:17'),
(353, 27, 'Aujou', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:06:03'),
(354, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:07:34');
INSERT INTO `user_activity` (`id`, `id_utilisateur`, `username`, `action_type`, `page_visitee`, `details_action`, `adresse_ip`, `user_agent`, `session_id`, `duree_session`, `date_action`) VALUES
(355, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:07:37'),
(356, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:10:11'),
(357, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:10:15'),
(358, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:10:30'),
(359, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:10:30'),
(360, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:10:57'),
(361, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:10:57'),
(362, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: error=Le+mot+de+passe+doit+contenir+au+moins+8+caract%C3%A8res.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:10:57'),
(363, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:11:13'),
(364, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:11:29'),
(365, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: error=Email+d%C3%A9j%C3%A0+utilis%C3%A9', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:11:29'),
(366, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:11:30'),
(367, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:11:36'),
(368, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:11:36'),
(369, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:12:00'),
(370, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:12:00'),
(371, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: error=Le+mot+de+passe+doit+contenir+au+moins+8+caract%C3%A8res.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:12:01'),
(372, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:12:29'),
(373, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:13:56'),
(374, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:25:36'),
(375, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:26:31'),
(376, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:32:27'),
(377, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:32:36'),
(378, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:32:51'),
(379, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:32:54'),
(380, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:33:00'),
(381, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:33:00'),
(382, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:47:58'),
(383, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:47:58'),
(384, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:47:58'),
(385, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: error=Email+d%C3%A9j%C3%A0+utilis%C3%A9', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:47:58'),
(386, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:48:00'),
(387, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:53:39'),
(388, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:53:40'),
(389, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:53:40'),
(390, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:54:24'),
(391, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:54:24'),
(392, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: error=Email+d%C3%A9j%C3%A0+utilis%C3%A9', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:54:24'),
(393, 1, 'admin', 'consultation', 'supprimer_medecin.php', 'Supprimer un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:54:50'),
(394, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:54:50'),
(395, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:54:52'),
(396, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:54:52'),
(397, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:55:09'),
(398, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:55:09'),
(399, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 15:56:35'),
(400, 1, 'admin', 'consultation', 'modifier_medecin.php', 'Est entrer dans la page modifier medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:01:18'),
(401, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:01:37'),
(402, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:02:23'),
(403, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:02:23'),
(404, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:02:35'),
(405, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:02:35'),
(406, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:02:35'),
(407, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:02:39'),
(408, 1, 'admin', 'consultation', 'supprimer_medecin.php', 'Supprimer un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:02:44'),
(409, 1, 'admin', 'consultation', 'modifier_medecin.php', 'Est entrer dans la page modifier medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:02:48'),
(410, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:10:57'),
(411, 1, 'admin', 'consultation', 'modifier_medecin.php', 'Est entrer dans la page modifier medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:10:59'),
(412, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:11:38'),
(413, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:11:46'),
(414, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:12:05'),
(415, 2, 'dr_martin', 'modification', 'modifier_patient.php', 'Patient: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 44) - Patient modifié', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:12:11'),
(416, 2, 'dr_martin', 'modification', 'modifier_patient.php', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 44)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:12:11'),
(417, 2, 'dr_martin', 'modification', 'modifier_patient.php', 'Patient: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 44) - Patient modifié', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:15:18'),
(418, 2, 'dr_martin', 'modification', 'modifier_patient.php', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 44)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:15:18'),
(419, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:15:18'),
(420, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:15:23'),
(421, 2, 'dr_martin', 'modification', 'modifier_patient.php', 'Patient: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 44) - Patient modifié', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:17:32'),
(422, 2, 'dr_martin', 'modification', 'modifier_patient.php', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 44)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:17:32'),
(423, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:17:32'),
(424, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:20:03'),
(425, 2, 'dr_martin', 'consultation', 'supprimer_patient.php', 'Accès a la suppression patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:20:09'),
(426, 2, 'dr_martin', 'suppression', 'supprimer_patient.php', 'Patient: Niambi Edmée Anne-Marie (ID: 53) - Patient est entrain d\'etre supprimer', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:20:09'),
(427, 2, 'dr_martin', 'suppression', 'supprimer_patient.php', 'Patient: Niambi Edmée Anne-Marie (ID: 53) - Patient supprimé avec succès', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:20:09'),
(428, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:20:37'),
(429, 2, 'dr_martin', 'modification', 'modifier_patient.php', 'Patient: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 44) - Patient modifié', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:21:01'),
(430, 2, 'dr_martin', 'modification', 'modifier_patient.php', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 44)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:21:01'),
(431, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:21:58'),
(432, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:21:58'),
(433, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:21:58'),
(434, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:22:08'),
(435, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:22:16'),
(436, 2, 'dr_martin', 'consultation', 'supprimer_patient.php', 'Accès a la suppression patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:22:21'),
(437, 2, 'dr_martin', 'suppression', 'supprimer_patient.php', 'Patient: Benie LMk (ID: 58) - Patient est entrain d\'etre supprimer', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:22:21'),
(438, 2, 'dr_martin', 'suppression', 'supprimer_patient.php', 'Patient: Benie LMk (ID: 58) - Patient supprimé avec succès', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:22:21'),
(439, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:22:26'),
(440, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:27:06'),
(441, 2, 'dr_martin', 'modification', 'modifier_patient.php', 'Patient: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 44) - Patient modifié', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:27:18'),
(442, 2, 'dr_martin', 'modification', 'modifier_patient.php', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 44)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:27:18'),
(443, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:27:48'),
(444, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:32:40'),
(445, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:32:41'),
(446, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:32:41'),
(447, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:32:41'),
(448, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:32:44'),
(449, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:32:59'),
(450, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:33:02'),
(451, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:33:02'),
(452, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:33:54'),
(453, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:35:30'),
(454, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:35:30'),
(455, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:36:11'),
(456, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'm0slcnk0qthhge6hl37nb68mkv', NULL, '2025-08-07 16:36:13'),
(457, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:05:39'),
(458, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:25:59'),
(459, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:26:01'),
(460, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:26:14'),
(461, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:26:54'),
(462, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:26:54'),
(463, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:27:21'),
(464, 1, 'admin', 'consultation', 'supprimer_medecin.php', 'Supprimer un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:27:31'),
(465, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:27:34'),
(466, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:28:21'),
(467, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:28:21'),
(468, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:28:21'),
(469, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:28:21'),
(470, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:28:26'),
(471, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:38:30'),
(472, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:38:33'),
(473, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:38:35'),
(474, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:38:35'),
(475, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:38:35'),
(476, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:45:54'),
(477, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:45:54'),
(478, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:45:54'),
(479, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:47:15'),
(480, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:47:15'),
(481, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:47:15'),
(482, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:47:20'),
(483, 2, 'dr_martin', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:47:26'),
(484, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:50:46'),
(485, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:50:46'),
(486, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:50:46'),
(487, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:50:53'),
(488, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 07:55:34'),
(489, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:11:51'),
(490, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:11:53'),
(491, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:13:40'),
(492, 2, 'dr_martin', 'modification', 'modifier_patient.php', 'Patient: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 44) - Patient modifié', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:14:10'),
(493, 2, 'dr_martin', 'modification', 'modifier_patient.php', 'Patient modifié: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 44)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:14:10'),
(494, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:14:10'),
(495, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:14:19'),
(496, 2, 'dr_martin', 'creation', 'consultation.php', 'Nouvelle consultation pour KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID patient: 44)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:14:57'),
(497, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:18:15'),
(498, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:18:20'),
(499, 2, 'dr_martin', 'creation', 'consultation.php', 'Nouvelle consultation pour KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID patient: 44)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:18:24'),
(500, 2, 'dr_martin', 'creation', 'consultation.php', 'Nouvelle consultation pour KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID patient: 44)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:19:00'),
(501, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:19:20'),
(502, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:24:50'),
(503, 2, 'dr_martin', 'creation', 'consultation.php', 'Nouvelle consultation pour KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID patient: 44)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:24:58'),
(504, 2, 'dr_martin', 'creation', 'consultation.php', 'Nouvelle consultation pour KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID patient: 44)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:25:10'),
(505, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:27:39'),
(506, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:29:08'),
(507, 2, 'dr_martin', 'creation', 'ordonnance.php', 'Ordonnance créée: dfs pour KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID ordonnance: 57)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:29:19'),
(508, 2, 'dr_martin', 'creation', 'ordonnance.php', 'Ordonnance créée: dfs pour KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID ordonnance: 58)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:29:34'),
(509, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:34:21'),
(510, 2, 'dr_martin', 'creation', 'ordonnance.php', 'Ordonnance créée: dsg pour KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID ordonnance: 59)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:34:26'),
(511, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:35:39'),
(512, 2, 'dr_martin', 'creation', 'ordonnance.php', 'Ordonnance créée: sdgs pour KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID ordonnance: 60)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:35:46'),
(513, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:38:46'),
(514, 2, 'dr_martin', 'creation', 'ordonnance.php', 'Ordonnance créée: sqfqd pour KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID ordonnance: 61)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:38:53'),
(515, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:40:46'),
(516, 2, 'dr_martin', 'creation', 'ordonnance.php', 'Ordonnance créée: h,ghg pour KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID ordonnance: 62)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:40:54'),
(517, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:43:25'),
(518, 2, 'dr_martin', 'creation', 'ordonnance.php', 'Ordonnance créée: zgfrg pour KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID ordonnance: 63)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:43:31'),
(519, 2, 'dr_martin', 'consultation', 'voir_ordonance.php', 'Consulte une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 08:48:41'),
(520, 2, 'dr_martin', 'consultation', 'ajouter_observation.php', 'Accès à ajouter observation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:00:11'),
(521, 2, 'dr_martin', 'consultation', 'bon_examen.php', 'A été sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:01:56'),
(522, 2, 'dr_martin', 'consultation', 'enregistrer_bon_examen.php', 'A Crée sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:02:00'),
(523, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:02:00'),
(524, 2, 'dr_martin', 'consultation', 'bon_examen.php', 'A été sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:05:24'),
(525, 2, 'dr_martin', 'consultation', 'enregistrer_bon_examen.php', 'A Crée sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:05:30');
INSERT INTO `user_activity` (`id`, `id_utilisateur`, `username`, `action_type`, `page_visitee`, `details_action`, `adresse_ip`, `user_agent`, `session_id`, `duree_session`, `date_action`) VALUES
(526, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:09:04'),
(527, 1, 'admin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:09:21'),
(528, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:09:22'),
(529, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:10:46'),
(530, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:17:08'),
(531, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:17:18'),
(532, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:19:02'),
(533, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:20:52'),
(534, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:20:52'),
(535, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:20:52'),
(536, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:30:02'),
(537, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:30:44'),
(538, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:31:17'),
(539, 2, 'dr_martin', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:31:30'),
(540, 2, 'dr_martin', 'consultation', 'historique_patients.php', 'Consulte l\'historique des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:31:38'),
(541, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:31:48'),
(542, 1, 'admin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:32:55'),
(543, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:32:55'),
(544, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:32:59'),
(545, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:32:59'),
(546, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:33:45'),
(547, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:33:51'),
(548, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:35:03'),
(549, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:41:52'),
(550, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:41:57'),
(551, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:41:57'),
(552, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:42:00'),
(553, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:42:26'),
(554, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:44:18'),
(555, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:44:18'),
(556, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:44:18'),
(557, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: error=Le+mot+de+passe+doit+contenir+au+moins+8+caract%C3%A8res.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:44:18'),
(558, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:44:54'),
(559, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: error=Adresse+email+invalide.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:44:54'),
(560, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:45:21'),
(561, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:45:21'),
(562, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:45:21'),
(563, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:45:55'),
(564, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: error=Le+num%C3%A9ro+doit+%C3%AAtre+au+format+congolais+%28%2B242+suivi+de+9+chiffres%29.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:45:55'),
(565, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:50:00'),
(566, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:50:00'),
(567, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:50:00'),
(568, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: error=Num%C3%A9ro+de+t%C3%A9l%C3%A9phone+invalide.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:50:00'),
(569, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:51:39'),
(570, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:51:39'),
(571, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:51:39'),
(572, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: error=T%C3%A9l%C3%A9phone+d%C3%A9j%C3%A0+utilis%C3%A9.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:51:39'),
(573, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:53:49'),
(574, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:53:49'),
(575, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:53:50'),
(576, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:53:50'),
(577, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:54:40'),
(578, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:55:57'),
(579, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:55:57'),
(580, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:57:08'),
(581, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:57:08'),
(582, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:57:08'),
(583, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 09:57:08'),
(584, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:00:26'),
(585, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:02:06'),
(586, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:02:10'),
(587, 42, 'GOALA Farild', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:05:58'),
(588, 42, 'GOALA Farild', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:09:32'),
(589, 42, 'GOALA Farild', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:09:32'),
(590, 42, 'GOALA Farild', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:09:32'),
(591, 42, 'GOALA Farild', 'consultation', 'ajouter_patient_traitement.php', 'A ajouté un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:11:38'),
(592, 42, 'GOALA Farild', '', 'ajouter_patient_traitement.php', 'Patient: NKOUNKOU Prince (ID: 60) - Ajout du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:11:38'),
(593, 42, 'GOALA Farild', 'creation', 'ajouter_patient_traitement.php', 'Patient créé: NKOUNKOU Prince (ID: 60)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:11:38'),
(594, 42, 'GOALA Farild', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:11:38'),
(595, 42, 'GOALA Farild', 'consultation', 'ajouter_patient.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:11:38'),
(596, 42, 'GOALA Farild', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:11:38'),
(597, 42, 'GOALA Farild', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:11:44'),
(598, 42, 'GOALA Farild', 'consultation', 'historique_patients.php', 'Consulte l\'historique des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:12:04'),
(599, 42, 'GOALA Farild', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:12:11'),
(600, 42, 'GOALA Farild', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:14:53'),
(601, 42, 'GOALA Farild', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:15:11'),
(602, 42, 'GOALA Farild', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:19:10'),
(603, 42, 'GOALA Farild', 'creation', 'consultation.php', 'Nouvelle consultation pour NKOUNKOU Prince (ID patient: 60)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:19:10'),
(604, 42, 'GOALA Farild', 'consultation', 'ajouter_observation.php', 'Accès à ajouter observation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:21:49'),
(605, 42, 'GOALA Farild', 'consultation', 'bon_examen.php', 'A été sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:22:27'),
(606, 42, 'GOALA Farild', 'consultation', 'enregistrer_bon_examen.php', 'A Crée sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:28:55'),
(607, 42, 'GOALA Farild', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:33:26'),
(608, 42, 'GOALA Farild', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:48:20'),
(609, 42, 'GOALA Farild', 'creation', 'ordonnance.php', 'Ordonnance créée: -Paracetamole 500mg\r\n-Dolipranne 400mg\r\n-jfjkgkgblglg\r\n-jfkifklvglkkhb\r\n-kfgjgjgkgk-\r\n,gfjghjkghjkhkhkh\r\n-jkgikgjghkghkhkh\r\n-khkihjhljhkljolkl pour NKOUNKOU Prince (ID ordonnance: 64)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:48:20'),
(610, 42, 'GOALA Farild', 'consultation', 'voir_ordonance.php', 'Consulte une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:48:28'),
(611, 42, 'GOALA Farild', 'consultation', 'generer_ordonnance.php', 'Est rentrer dans la page generer une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:48:39'),
(612, 42, 'GOALA Farild', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:49:31'),
(613, 42, 'GOALA Farild', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:50:53'),
(614, 42, 'GOALA Farild', 'creation', 'ordonnance.php', 'Ordonnance créée: jfdfhjfghjgjngfjhnjh\r\njhfguhhhhhhhhhhhhh\r\ndkkkkkkkkkkkkkkkkkk\r\nfffffffffffffffffffffffffffff\r\nbftguddddddddddddddd\r\nddddddddddddddddff\r\nujujujujujujujujujujujujujujujrt\r\ndfffffffffffffffffffffffffffffffffffffff\r\nduifffffffffffffffffffffffffffffffffff\r\noyiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii pour NKOUNKOU Prince (ID ordonnance: 65)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:50:53'),
(615, 42, 'GOALA Farild', 'creation', 'ordonnance.php', 'Ordonnance créée: jfdfhjfghjgjngfjhnjh\r\njhfguhhhhhhhhhhhhh\r\ndkkkkkkkkkkkkkkkkkk\r\nfffffffffffffffffffffffffffff\r\nbftguddddddddddddddd\r\nddddddddddddddddff\r\nujujujujujujujujujujujujujujujrt\r\ndfffffffffffffffffffffffffffffffffffffff\r\nduifffffffffffffffffffffffffffffffffff\r\noyiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii pour NKOUNKOU Prince (ID ordonnance: 66)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:51:10'),
(616, 42, 'GOALA Farild', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:51:13'),
(617, 42, 'GOALA Farild', 'consultation', 'voir_ordonance.php', 'Consulte une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:51:25'),
(618, 42, 'GOALA Farild', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:52:14'),
(619, 42, 'GOALA Farild', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:52:19'),
(620, 42, 'GOALA Farild', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:52:26'),
(621, 42, 'GOALA Farild', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:53:15'),
(622, 42, 'GOALA Farild', 'creation', 'ordonnance.php', 'Ordonnance créée: ,dnvvvvvvfbbbbbbbbbb\r\ndfhgggfhhhddgghdg\r\ndhsjfjdhjd\r\nfgfjdfgj\r\nfsgjdfjd\r\nfgjdfjd\r\nfdjdghj\r\ndfjdghj\r\nfgjdghj\r\ndgjdfhg pour NKOUNKOU Prince (ID ordonnance: 67)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:53:15'),
(623, 42, 'GOALA Farild', 'creation', 'ordonnance.php', 'Ordonnance créée: ,dnvvvvvvfbbbbbbbbbb\r\ndfhgggfhhhddgghdg\r\ndhsjfjdhjd\r\nfgfjdfgj\r\nfsgjdfjd\r\nfgjdfjd\r\nfdjdghj\r\ndfjdghj\r\nfgjdghj\r\ndgjdfhg pour NKOUNKOU Prince (ID ordonnance: 68)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:53:28'),
(624, 42, 'GOALA Farild', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:53:33'),
(625, 42, 'GOALA Farild', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:53:36'),
(626, 42, 'GOALA Farild', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:53:42'),
(627, 42, 'GOALA Farild', 'consultation', 'voir_ordonance.php', 'Consulte une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:54:02'),
(628, 42, 'GOALA Farild', 'consultation', 'generer_ordonnance.php', 'Est rentrer dans la page generer une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:54:09'),
(629, 42, 'GOALA Farild', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:54:43'),
(630, 42, 'GOALA Farild', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:55:15'),
(631, 42, 'GOALA Farild', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:55:16'),
(632, 42, 'GOALA Farild', 'consultation', 'historique_patients.php', 'Consulte l\'historique des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:55:31'),
(633, 42, 'GOALA Farild', 'modification', 'modifier_patient.php', 'Patient: NKOUNKOU Prince (ID: 60) - Patient modifié', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:56:53'),
(634, 42, 'GOALA Farild', 'modification', 'modifier_patient.php', 'Patient modifié: NKOUNKOU Prince (ID: 60)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:56:53'),
(635, 42, 'GOALA Farild', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:56:53'),
(636, 42, 'GOALA Farild', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:57:37'),
(637, 42, 'GOALA Farild', 'consultation', 'supprimer_patient.php', 'Accès a la suppression patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:57:47'),
(638, 42, 'GOALA Farild', 'suppression', 'supprimer_patient.php', 'Patient: premier Achera (ID: 46) - Patient est entrain d\'etre supprimer', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:57:47'),
(639, 42, 'GOALA Farild', 'suppression', 'supprimer_patient.php', 'Patient: premier Achera (ID: 46) - Patient supprimé avec succès', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:57:47'),
(640, 42, 'GOALA Farild', 'consultation', 'historique_patients.php', 'Consulte l\'historique des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:58:29'),
(641, 42, 'GOALA Farild', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:58:34'),
(642, 20, 'Jojo', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:59:21'),
(643, 20, 'Jojo', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 10:59:45'),
(644, 20, 'Jojo', 'consultation', 'supprimer_patient.php', 'Accès a la suppression patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:00:02'),
(645, 20, 'Jojo', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:01:00'),
(646, 20, 'Jojo', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:01:48'),
(647, 20, 'Jojo', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:02:16'),
(648, 20, 'Jojo', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:02:16'),
(649, 20, 'Jojo', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:02:16'),
(650, 20, 'Jojo', 'consultation', 'ajouter_patient_traitement.php', 'A ajouté un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:04:05'),
(651, 20, 'Jojo', '', 'ajouter_patient_traitement.php', 'Patient: Ebara Beni (ID: 61) - Ajout du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:04:05'),
(652, 20, 'Jojo', 'creation', 'ajouter_patient_traitement.php', 'Patient créé: Ebara Beni (ID: 61)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:04:05'),
(653, 20, 'Jojo', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:04:05'),
(654, 20, 'Jojo', 'consultation', 'ajouter_patient.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:04:05'),
(655, 20, 'Jojo', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:04:05'),
(656, 20, 'Jojo', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:04:08'),
(657, 20, 'Jojo', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:04:09'),
(658, 20, 'Jojo', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:04:32'),
(659, 20, 'Jojo', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:04:40'),
(660, 20, 'Jojo', 'creation', 'consultation.php', 'Nouvelle consultation pour Ebara Beni (ID patient: 61)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:05:10'),
(661, 20, 'Jojo', 'consultation', 'ajouter_observation.php', 'Accès à ajouter observation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:05:17'),
(662, 20, 'Jojo', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:05:36'),
(663, 20, 'Jojo', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:05:39'),
(664, 20, 'Jojo', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:06:39'),
(665, 20, 'Jojo', 'creation', 'ordonnance.php', 'Ordonnance créée: Pacacétamole pour Ebara Beni (ID ordonnance: 69)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:07:36'),
(666, 20, 'Jojo', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:07:43'),
(667, 20, 'Jojo', 'creation', 'ordonnance.php', 'Ordonnance créée: Dolipranne pour Ebara Beni (ID ordonnance: 70)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:08:13'),
(668, 20, 'Jojo', 'consultation', 'bon_examen.php', 'A été sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:08:18'),
(669, 20, 'Jojo', 'consultation', 'enregistrer_bon_examen.php', 'A Crée sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:08:33'),
(670, 20, 'Jojo', 'consultation', 'voir_ordonance.php', 'Consulte une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:09:07'),
(671, 20, 'Jojo', 'consultation', 'generer_ordonnance.php', 'Est rentrer dans la page generer une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:09:13'),
(672, 20, 'Jojo', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:39:33'),
(673, 20, 'Jojo', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:39:33'),
(674, 20, 'Jojo', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:39:33'),
(675, 20, 'Jojo', 'consultation', 'ajouter_patient_traitement.php', 'A ajouté un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:40:38'),
(676, 20, 'Jojo', '', 'ajouter_patient_traitement.php', 'Patient: Kong King (ID: 62) - Ajout du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:40:38'),
(677, 20, 'Jojo', 'creation', 'ajouter_patient_traitement.php', 'Patient créé: Kong King (ID: 62)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:40:38'),
(678, 20, 'Jojo', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:40:38'),
(679, 20, 'Jojo', 'consultation', 'ajouter_patient.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:40:38'),
(680, 20, 'Jojo', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:40:38'),
(681, 20, 'Jojo', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:41:09'),
(682, 20, 'Jojo', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:41:17'),
(683, 1, 'admin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:41:19'),
(684, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:41:19'),
(685, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:41:23'),
(686, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:41:26'),
(687, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:41:26'),
(688, 2, 'dr_martin', 'consultation', 'historique_patients.php', 'Consulte l\'historique des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:41:35'),
(689, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:41:36'),
(690, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:43:33'),
(691, 2, 'dr_martin', 'consultation', 'historique_patients.php', 'Consulte l\'historique des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:43:38'),
(692, 2, 'dr_martin', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:43:41'),
(693, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:44:46');
INSERT INTO `user_activity` (`id`, `id_utilisateur`, `username`, `action_type`, `page_visitee`, `details_action`, `adresse_ip`, `user_agent`, `session_id`, `duree_session`, `date_action`) VALUES
(694, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:46:45'),
(695, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 11:47:53'),
(696, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 12:04:56'),
(697, 1, 'admin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 12:05:14'),
(698, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 12:05:14'),
(699, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 12:05:22'),
(700, 1, 'admin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 12:07:03'),
(701, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 12:07:03'),
(702, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 12:07:14'),
(703, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 12:07:14'),
(704, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 12:07:21'),
(705, 1, 'admin', 'consultation', 'modifier_medecin.php', 'Est entrer dans la page modifier medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 12:07:32'),
(706, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 12:12:22'),
(707, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 12:13:02'),
(708, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 12:13:02'),
(709, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 13:46:45'),
(710, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 13:46:45'),
(711, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 13:47:17'),
(712, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des medecins', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:02:35'),
(713, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:10:12'),
(714, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:10:12'),
(715, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:10:27'),
(716, 1, 'admin', 'consultation', 'ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:10:36'),
(717, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:11:45'),
(718, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:11:52'),
(719, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:11:52'),
(720, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:11:58'),
(721, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:11:58'),
(722, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:11:58'),
(723, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:14:18'),
(724, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:14:18'),
(725, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:14:18'),
(726, 2, 'dr_martin', 'consultation', 'ajouter_patient_traitement.php', 'A ajouté un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:14:36'),
(727, 2, 'dr_martin', '', 'ajouter_patient_traitement.php', 'Patient: Kong King (ID: 63) - Ajout du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:14:36'),
(728, 2, 'dr_martin', 'creation', 'ajouter_patient_traitement.php', 'Patient créé: Kong King (ID: 63)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:14:36'),
(729, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:14:36'),
(730, 2, 'dr_martin', '', 'ajouter_patient_traitement.php', 'Patient: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 64) - Ajout du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:15:08'),
(731, 2, 'dr_martin', 'creation', 'ajouter_patient_traitement.php', 'Patient créé: KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID: 64)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:15:08'),
(732, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:15:46'),
(733, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:15:46'),
(734, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:15:46'),
(735, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:18:29'),
(736, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:18:29'),
(737, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:18:29'),
(738, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:18:50'),
(739, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:21:02'),
(740, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:21:09'),
(741, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:21:09'),
(742, 2, 'dr_martin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:29:26'),
(743, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:29:26'),
(744, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:29:26'),
(745, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:29:35'),
(746, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:29:35'),
(747, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:29:35'),
(748, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:29:52'),
(749, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:29:59'),
(750, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:30:02'),
(751, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:32:01'),
(752, 2, 'dr_martin', 'creation', 'consultation.php', 'Nouvelle consultation pour KAMPAKOL OBANA MIYOULOU Marc-Jeremy (ID patient: 44)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:32:06'),
(753, 2, 'dr_martin', 'consultation', 'bon_examen.php', 'A été sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:32:59'),
(754, 2, 'dr_martin', 'consultation', 'enregistrer_bon_examen.php', 'A Crée sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:33:02'),
(755, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:33:15'),
(756, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:40:51'),
(757, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:40:58'),
(758, 2, 'dr_martin', 'consultation', 'bon_examen.php', 'A été sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:41:15'),
(759, 2, 'dr_martin', 'consultation', 'enregistrer_bon_examen.php', 'A Crée sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:41:19'),
(760, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:41:59'),
(761, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:45:52'),
(762, 2, 'dr_martin', 'consultation', 'bon_examen.php', 'A été sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:45:58'),
(763, 2, 'dr_martin', 'consultation', 'enregistrer_bon_examen.php', 'A Crée sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:46:01'),
(764, 2, 'dr_martin', 'consultation', 'bon_examen.php', 'A été sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:47:48'),
(765, 2, 'dr_martin', 'consultation', 'enregistrer_bon_examen.php', 'A Crée sur la page bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:47:50'),
(766, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:49:15'),
(767, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:49:18'),
(768, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:55:03'),
(769, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:56:22'),
(770, 2, 'dr_martin', 'creation', 'ordonnance.php', 'Ordonnance créée: Paracetamole \r\nDoliprane pour Miyoulou Malocha (ID ordonnance: 71)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:56:22'),
(771, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:56:28'),
(772, 2, 'dr_martin', 'consultation', 'voir_ordonance.php', 'Consulte une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:56:36'),
(773, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:57:40'),
(774, 2, 'dr_martin', 'creation', 'ordonnance.php', 'Ordonnance créée: Paracetamole pour Miyoulou Malocha (ID ordonnance: 72)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:58:07'),
(775, 2, 'dr_martin', 'consultation', 'voir_ordonance.php', 'Consulte une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:58:07'),
(776, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 14:58:37'),
(777, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:00:37'),
(778, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:00:41'),
(779, 2, 'dr_martin', 'consultation', 'voir_ordonance.php', 'Consulte une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:02:05'),
(780, 2, 'dr_martin', 'consultation', 'voir_ordonance.php', 'Consulte une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:12:12'),
(781, 2, 'dr_martin', 'consultation', 'voir_ordonance.php', 'Consulte une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:14:12'),
(782, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:14:31'),
(783, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:17:22'),
(784, 20, 'Jojo', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:17:52'),
(785, 20, 'Jojo', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:17:54'),
(786, 20, 'Jojo', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:18:10'),
(787, 20, 'Jojo', 'modification', 'modifier_patient.php', 'Patient: NKOUNKOU Prince (ID: 60) - Patient modifié', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:18:26'),
(788, 20, 'Jojo', 'modification', 'modifier_patient.php', 'Patient modifié: NKOUNKOU Prince (ID: 60)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:18:26'),
(789, 20, 'Jojo', 'modification', 'modifier_patient.php', 'Patient: Kong KingC (ID: 62) - Patient modifié', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:18:56'),
(790, 20, 'Jojo', 'modification', 'modifier_patient.php', 'Patient modifié: Kong KingC (ID: 62)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:18:56'),
(791, 20, 'Jojo', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:18:57'),
(792, 20, 'Jojo', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:20:00'),
(793, 20, 'Jojo', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:20:06'),
(794, 20, 'Jojo', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:24:25'),
(795, 20, 'Jojo', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:26:42'),
(796, 20, 'Jojo', 'modification', 'modifier_patient.php', 'Patient: Ebara Beni (ID: 61) - Patient modifié', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:27:25'),
(797, 20, 'Jojo', 'modification', 'modifier_patient.php', 'Patient modifié: Ebara Beni (ID: 61)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:27:25'),
(798, 20, 'Jojo', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:27:25'),
(799, 20, 'Jojo', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:27:44'),
(800, 20, 'Jojo', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:37:55'),
(801, 20, 'Jojo', 'consultation', 'supprimer_patient.php', 'Accès a la suppression patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:38:26'),
(802, 20, 'Jojo', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:40:47'),
(803, 2, 'dr_martin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:40:49'),
(804, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:40:49'),
(805, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:40:49'),
(806, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:40:54'),
(807, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:41:00'),
(808, 2, 'dr_martin', 'consultation', 'generer_bon_examen.php', 'Génération du PDF bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:54:29'),
(809, 2, 'dr_martin', 'consultation', 'generer_bon_examen.php', 'Génération du PDF bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 15:57:29'),
(810, 2, 'dr_martin', 'consultation', 'generer_bon_examen.php', 'Génération du PDF bon d\'examen', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 16:01:15'),
(811, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 16:01:55'),
(812, 2, 'dr_martin', 'consultation', 'voir_ordonance.php', 'Consulte une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 16:02:01'),
(813, 2, 'dr_martin', 'consultation', 'generer_ordonnance.php', 'Est rentrer dans la page generer une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 16:02:06'),
(814, 2, 'dr_martin', 'consultation', 'voir_ordonance.php', 'Consulte une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 16:07:04'),
(815, 2, 'dr_martin', 'consultation', 'generer_ordonnance.php', 'Génération d\'une ordonnance PDF', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 16:07:06'),
(816, 2, 'dr_martin', 'consultation', 'voir_ordonance.php', 'Consulte une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 16:18:18'),
(817, 2, 'dr_martin', 'consultation', 'generer_ordonnance.php', 'Génération ordonnance PDF', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'tai6h1hpsjjhb3204ft7cqgs63', NULL, '2025-08-08 16:18:20'),
(818, 2, 'dr_martin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '1jeisuvak0nteep774tir7v7ad', NULL, '2025-08-08 20:18:05'),
(819, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '1jeisuvak0nteep774tir7v7ad', NULL, '2025-08-08 20:18:05'),
(820, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '1jeisuvak0nteep774tir7v7ad', NULL, '2025-08-08 20:18:05'),
(821, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '1jeisuvak0nteep774tir7v7ad', NULL, '2025-08-08 20:18:59'),
(822, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '1jeisuvak0nteep774tir7v7ad', NULL, '2025-08-08 20:19:00'),
(823, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '1jeisuvak0nteep774tir7v7ad', NULL, '2025-08-08 20:19:00'),
(824, 2, 'dr_martin', 'consultation', 'ajouter_patient_traitement.php', 'A ajouté un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '1jeisuvak0nteep774tir7v7ad', NULL, '2025-08-08 20:20:32'),
(825, 2, 'dr_martin', '', 'ajouter_patient_traitement.php', 'Patient: OBANA Marc-Jeremy (ID: 65) - Ajout du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '1jeisuvak0nteep774tir7v7ad', NULL, '2025-08-08 20:20:32'),
(826, 2, 'dr_martin', 'creation', 'ajouter_patient_traitement.php', 'Patient créé: OBANA Marc-Jeremy (ID: 65)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '1jeisuvak0nteep774tir7v7ad', NULL, '2025-08-08 20:20:32'),
(827, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '1jeisuvak0nteep774tir7v7ad', NULL, '2025-08-08 20:20:32'),
(828, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '1jeisuvak0nteep774tir7v7ad', NULL, '2025-08-08 20:20:32'),
(829, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '1jeisuvak0nteep774tir7v7ad', NULL, '2025-08-08 20:20:32'),
(830, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '1jeisuvak0nteep774tir7v7ad', NULL, '2025-08-08 20:20:35'),
(831, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '1jeisuvak0nteep774tir7v7ad', NULL, '2025-08-08 20:21:02'),
(832, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '1jeisuvak0nteep774tir7v7ad', NULL, '2025-08-08 20:22:57'),
(833, 2, 'dr_martin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:10:36'),
(834, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:10:36'),
(835, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:10:36'),
(836, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:20:28'),
(837, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:20:32'),
(838, 2, 'dr_martin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:20:34'),
(839, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:20:34'),
(840, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:37:07'),
(841, 1, 'admin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:37:28'),
(842, 1, 'admin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:37:28'),
(843, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:37:28'),
(844, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:41:54'),
(845, 2, 'dr_martin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:41:57'),
(846, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:41:57'),
(847, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:41:57'),
(848, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:42:10'),
(849, 2, 'dr_martin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:43:49'),
(850, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:43:49'),
(851, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:43:49'),
(852, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:43:56'),
(853, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:44:01'),
(854, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:44:14'),
(855, 1, 'admin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:45:08'),
(856, 1, 'admin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:45:08'),
(857, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:45:08'),
(858, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:45:12'),
(859, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:45:20'),
(860, 2, 'dr_martin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:45:21'),
(861, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:45:21'),
(862, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:45:21'),
(863, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:45:24'),
(864, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:45:24'),
(865, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:45:24'),
(866, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:46:51'),
(867, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:46:58');
INSERT INTO `user_activity` (`id`, `id_utilisateur`, `username`, `action_type`, `page_visitee`, `details_action`, `adresse_ip`, `user_agent`, `session_id`, `duree_session`, `date_action`) VALUES
(868, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:47:01'),
(869, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', 'dpivitmbfkgd0dvvit9sd34ln6', NULL, '2025-08-09 09:49:02'),
(870, 2, 'dr_martin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:17:35'),
(871, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:17:35'),
(872, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:17:36'),
(873, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:17:36'),
(874, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:18:34'),
(875, 1, 'admin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:18:50'),
(876, 1, 'admin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:18:50'),
(877, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:18:50'),
(878, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:18:56'),
(879, 2, 'dr_martin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:18:58'),
(880, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:18:58'),
(881, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:18:58'),
(882, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:20:41'),
(883, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:24:13'),
(884, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:24:13'),
(885, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:24:13'),
(886, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:26:17'),
(887, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:26:17'),
(888, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:26:17'),
(889, 2, 'dr_martin', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:27:20'),
(890, 2, 'dr_martin', 'consultation', 'historique_patients.php', 'Consulte l\'historique des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:27:25'),
(891, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:27:32'),
(892, 1, 'admin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:27:45'),
(893, 1, 'admin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:27:45'),
(894, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:27:45'),
(895, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des utilisateurs', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:27:51'),
(896, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:47:42'),
(897, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:49:28'),
(898, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:49:28'),
(899, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:49:28'),
(900, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:50:11'),
(901, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des utilisateurs', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:50:15'),
(902, 1, 'admin', 'consultation', 'supprimer_medecin.php', 'Supprimer un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:51:08'),
(903, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:52:42'),
(904, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:52:57'),
(905, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:52:57'),
(906, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des utilisateurs', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:53:10'),
(907, 1, 'admin', 'consultation', 'supprimer_medecin.php', 'Supprimer un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:53:15'),
(908, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:53:45'),
(909, 1, 'admin', 'consultation', 'modifier_medecin.php', 'Est entrer dans la page modifier medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 07:53:51'),
(910, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des utilisateurs', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:24:56'),
(911, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:24:57'),
(912, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', 'A ajouté un medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:25:09'),
(913, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:25:09'),
(914, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:31:01'),
(915, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:31:12'),
(916, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des utilisateurs', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:31:28'),
(917, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des utilisateurs', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:35:22'),
(918, 1, 'admin', 'consultation', 'ajouter_medecin.php', 'Accès à ajouter medecin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:36:23'),
(919, 1, 'admin', 'consultation', 'traitement_ajouter_medecin.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:36:32'),
(920, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des utilisateurs', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:36:33'),
(921, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des utilisateurs', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:40:27'),
(922, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des utilisateurs', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:48:50'),
(923, 1, 'admin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:57:46'),
(924, 2, 'dr_martin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:57:47'),
(925, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:57:47'),
(926, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:57:47'),
(927, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:57:54'),
(928, 2, 'dr_martin', 'consultation', 'historique_patients.php', 'Consulte l\'historique des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:58:01'),
(929, 2, 'dr_martin', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:58:03'),
(930, 2, 'dr_martin', 'consultation', 'logout.php', 'C\'est déconnecté', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:58:09'),
(931, 1, 'admin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:58:25'),
(932, 1, 'admin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:58:25'),
(933, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 08:58:25'),
(934, 1, 'admin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 09:12:07'),
(935, 1, 'admin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 09:12:07'),
(936, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 09:12:07'),
(938, 1, 'admin', 'deconnexion', 'logout.php', 'Déconnexion effectuée', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', 251, '2025-08-11 09:16:18'),
(939, 1, 'admin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 09:16:33'),
(940, 1, 'admin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 09:16:33'),
(941, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 09:16:33'),
(942, 1, 'admin', 'consultation', 'liste_medecins.php', 'Accès à la liste des utilisateurs', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 09:16:36'),
(943, 1, 'admin', 'deconnexion', 'logout.php', 'Déconnexion effectuée', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', 40, '2025-08-11 09:17:13'),
(944, 2, 'dr_martin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 09:17:16'),
(945, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 09:17:16'),
(946, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 09:17:16'),
(947, 2, 'dr_martin', 'deconnexion', 'logout.php', 'Déconnexion effectuée', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', 5, '2025-08-11 09:17:21'),
(948, 1, 'admin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 09:17:31'),
(949, 1, 'admin', 'consultation', 'dashboard_admin.php', 'A accedé au tableau de bord Administrateur', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-11 14:01:37'),
(950, 1, 'admin', 'deconnexion', 'logout.php', 'Déconnexion effectuée', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', 17058, '2025-08-11 14:01:48'),
(951, 2, 'dr_martin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:35:24'),
(952, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:35:24'),
(953, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:35:24'),
(954, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:35:34'),
(955, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:35:34'),
(956, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:35:34'),
(957, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:39:50'),
(958, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:39:50'),
(959, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:39:50'),
(960, 2, 'dr_martin', 'consultation', 'ajouter_patient_traitement.php', 'A ajouté un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:40:40'),
(961, 2, 'dr_martin', '', 'ajouter_patient_traitement.php', 'Patient: gdnfgng fgnf (ID: 66) - Ajout du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:40:40'),
(962, 2, 'dr_martin', 'creation', 'ajouter_patient_traitement.php', 'Patient créé: gdnfgng fgnf (ID: 66)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:40:40'),
(963, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:40:40'),
(964, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:40:42'),
(965, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:42:00'),
(966, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:42:09'),
(967, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:42:09'),
(968, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:42:09'),
(969, 2, 'dr_martin', 'consultation', 'ajouter_patient_traitement.php', 'A ajouté un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:42:29'),
(970, 2, 'dr_martin', '', 'ajouter_patient_traitement.php', 'Patient: gdnfgng Edmée Anne-Marie (ID: 67) - Ajout du patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:42:29'),
(971, 2, 'dr_martin', 'creation', 'ajouter_patient_traitement.php', 'Patient créé: gdnfgng Edmée Anne-Marie (ID: 67)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:42:29'),
(972, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Paramètres: success=1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:42:29'),
(973, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:45:28'),
(974, 2, 'dr_martin', 'consultation', 'historique_patients.php', 'Consulte l\'historique des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:45:38'),
(975, 2, 'dr_martin', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:45:49'),
(976, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 07:45:55'),
(977, 2, 'dr_martin', 'deconnexion', 'logout.php', 'Déconnexion effectuée', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', 2390, '2025-08-12 08:15:14'),
(978, 2, 'dr_martin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 08:17:27'),
(979, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 08:17:27'),
(980, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 08:17:28'),
(981, 2, 'dr_martin', 'consultation', 'historique_patients.php', 'Consulte l\'historique des patients', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 08:17:36'),
(982, 2, 'dr_martin', 'consultation', 'historique_consultations.php', 'A consulté l\'historique médicale', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 08:17:52'),
(983, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 08:18:12'),
(984, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 08:18:17'),
(985, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 08:18:33'),
(986, 2, 'dr_martin', 'consultation', 'supprimer_patient.php', 'Accès a la suppression patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 08:18:58'),
(987, 2, 'dr_martin', 'suppression', 'supprimer_patient.php', 'Patient: gdnfgng Edmée Anne-Marie (ID: 67) - Patient est entrain d\'etre supprimer', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 08:18:58'),
(988, 2, 'dr_martin', 'suppression', 'supprimer_patient.php', 'Patient: gdnfgng Edmée Anne-Marie (ID: 67) - Patient supprimé avec succès', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 08:18:58'),
(989, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 08:20:02'),
(990, 2, 'dr_martin', 'deconnexion', 'logout.php', 'Déconnexion effectuée', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', 1629, '2025-08-12 08:44:36'),
(991, 2, 'dr_martin', 'consultation', 'login_handler.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:08:51'),
(992, 2, 'dr_martin', 'connexion', 'login.php', 'Connexion réussie', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:08:51'),
(993, 2, 'dr_martin', 'consultation', 'dashboard_medecin.php', 'A acceder au tableau de bord', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:08:51'),
(994, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:10:49'),
(995, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Est entrer dans la page Ajouter un patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:11:39'),
(996, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:11:39'),
(997, 2, 'dr_martin', 'consultation', 'ajouter_patient.php', 'Accès à ajouter patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:11:39'),
(998, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:14:05'),
(999, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:14:18'),
(1000, 2, 'dr_martin', 'consultation', 'nouvelle_consultation.php', 'Accès à nouvelle consultation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:15:57'),
(1001, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:16:56'),
(1002, 2, 'dr_martin', 'consultation', 'ordonance_patient.php', 'A accedé a la creation d\'ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:17:01'),
(1003, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:20:37'),
(1004, 2, 'dr_martin', 'consultation', 'voir_ordonance.php', 'Consulte une ordonnance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:20:43'),
(1005, 2, 'dr_martin', 'consultation', 'generer_ordonnance.php', 'Génération ordonnance PDF', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:20:46'),
(1006, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:30:27'),
(1007, 2, 'dr_martin', 'consultation', 'ajouter_observation.php', 'Accès à ajouter observation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:30:30'),
(1008, 2, 'dr_martin', 'consultation', 'ajouter_observation.php', 'Accès à ajouter observation', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:31:46'),
(1009, 2, 'dr_martin', 'consultation', 'details_patient.php', 'A consulté les détails de un patients ', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 09:31:58'),
(1010, 2, 'dr_martin', 'consultation', 'lister_patients.php', 'Est entrer dans la page liste patient', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', 'khekan1vetbe7p68pfngarb15j', NULL, '2025-08-12 10:08:56');

-- --------------------------------------------------------

--
-- Table structure for table `user_sessions`
--

CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL,
  `id_utilisateur` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `session_id` varchar(255) NOT NULL,
  `adresse_ip` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `date_connexion` timestamp NOT NULL DEFAULT current_timestamp(),
  `derniere_activite` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `statut_session` enum('active','expiree','fermee') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_sessions`
--

INSERT INTO `user_sessions` (`id`, `id_utilisateur`, `username`, `session_id`, `adresse_ip`, `user_agent`, `date_connexion`, `derniere_activite`, `statut_session`) VALUES
(1, 1, 'admin', 'mc77k7u77kn26rq4iv3fgu4r8j', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-05 13:22:45', '2025-08-06 08:52:36', 'fermee'),
(7, 1, 'admin', '0e0eedcb34736ec1328ecaf49f249611', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-05 13:33:11', '2025-08-05 13:36:17', 'fermee'),
(8, 2, 'dr_martin', 'e901d3248deea2436e0ab8c73331a465', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-05 13:36:18', '2025-08-05 13:37:59', 'fermee'),
(9, 1, 'admin', 'dad62e08951dcec33adea0d61f7375df', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', '2025-08-05 13:36:55', '2025-08-05 15:28:19', 'fermee'),
(12, 2, 'dr_martin', '677313e696345f0dc71dbf7539a6017c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', '2025-08-05 15:28:47', '2025-08-05 15:49:49', 'fermee'),
(13, 2, 'dr_martin', '66821efc63e98cc05e22cf36a03081cc', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-05 15:56:58', '2025-08-06 07:16:31', 'expiree'),
(14, 1, 'admin', 'c81f83bb05d987e842cac77f3fbeac0e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-06 07:10:29', '2025-08-06 07:12:12', 'fermee'),
(15, 1, 'admin', 'd9ee5595a0adf275f05c52261ca9e055', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-06 07:12:22', '2025-08-06 07:12:34', 'fermee'),
(16, 2, 'dr_martin', 'd1858300d7a8f86ffbb1b9b4c17e4f29', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-06 07:12:35', '2025-08-06 07:13:08', 'fermee'),
(17, 1, 'admin', '0b25aceae9686b6ad6777c89a9881eec', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-06 07:13:19', '2025-08-06 07:21:39', 'fermee'),
(18, 2, 'dr_martin', '3735564647df49e8471124d14a62e8ae', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-06 07:21:41', '2025-08-06 07:31:08', 'fermee'),
(19, 1, 'admin', 'f57d51737e4b8149c967807527cbc197', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-06 07:31:21', '2025-08-06 07:35:30', 'fermee'),
(20, 27, 'Aujou', '9f2d02278aa5880f64ba062c82927864', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-06 07:35:34', '2025-08-06 07:36:05', 'fermee'),
(21, 1, 'admin', '00a09ca89cac6f4144b9d07bb89fd581', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-06 07:36:15', '2025-08-06 07:48:54', 'fermee'),
(22, 27, 'Aujou', '59b851c50aaf7e68b61d1f4d2301636b', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-06 07:48:56', '2025-08-06 08:14:28', 'fermee'),
(23, 1, 'admin', '1d12c3a7cb4bed69be1e23d8b69d6868', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-06 08:14:43', '2025-08-06 08:27:23', 'expiree'),
(24, 27, 'Aujou', 'cd217472c9f6403618debce456aed45c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-06 08:52:38', '2025-08-06 09:03:51', 'expiree'),
(25, 1, 'admin', 'cf24d9dff80aa6f80a65ff42ba13f748', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-06 08:53:07', '2025-08-06 09:05:51', 'expiree'),
(26, 27, 'Aujou', 'd00790d87a0575f86dfb755d8c9979b0', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-06 09:26:58', '2025-08-06 10:16:47', 'expiree'),
(27, 1, 'admin', 'b1f3205e17cf117c7b95e6a5ea39f8fa', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-06 09:59:08', '2025-08-06 10:16:47', 'expiree'),
(28, 1, 'admin', '45b05b1994dad913e76ea9b9590bd296', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 07:40:48', '2025-08-07 07:52:51', 'expiree'),
(29, 27, 'Aujou', 'd514fd99baeb6023e9b3f411177acff5', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 10:48:20', '2025-08-07 11:00:36', 'expiree'),
(30, 1, 'admin', '3a441f2ee3acabc46b91e82c6eb27378', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 10:49:06', '2025-08-07 11:00:36', 'expiree'),
(31, 27, 'Aujou', '93ae5da3c506624f0c78160c5927aa0e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 10:49:13', '2025-08-07 11:00:36', 'expiree'),
(32, 1, 'admin', 'a29d52ad9824ab5864ff87bf3a3d8cd5', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 10:49:49', '2025-08-07 11:02:35', 'expiree'),
(33, 27, 'Aujou', 'fa899f34856c9942df23483bd12ffc32', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 11:07:44', '2025-08-07 11:07:44', 'active'),
(34, 1, 'admin', '1a562842b24c80dc9ca49eea26e06a4e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 11:08:08', '2025-08-07 11:08:08', 'active'),
(35, 27, 'Aujou', '030d0a83a4694e56bcbb6b1757f0c5ea', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 13:02:16', '2025-08-07 13:02:16', 'active'),
(37, 1, 'admin', 'b65e46935c4c7e3017fe5d9a1cd2670d', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 15:13:56', '2025-08-07 15:13:56', 'active'),
(38, 1, 'admin', '2103c684739681d0bd230845acff34f2', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 15:32:51', '2025-08-07 15:32:51', 'active'),
(39, 1, 'admin', '5f5c9e2423371c590cfb6ad7ca6a47c5', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-07 16:32:59', '2025-08-07 16:32:59', 'active'),
(40, 1, 'admin', 'eca0d12ce4f012f46b249ad53236ba16', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 07:26:14', '2025-08-08 07:26:14', 'active'),
(41, 1, 'admin', 'bc222a6b78a521c7cdcd5633b34e1a44', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 09:09:21', '2025-08-08 09:09:21', 'active'),
(42, 1, 'admin', 'tai6h1hpsjjhb3204ft7cqgs63', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 09:09:21', '2025-08-08 15:40:49', 'active'),
(43, 1, 'admin', 'a73437a1e7282e89b0022fa5762a9478', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 09:32:55', '2025-08-08 09:32:55', 'active'),
(45, 1, 'admin', 'e02cf32a4ebbba7cd50e2408d99c39bb', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 11:41:19', '2025-08-08 11:41:19', 'active'),
(47, 2, 'dr_martin', '63608ed6630f6186594da789f5360989', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 11:41:26', '2025-08-08 11:41:26', 'active'),
(49, 1, 'admin', '2453b2ad65a596697dbef578e23b80e3', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 12:05:14', '2025-08-08 12:05:14', 'active'),
(51, 1, 'admin', 'df6e1551b0d9b92bdb6762dec516d830', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 12:07:03', '2025-08-08 12:07:03', 'active'),
(53, 2, 'dr_martin', '8d72d6bf9abe60013ebcadfe17ade206', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 14:11:52', '2025-08-08 14:11:52', 'active'),
(55, 2, 'dr_martin', 'fd7a84f5c62eb1005146480ccda2ff90', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 14:21:09', '2025-08-08 14:21:09', 'active'),
(57, 2, 'dr_martin', '1a59afcc9455cb48cc104ee0a7f47180', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 14:29:26', '2025-08-08 14:29:26', 'active'),
(59, 2, 'dr_martin', '4d9338f3c38796f27863b4ac74cb3f87', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 15:40:49', '2025-08-08 15:40:49', 'active'),
(61, 2, 'dr_martin', 'bb60dd49284ce45af58f6aa7ba7f6c12', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 20:18:05', '2025-08-08 20:18:05', 'active'),
(62, 2, 'dr_martin', '1jeisuvak0nteep774tir7v7ad', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-08 20:18:05', '2025-08-08 20:20:32', 'active'),
(63, 2, 'dr_martin', 'b4343b55bf9ee21d95abb205d8e68c8e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-09 09:10:36', '2025-08-09 09:10:36', 'active'),
(64, 2, 'dr_martin', 'dpivitmbfkgd0dvvit9sd34ln6', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-09 09:10:36', '2025-08-09 09:45:24', 'active'),
(65, 2, 'dr_martin', '018a7722718d7f603a737b2ed2179ec3', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-09 09:20:34', '2025-08-09 09:20:34', 'active'),
(67, 1, 'admin', '350f3a74d8b4b43ca39d4aef8815e261', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-09 09:37:28', '2025-08-09 09:37:28', 'active'),
(69, 2, 'dr_martin', '80d2cbc509bdd69f4dda1da5e8f5de8d', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-09 09:41:57', '2025-08-09 09:41:57', 'active'),
(71, 2, 'dr_martin', '91a804004dab926b67e31d08ff209a07', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-09 09:43:49', '2025-08-09 09:43:49', 'active'),
(73, 2, 'dr_martin', '4b8b9a310c4e4fd02817ff2f83da53c0', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-09 09:44:01', '2025-08-09 09:44:01', 'active'),
(75, 1, 'admin', 'e49d2c2e1d2e3f8779b7a9da9f4a0a35', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-09 09:45:08', '2025-08-09 09:45:08', 'active'),
(77, 2, 'dr_martin', 'dbbab774115f3e59ffb37d7740c165de', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0', '2025-08-09 09:45:21', '2025-08-09 09:45:21', 'active'),
(79, 2, 'dr_martin', '73b13cefc8ec1a0aff8f9583b2930cc8', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 07:17:35', '2025-08-11 07:17:35', 'active'),
(80, 2, 'dr_martin', 'khekan1vetbe7p68pfngarb15j', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 07:17:35', '2025-08-12 09:11:39', 'active'),
(81, 2, 'dr_martin', '9e4097909307cd3af5334bc6ba3623dc', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 07:17:36', '2025-08-11 07:17:36', 'active'),
(83, 1, 'admin', '7c8a356afdeb923111dec023c5f4738b', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 07:18:50', '2025-08-11 07:18:50', 'active'),
(85, 2, 'dr_martin', '83ed52b311277725d5139635cd69e8b6', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 07:18:58', '2025-08-11 07:18:58', 'active'),
(87, 1, 'admin', 'fb630eca15eeebe689aa32b1a6d181fb', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 07:27:45', '2025-08-11 07:27:45', 'active'),
(89, 2, 'dr_martin', 'a3c80d49eb059edbb411dec797e95b21', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 08:57:47', '2025-08-11 08:57:47', 'active'),
(91, 1, 'admin', '889b94753d681b6ffff98d1bf22d5731', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 08:58:25', '2025-08-11 08:58:25', 'active'),
(93, 1, 'admin', '6d1885a1fce04856e21c7eda0f0f7b2c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 09:12:07', '2025-08-11 09:12:07', 'active'),
(95, 1, 'admin', '99297dcd38151b5e1349dc0b4fa1bb79', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 09:16:33', '2025-08-11 09:16:33', 'active'),
(97, 2, 'dr_martin', 'b29366f0ef33324b78a0db9fbffaf854', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 09:17:16', '2025-08-11 09:17:16', 'active'),
(99, 1, 'admin', 'a91b2d2a00579df66436d906bccd27de', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-11 09:17:30', '2025-08-11 09:17:30', 'active'),
(101, 2, 'dr_martin', '1f92061cd867cf78bacea16727497fb9', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-12 07:35:24', '2025-08-12 07:35:24', 'active'),
(103, 2, 'dr_martin', 'fa83edd095a30a0b4a5e6fb1383e7d85', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-12 08:17:27', '2025-08-12 08:17:27', 'active'),
(105, 2, 'dr_martin', 'b40b201a9b31022a8028027ddb48a539', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0', '2025-08-12 09:08:51', '2025-08-12 09:08:51', 'active');

-- --------------------------------------------------------

--
-- Stand-in structure for view `vue_stats_utilisateurs`
-- (See below for the actual view)
--
CREATE TABLE `vue_stats_utilisateurs` (
`id_utilisateur` int(11)
,`username` varchar(50)
,`role` varchar(30)
,`statut` enum('principal','interimaire')
,`date_creation` datetime
,`derniere_activite` timestamp
,`statut_session` enum('active','expiree','fermee')
,`derniere_ip` varchar(45)
,`connexions_aujourdhui` bigint(21)
,`connexions_semaine` bigint(21)
,`actions_aujourdhui` bigint(21)
);

-- --------------------------------------------------------

--
-- Structure for view `vue_stats_utilisateurs`
--
DROP TABLE IF EXISTS `vue_stats_utilisateurs`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vue_stats_utilisateurs`  AS SELECT `u`.`id_utilisateur` AS `id_utilisateur`, `u`.`username` AS `username`, `u`.`role` AS `role`, `u`.`statut` AS `statut`, `u`.`date_creation` AS `date_creation`, `s`.`derniere_activite` AS `derniere_activite`, `s`.`statut_session` AS `statut_session`, `s`.`adresse_ip` AS `derniere_ip`, (select count(0) from `user_activity` `ua` where `ua`.`id_utilisateur` = `u`.`id_utilisateur` and `ua`.`action_type` = 'connexion' and cast(`ua`.`date_action` as date) = curdate()) AS `connexions_aujourdhui`, (select count(0) from `user_activity` `ua` where `ua`.`id_utilisateur` = `u`.`id_utilisateur` and `ua`.`action_type` = 'connexion' and `ua`.`date_action` >= current_timestamp() - interval 7 day) AS `connexions_semaine`, (select count(0) from `user_activity` `ua` where `ua`.`id_utilisateur` = `u`.`id_utilisateur` and `ua`.`action_type` in ('creation','modification','suppression') and cast(`ua`.`date_action` as date) = curdate()) AS `actions_aujourdhui` FROM (`users` `u` left join `user_sessions` `s` on(`u`.`id_utilisateur` = `s`.`id_utilisateur` and `s`.`statut_session` = 'active')) ORDER BY `s`.`derniere_activite` DESC ;

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
-- Indexes for table `consultations`
--
ALTER TABLE `consultations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `consultations_ibfk_1` (`id_patient`);

--
-- Indexes for table `historique_patients`
--
ALTER TABLE `historique_patients`
  ADD PRIMARY KEY (`id_historique`),
  ADD KEY `idx_patient` (`id_patient`),
  ADD KEY `idx_utilisateur` (`id_utilisateur`),
  ADD KEY `idx_date` (`date_action`),
  ADD KEY `idx_action` (`action_type`);

--
-- Indexes for table `historique_utilisateurs`
--
ALTER TABLE `historique_utilisateurs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_utilisateur_cible` (`id_utilisateur_cible`),
  ADD KEY `idx_utilisateur_auteur` (`id_utilisateur_auteur`),
  ADD KEY `idx_action_type` (`action_type`),
  ADD KEY `idx_date_action` (`date_action`);

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
  ADD UNIQUE KEY `mail` (`mail`),
  ADD UNIQUE KEY `unique_phone_number` (`phone_number`);

--
-- Indexes for table `user_activity`
--
ALTER TABLE `user_activity`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_utilisateur` (`id_utilisateur`),
  ADD KEY `idx_action_type` (`action_type`),
  ADD KEY `idx_date_action` (`date_action`),
  ADD KEY `idx_session` (`session_id`);

--
-- Indexes for table `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `session_id` (`session_id`),
  ADD KEY `idx_utilisateur` (`id_utilisateur`),
  ADD KEY `idx_session` (`session_id`),
  ADD KEY `idx_statut` (`statut_session`),
  ADD KEY `idx_derniere_activite` (`derniere_activite`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bons_examens`
--
ALTER TABLE `bons_examens`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `consultations`
--
ALTER TABLE `consultations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT for table `historique_patients`
--
ALTER TABLE `historique_patients`
  MODIFY `id_historique` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT for table `historique_utilisateurs`
--
ALTER TABLE `historique_utilisateurs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=71;

--
-- AUTO_INCREMENT for table `observations`
--
ALTER TABLE `observations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT for table `ordonnances`
--
ALTER TABLE `ordonnances`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=73;

--
-- AUTO_INCREMENT for table `patients`
--
ALTER TABLE `patients`
  MODIFY `id_patient` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT for table `support_messages`
--
ALTER TABLE `support_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id_utilisateur` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `user_activity`
--
ALTER TABLE `user_activity`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1011;

--
-- AUTO_INCREMENT for table `user_sessions`
--
ALTER TABLE `user_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=107;

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
-- Constraints for table `consultations`
--
ALTER TABLE `consultations`
  ADD CONSTRAINT `consultations_ibfk_1` FOREIGN KEY (`id_patient`) REFERENCES `patients` (`id_patient`) ON DELETE CASCADE;

--
-- Constraints for table `historique_utilisateurs`
--
ALTER TABLE `historique_utilisateurs`
  ADD CONSTRAINT `historique_utilisateurs_ibfk_2` FOREIGN KEY (`id_utilisateur_auteur`) REFERENCES `users` (`id_utilisateur`) ON DELETE CASCADE;

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
-- Constraints for table `patient_utilisateur`
--
ALTER TABLE `patient_utilisateur`
  ADD CONSTRAINT `patient_utilisateur_ibfk_1` FOREIGN KEY (`id_utilisateur`) REFERENCES `users` (`id_utilisateur`) ON DELETE CASCADE,
  ADD CONSTRAINT `patient_utilisateur_ibfk_2` FOREIGN KEY (`id_patient`) REFERENCES `patients` (`id_patient`) ON DELETE CASCADE;

--
-- Constraints for table `user_activity`
--
ALTER TABLE `user_activity`
  ADD CONSTRAINT `user_activity_ibfk_1` FOREIGN KEY (`id_utilisateur`) REFERENCES `users` (`id_utilisateur`) ON DELETE CASCADE;

--
-- Constraints for table `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`id_utilisateur`) REFERENCES `users` (`id_utilisateur`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
