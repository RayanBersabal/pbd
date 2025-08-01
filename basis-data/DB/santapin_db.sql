-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 01, 2025 at 05:20 PM
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
-- Database: `santapin_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AdjustPricesByRating` ()   BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE p_id BIGINT UNSIGNED;
    DECLARE p_name VARCHAR(255);
    DECLARE p_old_price INT UNSIGNED;
    DECLARE p_avg_rating DECIMAL(3,2);

    DECLARE cur CURSOR FOR
        SELECT id, name, price FROM products;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO p_id, p_name, p_old_price;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET p_avg_rating = GetProductAvgRating(p_id, '2025-08-01');

        IF p_avg_rating < 3.00 THEN
            UPDATE products
            SET price = ROUND(price * 1.10)
            WHERE id = p_id;

            INSERT INTO product_price_changes_log (product_id, old_price, new_price, notes)
            VALUES (
                p_id,
                p_old_price,
                ROUND(p_old_price * 1.10),
                CONCAT('Harga produk ', p_name, ' dinaikkan karena rating rendah (', p_avg_rating, ')')
            );
        END IF;
    END LOOP;

    CLOSE cur;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckPaymentStatus` (IN `p_order_id` BIGINT UNSIGNED, OUT `p_status_message` VARCHAR(255))   BEGIN
    DECLARE status_value VARCHAR(255);

    SELECT payment_status INTO status_value
    FROM orders
    WHERE id = p_order_id;

    CASE status_value
        WHEN 'paid' THEN
            SET p_status_message = CONCAT('Pesanan ', p_order_id, ' sudah lunas.');
        WHEN 'pending' THEN
            SET p_status_message = CONCAT('Pesanan ', p_order_id, ' masih pending.');
        WHEN 'failed' THEN
            SET p_status_message = CONCAT('Pesanan ', p_order_id, ' gagal dibayar.');
        ELSE
            SET p_status_message = CONCAT('Status pesanan ', p_order_id, ' tidak diketahui.');
    END CASE;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `GetProductAvgRating` (`p_product_id` BIGINT UNSIGNED, `p_start_date` DATE) RETURNS DECIMAL(3,2) DETERMINISTIC BEGIN
    DECLARE avg_rating DECIMAL(3,2);

    SELECT AVG(rating) INTO avg_rating
    FROM reviews
    WHERE product_id = p_product_id
    AND created_at >= p_start_date;

    IF avg_rating IS NULL THEN
        SET avg_rating = 0.00;
    END IF;

    RETURN avg_rating;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GetTotalRevenue` () RETURNS INT(10) UNSIGNED DETERMINISTIC BEGIN
    DECLARE total INT UNSIGNED;
    SELECT SUM(total_amount) INTO total
    FROM orders
    WHERE payment_status = 'paid';
    
    IF total IS NULL THEN
        SET total = 0;
    END IF;

    RETURN total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `carts`
--

CREATE TABLE `carts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `carts`
--

INSERT INTO `carts` (`id`, `user_id`, `product_id`, `quantity`, `created_at`, `updated_at`) VALUES
(1, 5, 9, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(2, 4, 3, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(3, 9, 19, 2, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(4, 11, 11, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(5, 11, 12, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(6, 1, 13, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(7, 3, 8, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(8, 6, 8, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(9, 1, 9, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(10, 5, 6, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(11, 1, 13, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(12, 4, 6, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(13, 8, 16, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(14, 9, 20, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(15, 11, 16, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(16, 2, 11, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(17, 10, 19, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(18, 3, 2, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(19, 3, 13, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(20, 11, 14, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54');

-- --------------------------------------------------------

--
-- Table structure for table `delivery_zones`
--

CREATE TABLE `delivery_zones` (
  `id` int(11) NOT NULL,
  `province` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `delivery_fee` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `members`
--

CREATE TABLE `members` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `role` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '[]' CHECK (json_valid(`role`)),
  `task` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '[]' CHECK (json_valid(`task`)),
  `image` varchar(255) DEFAULT NULL,
  `github` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2025_07_30_062548_create_products_table', 1),
(5, '2025_07_30_062608_create_members_table', 1),
(6, '2025_07_30_062619_create_carts_table', 1),
(7, '2025_07_30_062633_create_orders_table', 1),
(8, '2025_07_30_062648_create_order_items_table', 1),
(9, '2025_07_30_062836_create_reviews_table', 1),
(10, '2025_07_30_080709_create_sessions_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `customer_name` varchar(255) NOT NULL,
  `customer_phone` varchar(255) NOT NULL,
  `delivery_address` text NOT NULL,
  `notes` text DEFAULT NULL,
  `payment_type` varchar(255) NOT NULL,
  `subtotal` int(10) UNSIGNED NOT NULL,
  `delivery_fee` int(10) UNSIGNED NOT NULL,
  `admin_fee` int(10) UNSIGNED NOT NULL,
  `total_amount` int(10) UNSIGNED NOT NULL,
  `payment_status` varchar(255) NOT NULL DEFAULT 'pending',
  `payment_reference` varchar(255) DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'Dipesan',
  `estimated_delivery_time` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `customer_name`, `customer_phone`, `delivery_address`, `notes`, `payment_type`, `subtotal`, `delivery_fee`, `admin_fee`, `total_amount`, `payment_status`, `payment_reference`, `paid_at`, `status`, `estimated_delivery_time`, `created_at`, `updated_at`) VALUES
(1, 8, 'Pablo Hammes', '626-572-3952', '96723 DuBuque Drive Suite 470\nWest Brando, WV 56327', 'Qui perferendis corporis nobis molestiae sed.', 'transfer bank', 293180, 9819, 5000, 307999, 'failed', NULL, NULL, 'Dipesan', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(2, 10, 'Marty Cummings', '+1-775-478-0387', '1683 Lina Island\nHahnfurt, ND 56974', 'Consequatur aperiam id harum saepe fugit vel odio illo.', 'transfer bank', 76385, 19149, 5000, 100534, 'paid', NULL, '2025-08-01 02:59:57', 'Dikirim', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(3, 9, 'Kory Farrell', '207-592-6637', '5472 Wuckert Crescent Apt. 677\nKrajcikhaven, LA 40335-4930', 'Odio aut beatae nemo beatae.', 'transfer bank', 76247, 13476, 5000, 94723, 'pending', NULL, NULL, 'Dikirim', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(4, 8, 'Mary Gulgowski', '1-661-291-6903', '2519 Autumn Gardens\nWest Shermanview, LA 74836', 'Aut consequuntur cum voluptas sed.', 'qris', 227298, 18141, 5000, 250439, 'failed', NULL, NULL, 'Pesanan Selesai', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(5, 7, 'Abbey Runolfsdottir', '+13473372146', '319 Daphney Passage\nGunnarside, SC 27906', 'Vel omnis dignissimos eum iure laboriosam quo vel.', 'transfer bank', 20637, 9385, 5000, 35022, 'failed', NULL, NULL, 'Disiapkan', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(6, 4, 'Andreanne Hamill', '(301) 276-8503', '3728 Carlie Plaza\nLake Ismaelview, CO 98757', 'Cum alias quos reiciendis doloribus aspernatur deleniti.', 'tunai', 168538, 14420, 5000, 187958, 'failed', NULL, NULL, 'Dikirim', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(7, 2, 'Lilliana McKenzie', '1-857-796-7856', '5240 Emerald Camp Apt. 007\nWest Burleyland, DE 10734-9207', 'Enim saepe nisi qui.', 'tunai', 38398, 10241, 5000, 53639, 'pending', NULL, NULL, 'Dipesan', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(8, 5, 'Kelvin Johns', '+1.680.202.5291', '296 Mazie Turnpike\nPenelopeshire, TN 71036', 'Ad occaecati aperiam at.', 'qris', 197486, 13842, 5000, 216328, 'failed', NULL, NULL, 'Dikirim', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(9, 4, 'Ramon Jakubowski', '458.643.1047', '95831 Rosie Centers\nSouth Theresiaberg, TN 26188', 'Dolor adipisci ut qui rerum nisi voluptatem libero.', 'qris', 88036, 14090, 5000, 107126, 'paid', 'REF-25735755', '2025-07-31 18:19:54', 'Dikirim', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(10, 11, 'Damaris Denesik', '1-352-889-5059', '68134 Santos Walks\nSouth Lillian, KS 13847', 'Error rem atque consequatur aut aliquid delectus ea.', 'qris', 11200, 8089, 5000, 24289, 'failed', NULL, NULL, 'Pesanan Selesai', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(11, 2, 'Trinity Hammes', '+1-786-625-1535', '290 Rau Burg Apt. 858\nStoltenbergshire, RI 70978', 'Similique sunt nihil quia.', 'transfer bank', 194286, 9629, 5000, 208915, 'pending', NULL, NULL, 'Dipesan', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(12, 1, 'Jo Luettgen', '913-201-9692', '458 McCullough Bridge\nLake Donnell, NV 50534', 'Numquam quibusdam aperiam accusamus aut.', 'qris', 230188, 11993, 5000, 247181, 'pending', NULL, NULL, 'Pesanan Selesai', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(13, 9, 'Bertram West', '325.536.0268', '31409 Kris Trail\nLaurynside, OH 47835', 'Fuga blanditiis occaecati aut quia rerum.', 'qris', 210576, 17404, 5000, 232980, 'pending', NULL, NULL, 'Disiapkan', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(14, 3, 'Lessie Bergnaum', '702.431.1652', '97038 Ondricka Squares Apt. 190\nMarcellestad, IA 95132-3231', 'Quo dolore et dolores est enim.', 'tunai', 176169, 5066, 5000, 186235, 'failed', NULL, NULL, 'Pesanan Selesai', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(15, 7, 'Mrs. Dianna Tromp', '+1 (786) 938-5108', '694 Bosco Manors Suite 904\nPort Juwan, KS 11662-2711', 'Voluptatibus a voluptates quaerat ea.', 'transfer bank', 269580, 5669, 5000, 280249, 'pending', NULL, NULL, 'Dipesan', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(16, 5, 'Alden Runolfsdottir', '779.691.9915', '6576 White Islands\nKuhnland, MO 36307', 'Cum soluta pariatur doloribus nisi est.', 'qris', 191666, 6468, 5000, 203134, 'paid', 'REF-39437317', '2025-07-31 18:19:54', 'Dipesan', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(18, 1, 'Johnpaul Hermann', '248.705.8641', '7404 Moen Island\nRoobhaven, AZ 81206-3796', 'Totam error id earum soluta.', 'tunai', 221081, 11775, 5000, 237856, 'pending', NULL, NULL, 'Disiapkan', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(19, 9, 'Emerald Legros', '1-757-695-6956', '8933 Yundt Loaf\nStrosintown, OK 64188', 'Quo ut sit in et et quia eligendi fugiat.', 'qris', 270886, 16808, 5000, 292694, 'failed', NULL, NULL, 'Disiapkan', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(20, 4, 'Olin Bednar', '878-525-6963', '84341 Sporer Port\nStephaniestad, LA 28497', 'Qui consequatur ducimus aut odit incidunt.', 'tunai', 255191, 12549, 5000, 272740, 'failed', NULL, NULL, 'Dikirim', '30-45 menit', '2025-07-31 18:19:54', '2025-07-31 18:19:54');

--
-- Triggers `orders`
--
DELIMITER $$
CREATE TRIGGER `trg_after_delete_orders` AFTER DELETE ON `orders` FOR EACH ROW BEGIN
    INSERT INTO order_deletion_logs (order_id, user_id, notes)
    VALUES (OLD.id, OLD.user_id, CONCAT('Order #', OLD.id, ' telah dihapus oleh sistem.'));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_before_update_orders` BEFORE UPDATE ON `orders` FOR EACH ROW BEGIN
    IF NEW.payment_status = 'paid' AND OLD.payment_status != 'paid' THEN
        SET NEW.paid_at = NOW();
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `order_deletion_logs`
--

CREATE TABLE `order_deletion_logs` (
  `id` int(11) NOT NULL,
  `order_id` bigint(20) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `deleted_at` datetime DEFAULT current_timestamp(),
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_deletion_logs`
--

INSERT INTO `order_deletion_logs` (`id`, `order_id`, `user_id`, `deleted_at`, `notes`) VALUES
(1, 17, 5, '2025-08-01 11:20:50', 'Order #17 telah dihapus oleh sistem.');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `price` int(10) UNSIGNED NOT NULL,
  `quantity` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `product_name`, `price`, `quantity`, `created_at`, `updated_at`) VALUES
(1, 1, 13, 'doloremque totam voluptas', 149481, 4, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(2, 2, 5, 'Sate Ayam', 30000, 5, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(3, 2, 14, 'sit molestiae consequatur', 69497, 4, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(4, 2, 15, 'esse voluptas voluptatem', 93996, 5, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(5, 3, 19, 'id ea pariatur', 50388, 2, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(6, 3, 13, 'doloremque totam voluptas', 149481, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(7, 4, 16, 'et et nisi', 29816, 4, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(8, 4, 2, 'Es Teh Manis', 8000, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(9, 5, 18, 'eos earum et', 143423, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(10, 5, 11, 'quo excepturi nobis', 47375, 5, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(11, 6, 10, 'ab dolorum quaerat', 111916, 4, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(12, 6, 15, 'esse voluptas voluptatem', 93996, 2, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(13, 6, 4, 'Jus Alpukat', 15000, 4, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(14, 7, 9, 'atque enim omnis', 122195, 2, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(15, 7, 14, 'sit molestiae consequatur', 69497, 4, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(16, 7, 2, 'Es Teh Manis', 8000, 5, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(17, 8, 11, 'quo excepturi nobis', 47375, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(18, 9, 11, 'quo excepturi nobis', 47375, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(19, 9, 8, 'reiciendis qui eveniet', 70212, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(20, 9, 13, 'doloremque totam voluptas', 149481, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(21, 10, 17, 'adipisci ex nostrum', 13223, 2, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(22, 11, 2, 'Es Teh Manis', 8000, 4, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(23, 12, 8, 'reiciendis qui eveniet', 70212, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(24, 13, 16, 'et et nisi', 29816, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(25, 13, 12, 'illum occaecati fugiat', 28374, 5, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(26, 13, 3, 'Mie Ayam', 20000, 5, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(27, 14, 8, 'reiciendis qui eveniet', 70212, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(28, 14, 17, 'adipisci ex nostrum', 13223, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(29, 15, 1, 'Nasi Goreng', 25000, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(30, 15, 9, 'atque enim omnis', 122195, 5, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(31, 15, 15, 'esse voluptas voluptatem', 93996, 4, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(32, 16, 1, 'Nasi Goreng', 25000, 2, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(36, 18, 10, 'ab dolorum quaerat', 111916, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(37, 18, 12, 'illum occaecati fugiat', 28374, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(38, 18, 9, 'atque enim omnis', 122195, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(39, 19, 15, 'esse voluptas voluptatem', 93996, 3, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(40, 20, 4, 'Jus Alpukat', 15000, 2, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(41, 20, 7, 'a quidem quis', 125838, 2, '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(42, 20, 8, 'reiciendis qui eveniet', 70212, 1, '2025-07-31 18:19:54', '2025-07-31 18:19:54');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` int(10) UNSIGNED NOT NULL,
  `category` enum('Makanan','Minuman') NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `description`, `price`, `category`, `image`, `created_at`, `updated_at`) VALUES
(1, 'Nasi Goreng', 'Nasi goreng khas Indonesia.', 30250, 'Makanan', 'products/nasi-goreng.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(2, 'Es Teh Manis', 'Minuman dingin teh manis.', 8000, 'Minuman', 'products/es-teh-manis.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(3, 'Mie Ayam', 'Mie ayam dengan topping melimpah.', 20000, 'Makanan', 'products/mie-ayam.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(4, 'Jus Alpukat', 'Jus alpukat segar.', 18150, 'Minuman', 'products/jus-alpukat.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(5, 'Sate Ayam', 'Sate ayam dengan bumbu kacang khas.', 30000, 'Makanan', 'products/sate-ayam.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(6, 'Steak', 'Steak dari daging murah', 84952, 'Makanan', 'products/suscipit-quo-voluptatum-iure-illum-rerum-dolore-dolorum.jpg', '2025-07-31 18:19:54', '2025-07-31 18:28:12'),
(7, 'Nasi Kuning', 'Natus omnis dolorum sit voluptatem fugit consequatur eaque cumque. Maiores est voluptatibus rerum quia numquam consequatur. Ratione reiciendis sint voluptates magni non. Voluptas est libero quod sapiente rerum.', 15000, 'Minuman', 'products/quia-qui-deserunt-sit-consequuntur.jpg', '2025-07-31 18:19:54', '2025-07-31 21:08:13'),
(8, 'reiciendis qui eveniet', 'Nesciunt architecto minus unde. Culpa voluptas corporis dolores et maxime. In sunt alias aliquid consequatur quis. Cupiditate ut quia et quod nobis quia.', 84956, 'Minuman', 'products/sit-accusantium-qui-omnis-maxime.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(9, 'atque enim omnis', 'Beatae et qui mollitia modi consequatur corrupti ipsam. Quod soluta alias ea tempora totam est. Eveniet est eos saepe amet in fugiat nihil. Sed corrupti officia nostrum perspiciatis.', 147857, 'Minuman', 'products/sint-nihil-sunt-aliquam-est-ad-aut.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(10, 'ab dolorum quaerat', 'Velit deleniti aut officiis quidem. Aut qui est voluptatem dolorum maxime necessitatibus molestiae. Quia voluptas excepturi voluptatem velit aut ea. Accusantium rerum iusto assumenda eos voluptas sapiente provident. Qui saepe velit adipisci unde.', 111916, 'Minuman', 'products/veritatis-distinctio-omnis-ducimus-repellat-architecto.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(11, 'quo excepturi nobis', 'Libero enim ipsam libero et in consectetur dicta sed. Odio voluptatem earum autem recusandae consequuntur. Beatae et minus qui dolores.', 57324, 'Minuman', 'products/molestias-eaque-consequatur-earum-quasi-eaque-beatae-qui-sed.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(12, 'illum occaecati fugiat', 'Corrupti rem nesciunt recusandae sunt ut quas fuga. Nihil praesentium voluptates id aspernatur vel officiis. Neque dolor illo omnis aut. Alias excepturi est ea quis neque. Perferendis eum beatae corporis dolorem ea rerum aut excepturi.', 34332, 'Makanan', 'products/natus-ducimus-eos-eligendi-ex-qui-odio-voluptatem.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(13, 'doloremque totam voluptas', 'Vel facilis quia sit quod eius nisi quia. Minima odio distinctio nobis voluptatem corporis.', 180872, 'Makanan', 'products/consequatur-tempore-doloribus-quisquam-repellendus.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(14, 'sit molestiae consequatur', 'Ea quo aperiam fugiat maxime. Dicta voluptas rerum dignissimos laudantium vero aut mollitia. Quia autem distinctio perspiciatis sit et fugit. Ipsa ea ex suscipit soluta et dolorem delectus.', 84092, 'Minuman', 'products/sapiente-repellendus-consequatur-modi-quia.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(15, 'esse voluptas voluptatem', 'Aliquam provident sint provident pariatur. Dolorum tenetur repellendus dolorum autem veritatis laudantium recusandae. Sit modi cumque accusantium repellat enim vitae quae.', 113736, 'Makanan', 'products/neque-repellendus-commodi-reprehenderit-rerum-minus.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(16, 'et et nisi', 'Ut labore quisquam error. Magnam consequatur et a excepturi quas.', 36078, 'Makanan', 'products/quod-aliquam-facilis-quam-aut-molestiae-nihil-laboriosam.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(17, 'adipisci ex nostrum', 'Nisi dicta minus accusamus sit beatae mollitia natus. Et excepturi dolorem quo ea et. Ut ut earum sit voluptates molestias. Placeat fuga quis itaque modi.', 16000, 'Makanan', 'products/quidem-et-quia-enim-facere-ea.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(18, 'eos earum et', 'Repellat provident voluptatem odit est ea. Sit rerum aperiam ut rerum. Laborum tempora dolor rerum provident distinctio impedit voluptas. In modi quia aliquid sed consequatur mollitia.', 173542, 'Makanan', 'products/libero-possimus-ratione-aliquam-qui-doloremque.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(19, 'id ea pariatur', 'Autem at dolorem qui et. Sit accusamus sequi tempora quia qui exercitationem praesentium. Qui iste et odit officia adipisci.', 50388, 'Minuman', 'products/et-laborum-voluptate-voluptates-similique-aut.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(20, 'necessitatibus dolor et', 'Vel minus illo debitis at molestiae non quidem accusantium. Blanditiis dolore corrupti ut doloremque. Dolorum voluptas quasi et asperiores nemo. Qui molestiae ut sunt optio aut distinctio facilis. Et aut porro soluta et et harum aut.', 65471, 'Minuman', 'products/eaque-perspiciatis-quas-et-neque-autem-in.jpg', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(21, 'Nasi Kuning', 'Nasi dengan lauk lengkap', 15000, 'Makanan', NULL, '2025-08-01 03:29:32', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `product_price_changes_log`
--

CREATE TABLE `product_price_changes_log` (
  `id` int(11) NOT NULL,
  `product_id` bigint(20) UNSIGNED DEFAULT NULL,
  `old_price` int(10) UNSIGNED DEFAULT NULL,
  `new_price` int(10) UNSIGNED DEFAULT NULL,
  `change_date` datetime DEFAULT current_timestamp(),
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `product_price_changes_log`
--

INSERT INTO `product_price_changes_log` (`id`, `product_id`, `old_price`, `new_price`, `change_date`, `notes`) VALUES
(1, 1, 25000, 27500, '2025-08-01 08:46:14', 'Harga produk Nasi Goreng dinaikkan karena rating rendah (0.00)'),
(2, 4, 15000, 16500, '2025-08-01 08:46:14', 'Harga produk Jus Alpukat dinaikkan karena rating rendah (2.50)'),
(3, 6, 70208, 77229, '2025-08-01 08:46:14', 'Harga produk Steak dinaikkan karena rating rendah (2.50)'),
(4, 7, 125838, 138422, '2025-08-01 08:46:14', 'Harga produk a quidem quis dinaikkan karena rating rendah (2.00)'),
(5, 8, 70212, 77233, '2025-08-01 08:46:14', 'Harga produk reiciendis qui eveniet dinaikkan karena rating rendah (2.00)'),
(6, 9, 122195, 134415, '2025-08-01 08:46:14', 'Harga produk atque enim omnis dinaikkan karena rating rendah (1.00)'),
(7, 11, 47375, 52113, '2025-08-01 08:46:14', 'Harga produk quo excepturi nobis dinaikkan karena rating rendah (2.00)'),
(8, 12, 28374, 31211, '2025-08-01 08:46:14', 'Harga produk illum occaecati fugiat dinaikkan karena rating rendah (1.00)'),
(9, 13, 149481, 164429, '2025-08-01 08:46:14', 'Harga produk doloremque totam voluptas dinaikkan karena rating rendah (1.00)'),
(10, 14, 69497, 76447, '2025-08-01 08:46:14', 'Harga produk sit molestiae consequatur dinaikkan karena rating rendah (0.00)'),
(11, 15, 93996, 103396, '2025-08-01 08:46:14', 'Harga produk esse voluptas voluptatem dinaikkan karena rating rendah (2.00)'),
(12, 16, 29816, 32798, '2025-08-01 08:46:14', 'Harga produk et et nisi dinaikkan karena rating rendah (0.00)'),
(13, 17, 13223, 14545, '2025-08-01 08:46:14', 'Harga produk adipisci ex nostrum dinaikkan karena rating rendah (0.00)'),
(14, 18, 143423, 157765, '2025-08-01 08:46:14', 'Harga produk eos earum et dinaikkan karena rating rendah (2.00)'),
(15, 20, 54108, 59519, '2025-08-01 08:46:14', 'Harga produk necessitatibus dolor et dinaikkan karena rating rendah (1.00)'),
(16, 1, 27500, 30250, '2025-08-01 09:39:40', 'Harga produk Nasi Goreng dinaikkan karena rating rendah (0.00)'),
(17, 4, 16500, 18150, '2025-08-01 09:39:40', 'Harga produk Jus Alpukat dinaikkan karena rating rendah (2.50)'),
(18, 6, 77229, 84952, '2025-08-01 09:39:40', 'Harga produk Steak dinaikkan karena rating rendah (2.50)'),
(19, 7, 138422, 152264, '2025-08-01 09:39:40', 'Harga produk a quidem quis dinaikkan karena rating rendah (2.00)'),
(20, 8, 77233, 84956, '2025-08-01 09:39:40', 'Harga produk reiciendis qui eveniet dinaikkan karena rating rendah (2.00)'),
(21, 9, 134415, 147857, '2025-08-01 09:39:40', 'Harga produk atque enim omnis dinaikkan karena rating rendah (1.00)'),
(22, 11, 52113, 57324, '2025-08-01 09:39:40', 'Harga produk quo excepturi nobis dinaikkan karena rating rendah (2.00)'),
(23, 12, 31211, 34332, '2025-08-01 09:39:40', 'Harga produk illum occaecati fugiat dinaikkan karena rating rendah (1.00)'),
(24, 13, 164429, 180872, '2025-08-01 09:39:40', 'Harga produk doloremque totam voluptas dinaikkan karena rating rendah (1.00)'),
(25, 14, 76447, 84092, '2025-08-01 09:39:40', 'Harga produk sit molestiae consequatur dinaikkan karena rating rendah (0.00)'),
(26, 15, 103396, 113736, '2025-08-01 09:39:40', 'Harga produk esse voluptas voluptatem dinaikkan karena rating rendah (2.00)'),
(27, 16, 32798, 36078, '2025-08-01 09:39:40', 'Harga produk et et nisi dinaikkan karena rating rendah (0.00)'),
(28, 17, 14545, 16000, '2025-08-01 09:39:40', 'Harga produk adipisci ex nostrum dinaikkan karena rating rendah (0.00)'),
(29, 18, 157765, 173542, '2025-08-01 09:39:40', 'Harga produk eos earum et dinaikkan karena rating rendah (2.00)'),
(30, 20, 59519, 65471, '2025-08-01 09:39:40', 'Harga produk necessitatibus dolor et dinaikkan karena rating rendah (1.00)');

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `rating` tinyint(3) UNSIGNED NOT NULL,
  `comment` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`id`, `user_id`, `product_id`, `rating`, `comment`, `created_at`, `updated_at`) VALUES
(1, 7, 4, 4, 'Ut ut et vitae neque odio et repellat. Officiis ex quas deserunt animi modi sint et. Veniam consequatur temporibus eligendi repudiandae velit quo.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(2, 7, 12, 1, 'Dolores eum error voluptatibus molestiae et et sunt. Architecto provident id dolorem incidunt. Impedit amet officia necessitatibus temporibus deserunt consequuntur quos. Similique fugiat magnam quibusdam consequuntur qui similique ratione.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(3, 9, 7, 2, 'Explicabo vero et id quibusdam quos. Nam voluptas itaque provident voluptas sit provident qui. Eum quo qui blanditiis sunt. Repudiandae consequatur ut explicabo ipsam accusantium voluptates. Voluptatum qui similique vel.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(4, 6, 4, 1, 'Est nisi veniam quo aut. Et blanditiis velit quisquam quia. Veritatis aut dolor enim eveniet exercitationem. Culpa laudantium sit qui non.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(5, 9, 10, 2, 'Aut voluptatem sequi asperiores perferendis. Aut illum ipsum quo illo fuga atque. Velit doloremque aut magnam ipsa ad molestiae.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(6, 8, 8, 2, 'Sequi est est sed vero hic rerum blanditiis omnis. Ut dolorem quaerat animi voluptatum maiores eos. Ad distinctio debitis quia ullam id dolores adipisci.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(7, 8, 11, 2, 'Et eos ea in quis perferendis eveniet. Sed cumque ratione a numquam id illum deleniti. Commodi eaque quibusdam occaecati perferendis velit sapiente. Dolores nam veniam error ut cum ea. Alias et exercitationem molestiae sapiente aut qui.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(8, 10, 9, 1, 'Eaque dolor ut necessitatibus minima et id nulla laborum. Magnam blanditiis sed quisquam qui sit. Molestias illum id id et dicta et.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(9, 8, 5, 4, 'Doloremque ut temporibus facere modi. Possimus ut porro incidunt vitae quia nihil et. Aut quasi delectus rerum sed enim facilis rerum. Est enim voluptas autem quia.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(10, 3, 15, 2, 'Quis nihil corrupti ex est. Qui fugit officiis eligendi rerum vel. Similique in qui doloremque sed quo et. Excepturi cum non aliquam odio ipsum. Maiores explicabo eius aspernatur nostrum voluptatem neque ullam.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(11, 1, 6, 1, 'Minima ea aut sed eos exercitationem. Consequuntur aut inventore est rem quas asperiores qui aut. Fugiat et ut ut voluptatem vero quis magnam.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(12, 11, 2, 3, 'Placeat ea incidunt dolores quas laborum. Ea facere sit molestiae itaque aut ut. Tempora dolorem ducimus natus dolore tempore et. Quis voluptates voluptates et est ea.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(13, 1, 19, 4, 'Id harum quos rerum exercitationem eaque voluptatem. Dolore sed facere praesentium nulla sed eius aut. Perspiciatis id occaecati reprehenderit numquam.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(14, 4, 20, 1, 'Distinctio placeat quaerat eius est in provident. Sit necessitatibus ipsam possimus labore est qui hic. Et nobis fuga quas repudiandae cumque dolores debitis.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(15, 9, 12, 1, 'Aut blanditiis ducimus sed quia. Rerum enim est reiciendis.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(16, 4, 6, 4, 'Praesentium occaecati quia ea non voluptatem. Assumenda officia et et ex. Necessitatibus maiores nihil dolorem ea quis.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(17, 9, 3, 4, 'Placeat illum voluptate deserunt id. Ea eos dolores quasi voluptatem beatae et. Ipsa qui alias rerum temporibus aliquid reiciendis.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(18, 4, 10, 4, 'Temporibus qui aut dolores tenetur eius. Consequatur amet sit quasi expedita. Voluptatum voluptatem dignissimos deleniti aut quidem numquam.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(19, 10, 18, 2, 'Consectetur et harum id laudantium dolor dignissimos. Sit et est fugiat ab aut. Ea et quas aut cum in quia repellat. Qui culpa quaerat adipisci id.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(20, 9, 13, 1, 'Pariatur id et velit et voluptatum. Aperiam est maiores inventore sapiente dolor. Sunt ut vero harum sint excepturi fuga.', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(21, 1, 2, 4, 'Bagus', '2025-08-01 02:52:46', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('gvPmpcGfrecBFlhS0b6vryZDUnnTfFZ3d09xKo2H', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWlE4SGE5QzBPYk5ybnV6NXhySURYeUJGaHFUUTRnaVFsQ1B5TTM3byI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1754031214),
('ri3Gdy2h6X6upfmiQ5ilabLJFOcT68FaCJG1EO9l', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiT1B2VU9MUnhucWg4UEtjWDdVaTVEc1dxMTVSTHFleDFwODc4U3VvZSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzc6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9wcm9kdWN0cy9jcmVhdGUiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1754011706);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `role` enum('user','admin') NOT NULL DEFAULT 'user',
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `phone`, `address`, `role`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Admin User', 'admin@santapin.com', '$2y$12$RnWIJFl.IZm2BXDX3Sg2ROLXImKYoJmjK1.Q1N3382V7V5F/2Vi92', '089876543210', 'Jl. Admin No. 1', 'admin', NULL, '2025-07-31 18:19:52', '2025-07-31 18:19:52'),
(2, 'Dean Mosciski', 'marco11@example.com', '$2y$12$I9NcB4BzzxvCJ7RAdYuAEOViIEQz5zYG3UC1tyC2.jY.Kllr/Kxba', '1-573-810-3033', '256 Homenick Burg Suite 727\nSouth Pattie, NH 92422-4426', 'user', 'APIYKTePm8', '2025-07-31 18:19:52', '2025-07-31 18:19:52'),
(3, 'Cassandre Schamberger', 'marques.little@example.com', '$2y$12$m5Ny3zQuJiQHLIPVI1hEpetQ5lytsjQuqart9oWTdOFznme3ouwXe', '+1-321-592-1620', '6465 April Mountain Suite 635\nPort Colten, SD 81970-6006', 'user', 'IQRSy2Jtzq', '2025-07-31 18:19:52', '2025-07-31 18:19:52'),
(4, 'Brandyn Runte', 'holden95@example.org', '$2y$12$HLC92hahh8g7cjcLg8ecCewUc3jW6SbMr0/7N5QjEAYq6rkZXeM6.', '775-466-7060', '3946 Thiel Run Apt. 051\nNew Annalise, MD 58890', 'user', 'cODCXSqDsS', '2025-07-31 18:19:52', '2025-07-31 18:19:52'),
(5, 'Vella Tromp', 'ava61@example.org', '$2y$12$PgJd7Vc63ErmDP9bSAC.8.Rv.USSPaBC5JnkZ9rdYih4HwT/QvPcm', '+12074782371', '95652 Pearl Lights Suite 442\nOsinskihaven, GA 03275', 'user', 'uZVCTvQIoI', '2025-07-31 18:19:53', '2025-07-31 18:19:53'),
(6, 'Jazmyne O\'Hara', 'joanny.torphy@example.org', '$2y$12$31lM/Ajzc80mnFgcwPr/MOmy3ScAdsuNfy8aJxKZvTCnp1JlC2Jxq', '+12017052532', '26539 Aufderhar Inlet Suite 447\nNew Eleanora, IN 43597', 'admin', '26f5KhEH0m', '2025-07-31 18:19:53', '2025-07-31 18:19:53'),
(7, 'Stone Rempel', 'runolfsdottir.kenyon@example.com', '$2y$12$ITC12E3O1Yx7JqOdTJIBd.1pT4TlDjlPM411Zhn7Sm7AGbiddCPCa', '404.771.4839', '109 Padberg Burg\nWest Arjunchester, DC 30767', 'admin', 'K7YzuvxcbW', '2025-07-31 18:19:53', '2025-07-31 18:19:53'),
(8, 'Erik Funk', 'cecelia.schoen@example.org', '$2y$12$gaWlVWTKk7CdPnzaFQ9f0uRxkORdR9drK/pk6FHYTm9TO10qAPFJy', '364-706-7102', '940 Gerlach Ridge\nPort Leonora, AZ 30166-4709', 'user', 'IfDEbGt1rU', '2025-07-31 18:19:53', '2025-07-31 18:19:53'),
(9, 'Kurtis McLaughlin Jr.', 'eldora.quitzon@example.com', '$2y$12$xxCSJHGGO6cYrYYAE42P8OTbCSvwhZL8wOy2dKp.aj7LFBUlCQaPG', '1-878-478-8163', '345 Armani Spurs Apt. 534\nNew Theodorachester, AZ 60331', 'admin', '0x4LvNIchl', '2025-07-31 18:19:53', '2025-07-31 18:19:53'),
(10, 'Ms. Lempi Larson MD', 'glover.johann@example.org', '$2y$12$WSqG2H29TyeIRyKZikjQqeSrtF0G3WjTOENn.BhVFwgPW7cLwT8IO', '+1.816.885.9559', '3881 Sawayn Mountains\nNew Paulineborough, AK 03381-9714', 'admin', 'j2zYaWcKzo', '2025-07-31 18:19:54', '2025-07-31 18:19:54'),
(11, 'Danika Farrell', 'fadel.roscoe@example.net', '$2y$12$kgRJjVnTvKFFlCHkjVD/A.qdN6YZCnqPg3Ia4v1zmq4lTxv82t9rK', '+1.570.660.1290', '64636 Treutel Neck Apt. 991\nWilhelmineport, PA 57344', 'admin', 'fGTqaLZwdp', '2025-07-31 18:19:54', '2025-07-31 18:19:54');

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_makanan`
-- (See below for the actual view)
--
CREATE TABLE `view_makanan` (
`id` bigint(20) unsigned
,`name` varchar(255)
,`description` text
,`price` int(10) unsigned
,`category` enum('Makanan','Minuman')
,`image` varchar(255)
,`created_at` timestamp
,`updated_at` timestamp
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_makanan_terjangkau`
-- (See below for the actual view)
--
CREATE TABLE `view_makanan_terjangkau` (
`id` bigint(20) unsigned
,`name` varchar(255)
,`description` text
,`price` int(10) unsigned
,`category` enum('Makanan','Minuman')
,`image` varchar(255)
,`created_at` timestamp
,`updated_at` timestamp
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_paid_orders`
-- (See below for the actual view)
--
CREATE TABLE `view_paid_orders` (
`id` bigint(20) unsigned
,`user_id` bigint(20) unsigned
,`customer_name` varchar(255)
,`customer_phone` varchar(255)
,`delivery_address` text
,`notes` text
,`payment_type` varchar(255)
,`subtotal` int(10) unsigned
,`delivery_fee` int(10) unsigned
,`admin_fee` int(10) unsigned
,`total_amount` int(10) unsigned
,`payment_status` varchar(255)
,`payment_reference` varchar(255)
,`paid_at` timestamp
,`status` varchar(255)
,`estimated_delivery_time` varchar(255)
,`created_at` timestamp
,`updated_at` timestamp
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_product_summary`
-- (See below for the actual view)
--
CREATE TABLE `view_product_summary` (
`id` bigint(20) unsigned
,`name` varchar(255)
,`category` enum('Makanan','Minuman')
,`price` int(10) unsigned
);

-- --------------------------------------------------------

--
-- Structure for view `view_makanan`
--
DROP TABLE IF EXISTS `view_makanan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_makanan`  AS SELECT `products`.`id` AS `id`, `products`.`name` AS `name`, `products`.`description` AS `description`, `products`.`price` AS `price`, `products`.`category` AS `category`, `products`.`image` AS `image`, `products`.`created_at` AS `created_at`, `products`.`updated_at` AS `updated_at` FROM `products` WHERE `products`.`category` = 'Makanan'WITH CASCADED CHECK OPTION  ;

-- --------------------------------------------------------

--
-- Structure for view `view_makanan_terjangkau`
--
DROP TABLE IF EXISTS `view_makanan_terjangkau`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_makanan_terjangkau`  AS SELECT `view_makanan`.`id` AS `id`, `view_makanan`.`name` AS `name`, `view_makanan`.`description` AS `description`, `view_makanan`.`price` AS `price`, `view_makanan`.`category` AS `category`, `view_makanan`.`image` AS `image`, `view_makanan`.`created_at` AS `created_at`, `view_makanan`.`updated_at` AS `updated_at` FROM `view_makanan` WHERE `view_makanan`.`price` < 30000WITH LOCALCHECK OPTION  ;

-- --------------------------------------------------------

--
-- Structure for view `view_paid_orders`
--
DROP TABLE IF EXISTS `view_paid_orders`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_paid_orders`  AS SELECT `orders`.`id` AS `id`, `orders`.`user_id` AS `user_id`, `orders`.`customer_name` AS `customer_name`, `orders`.`customer_phone` AS `customer_phone`, `orders`.`delivery_address` AS `delivery_address`, `orders`.`notes` AS `notes`, `orders`.`payment_type` AS `payment_type`, `orders`.`subtotal` AS `subtotal`, `orders`.`delivery_fee` AS `delivery_fee`, `orders`.`admin_fee` AS `admin_fee`, `orders`.`total_amount` AS `total_amount`, `orders`.`payment_status` AS `payment_status`, `orders`.`payment_reference` AS `payment_reference`, `orders`.`paid_at` AS `paid_at`, `orders`.`status` AS `status`, `orders`.`estimated_delivery_time` AS `estimated_delivery_time`, `orders`.`created_at` AS `created_at`, `orders`.`updated_at` AS `updated_at` FROM `orders` WHERE `orders`.`payment_status` = 'paid' ;

-- --------------------------------------------------------

--
-- Structure for view `view_product_summary`
--
DROP TABLE IF EXISTS `view_product_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_product_summary`  AS SELECT `products`.`id` AS `id`, `products`.`name` AS `name`, `products`.`category` AS `category`, `products`.`price` AS `price` FROM `products` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `carts_user_id_foreign` (`user_id`),
  ADD KEY `carts_product_id_foreign` (`product_id`);

--
-- Indexes for table `delivery_zones`
--
ALTER TABLE `delivery_zones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_location` (`province`,`city`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `members`
--
ALTER TABLE `members`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orders_user_id_foreign` (`user_id`);

--
-- Indexes for table `order_deletion_logs`
--
ALTER TABLE `order_deletion_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_items_order_id_foreign` (`order_id`),
  ADD KEY `idx_product_order` (`product_id`,`order_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_category_price` (`category`,`price`);

--
-- Indexes for table `product_price_changes_log`
--
ALTER TABLE `product_price_changes_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `reviews_user_id_product_id_unique` (`user_id`,`product_id`),
  ADD KEY `reviews_product_id_foreign` (`product_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `carts`
--
ALTER TABLE `carts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `delivery_zones`
--
ALTER TABLE `delivery_zones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `members`
--
ALTER TABLE `members`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `order_deletion_logs`
--
ALTER TABLE `order_deletion_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `product_price_changes_log`
--
ALTER TABLE `product_price_changes_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `carts_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `carts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
