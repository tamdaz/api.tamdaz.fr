-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE IF NOT EXISTS `blogs` (
    `id` BIGINT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    `slug` VARCHAR(255) NOT NULL UNIQUE,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `content` TEXT NULL,
    `category_id` BIGINT NOT NULL,
    `is_published` TINYINT(1) NOT NULL,
    `published_at` DATE NOT NULL DEFAULT NOW()
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

DROP TABLE IF EXISTS `blogs`;