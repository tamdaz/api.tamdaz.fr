-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE IF NOT EXISTS files (
  `id` BIGINT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `model_id` BIGINT NOT NULL,
  `model_type` VARCHAR(255) NOT NULL,
  `path` VARCHAR(500) NOT NULL
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

DROP TABLE IF EXISTS files;