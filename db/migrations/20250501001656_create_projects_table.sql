-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE IF NOT EXISTS `projects` (
    `id` BIGINT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    `slug` VARCHAR(255)  NOT NULL UNIQUE,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT,
    `content` TEXT,
    `category_id` BIGINT NOT NULL,
    `realized_at` DATE NOT NULL,
    `published_at` DATE
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

DROP TABLE IF EXISTS `projects`;