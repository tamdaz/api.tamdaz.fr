-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE IF NOT EXISTS `tw` (
    `id` bigint PRIMARY KEY NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT NOT NULL,
    `image_url` VARCHAR(511) NOT NULL,
    `source_url` VARCHAR(511) NOT NULL,
    `published_at` DATE NOT NULL,
    `source` VARCHAR(255) NOT NULL
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

DROP TABLE IF EXISTS `tw`;