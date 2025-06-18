# TODO: Maybe it's interesting to add a class that allows to generate the query thanks to the query builder.
@[ADI::Register]
class App::Repositories::BlogRepository
  def find_all : Array(App::Entities::Blog)
    query = <<-SQL
    SELECT B.id AS `id`, `title`, B.slug AS `slug`, `description`, `content`,
      `is_published`, `published_at`, C.name AS `category`, F.path AS `thumbnail`
    FROM        blogs     AS B
    INNER JOIN categories AS C ON C.id = B.category_id
    INNER JOIN files      AS F ON F.model_id = B.id
    WHERE F.model_type = "App::Entities::Blog";
    SQL

    App::Entities::Blog.from_rs(App::Database.db.query(query))
  end

  def find(slug : String) : App::Entities::Blog
    query = <<-SQL
    SELECT
      B.id AS id, title, B.slug AS slug, description, content, is_published,
      published_at, C.name AS category, F.path AS thumbnail
    FROM       blogs      AS B
    INNER JOIN categories AS C ON C.id = B.category_id
    INNER JOIN files      AS F ON F.model_id = B.id
    WHERE      F.model_type = "App::Entities::Blog" AND B.slug = ?;
    SQL

    App::Database.db.query_one(query, slug, as: App::Entities::Blog)
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end

  def create(blog_dto : App::DTO::BlogDTO) : Int64
    query = <<-SQL
    INSERT INTO
      blogs(`title`, `slug`, `description`, `content`, `category_id`, `is_published`)
    VALUES
      (?, ?, ?, ?, ?, ?);
    SQL

    db = App::Database.db.exec(
      query,
      blog_dto.title,
      App::Helpers::SlugGenerator.generate(blog_dto.title),
      blog_dto.description,
      blog_dto.content,
      blog_dto.category_id,
      blog_dto.is_published
    )

    db.last_insert_id
  rescue e : Exception
    if e.message.as(String).includes?("Duplicate entry")
      raise App::Exceptions::DuplicatedIDException.new
    end

    0i64
  end

  def update(blog_dto : App::DTO::BlogDTO, current_slug : String) : Int64
    blog_id = App::Database.db.query_one(
      "SELECT id FROM blogs WHERE slug = ?", current_slug, &.read(Int64)
    )

    query = <<-SQL
    UPDATE blogs SET
      `title` = ?, `slug` = ?, `description` = ?,
      `content` = ?, `category_id` = ?, `is_published` = ?
    WHERE slug = ?
    SQL

    App::Database.db.exec(
      query,
      blog_dto.title,
      App::Helpers::SlugGenerator.generate(blog_dto.title),
      blog_dto.description,
      blog_dto.content,
      blog_dto.category_id,
      blog_dto.is_published,
      current_slug
    )

    blog_id
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end

  def delete(slug : String) : Int64
    blog_id = App::Database.db.query_one(
      "SELECT id FROM blogs WHERE slug = ?", slug, &.read(Int64)
    )

    file_path = App::Database.db.query_one?(
      "SELECT path FROM files WHERE F.model_type = 'App::Entities::Blog' AND model_id = ?", blog_id, &.read(String)
    )

    App::Database.db.exec("DELETE FROM blogs WHERE slug = ?", slug)

    App::Database.db.exec(
      "DELETE FROM files WHERE F.model_type = 'App::Entities::Blog' AND model_id = ?",
      blog_id
    )

    if File.exists?("./uploads/#{file_path}")
      File.delete("./uploads/#{file_path}")
    end

    blog_id
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end
end
