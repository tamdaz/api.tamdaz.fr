-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

ALTER TABLE blogs ADD CONSTRAINT fk_blogs_categories FOREIGN KEY (category_id) REFERENCES categories (id);
ALTER TABLE projects ADD CONSTRAINT fk_projects_categories FOREIGN KEY (category_id) REFERENCES categories (id);
ALTER TABLE reports ADD CONSTRAINT fk_reports_categories FOREIGN KEY (category_id) REFERENCES categories (id);
-- ALTER TABLE files ADD CONSTRAINT fk_files_skills FOREIGN KEY (model_id) REFERENCES skills (id);
-- ALTER TABLE files ADD CONSTRAINT fk_files_reports FOREIGN KEY (model_id) REFERENCES reports (id);
-- ALTER TABLE files ADD CONSTRAINT fk_files_blogs FOREIGN KEY (model_id) REFERENCES blogs (id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

ALTER TABLE blogs DROP FOREIGN KEY (category_id) REFERENCES categories (id);
ALTER TABLE projects DROP FOREIGN KEY (category_id) REFERENCES categories (id);
ALTER TABLE reports DROP FOREIGN KEY (category_id) REFERENCES categories (id);
-- ALTER TABLE files DROP FOREIGN KEY (model_id) REFERENCES skills (id);
-- ALTER TABLE files DROP FOREIGN KEY (model_id) REFERENCES reports (id);
-- ALTER TABLE files DROP FOREIGN KEY (model_id) REFERENCES blogs (id);