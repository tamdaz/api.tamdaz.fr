@[ADI::Register]
class App::Repositories::CategoryRepository
  def find_all : Array(App::Entities::Category)
    query = <<-SQL
    SELECT
      C.id AS `id`, `name`, C.slug AS `slug`, `usage`, COUNT(C.id) AS links
    FROM      categories AS C
    LEFT JOIN blogs      AS B ON C.id = B.category_id
    LEFT JOIN reports    AS R ON C.id = R.category_id
    LEFT JOIN projects   AS P ON C.id = P.category_id
    GROUP BY C.id
    SQL

    App::Entities::Category.from_rs(App::Database.db.query(query))
  end

  def find(slug : String) : App::Entities::Category
    query = <<-SQL
    SELECT
      C.id AS `id`, `name`, C.slug AS `slug`, `usage`, COUNT(C.id) AS links
    FROM      categories AS C
    LEFT JOIN blogs      AS B ON C.id = B.category_id
    LEFT JOIN reports    AS R ON C.id = R.category_id
    LEFT JOIN projects   AS P ON C.id = P.category_id
    WHERE C.slug = ?
    GROUP BY C.id
    SQL

    App::Database.db.query_one(query, slug, as: App::Entities::Category)
  end

  def create(category_dto : App::DTO::CategoryDTO) : Int64
    db = App::Database.db.exec(
      "INSERT INTO categories (`name`, `slug`, `usage`) VALUES (?, ?, ?);",
      category_dto.name,
      App::Helpers::SlugGenerator.generate(category_dto.name),
      category_dto.usage
    )

    db.last_insert_id
  end

  def update(current_slug : String, category_dto : App::DTO::CategoryDTO) : Void
    App::Database.db.exec(
      "UPDATE categories SET `name` = ?, `slug` = ? WHERE slug = ?",
      category_dto.name,
      App::Helpers::SlugGenerator.generate(category_dto.name),
      current_slug
    )
  end

  def delete(slug : String) : Void
    App::Database.db.exec("DELETE FROM categories WHERE slug = ?", slug)
  end
end
