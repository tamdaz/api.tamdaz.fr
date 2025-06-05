@[ADI::Register]
class App::Repositories::ProjectRepository
  def find_all : Array(App::Entities::Project)
    query = <<-SQL
    SELECT
      P.id AS `id`, `title`, P.slug AS `slug`, `description`, `content`, C.name AS `category`,
      `realized_at`, `published_at`, F.path AS `thumbnail`
    FROM projects AS P
    INNER JOIN categories AS C ON C.id = P.category_id
    INNER JOIN files      AS F ON F.model_id = P.id
    SQL

    App::Entities::Project.from_rs(App::Database.db.query(query))
  end

  def find(slug : String) : App::Entities::Project
    query = <<-SQL
    SELECT
      P.id AS `id`, `title`, P.slug AS `slug`, `description`, `content`, C.name AS `category`,
      `realized_at`, `published_at`, F.path AS `thumbnail`
    FROM projects AS P
    INNER JOIN categories AS C ON C.id = P.category_id
    INNER JOIN files      AS F ON F.model_id = P.id
    WHERE slug = ?
    SQL

    App::Database.db.query_one(query, slug, as: App::Entities::Project)
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end

  def create(project_dto : App::DTO::ProjectDTO) : Int64
    query = <<-SQL
    INSERT INTO projects (`title`, `slug`, `description`, `content`, `category_id`, `realized_at`, `published_at`)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    SQL

    db = App::Database.db.exec(
      query,
      project_dto.title,
      App::Helpers::SlugGenerator.generate(project_dto.title),
      project_dto.description,
      project_dto.content,
      project_dto.category_id,
      project_dto.realized_at,
      project_dto.published_at
    )

    db.last_insert_id
  rescue e : Exception
    if (e.message.as(String).includes?("Duplicate entry"))
      raise App::Exceptions::DuplicatedIDException.new
    end

    0i64
  end

  def update(slug : String, project_dto : App::DTO::ProjectDTO) : Int64
    id = self.find(slug).id

    query = <<-SQL
    UPDATE projects SET
      `title` = ?, `slug` = ?, `description` = ?, `content` = ?,
      `category_id` = ?, `realized_at` = ?, `published_at` = ?
    WHERE slug = ?
    SQL

    result = App::Database.db.exec(
      query,
      project_dto.title,
      App::Helpers::SlugGenerator.generate(project_dto.title),
      project_dto.description,
      project_dto.content,
      project_dto.category_id,
      project_dto.realized_at,
      project_dto.published_at,
      slug
    )

    id
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end

  def delete(slug : String) : Int64
    id = self.find(slug).id

    file_path = App::Database.db.query_one(
      "SELECT path FROM files WHERE model_id = ?", id, &.read(String)
    )

    if File.exists?("./uploads/#{file_path}")
      File.delete("./uploads/#{file_path}")
    end

    App::Database.db.exec(
      "DELETE FROM files WHERE model_id = ? AND model_type = ?",
      id, App::Entities::Project.name
    )

    App::Database.db.exec("DELETE FROM projects WHERE id = ?", id)

    id
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end
end
