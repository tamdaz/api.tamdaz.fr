-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE IF NOT EXISTS `timelines` (
    `id` BIGINT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    `date_start` DATE NOT NULL,
    `date_end` DATE NOT NULL,
    `description` VARCHAR(255) NOT NULL,
    `type` VARCHAR(50) NOT NULL
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

DROP TABLE IF EXISTS `timelines`;