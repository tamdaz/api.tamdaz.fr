@[ADI::Register]
class App::Repositories::CategoryRepository
  def find_all : Array(App::Entities::Category)
    query = <<-SQL
    SELECT
      C.id AS `id`, `name`, C.slug AS `slug`, `usage`,
      CASE
        WHEN C.usage = 'blogs' THEN COUNT(B.id)
        WHEN C.usage = 'reports' THEN COUNT(R.id)
        WHEN C.usage = 'projects' THEN COUNT(P.id)
        ELSE 0
      END AS links
    FROM      categories AS C
    LEFT JOIN blogs      AS B ON C.id = B.category_id
    LEFT JOIN reports    AS R ON C.id = R.category_id
    LEFT JOIN projects   AS P ON C.id = P.category_id
    GROUP BY  C.id
    SQL

    App::Entities::Category.from_rs(App::Database.db.query(query))
  end

  def group_by_usages : Hash(String, Int64)
    query = <<-SQL
    SELECT C.usage, COUNT(C.id) AS number_of_categories
    FROM      categories AS C
    LEFT JOIN blogs      AS B ON C.id = B.category_id
    LEFT JOIN reports    AS R ON C.id = R.category_id
    LEFT JOIN projects   AS P ON C.id = P.category_id
    GROUP BY C.usage;
    SQL

    output = {} of String => Int64

    usages = App::Database.db.query_all(query, as: {String, Int64})

    usages.each do |usage|
      output[usage[0].downcase] = usage[1]
    end

    output
  end

  def find(slug : String) : App::Entities::Category
    query = <<-SQL
    SELECT
      C.id AS `id`, `name`, C.slug AS `slug`, `usage`,
      CASE
        WHEN C.usage = 'blogs' THEN COUNT(B.id)
        WHEN C.usage = 'reports' THEN COUNT(R.id)
        WHEN C.usage = 'projects' THEN COUNT(P.id)
        ELSE 0
      END AS links
    FROM      categories AS C
    LEFT JOIN blogs      AS B ON C.id = B.category_id
    LEFT JOIN reports    AS R ON C.id = R.category_id
    LEFT JOIN projects   AS P ON C.id = P.category_id
    WHERE     C.slug = ?
    GROUP BY  C.id
    SQL

    App::Database.db.query_one(query, slug, as: App::Entities::Category)
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end

  def create(category_dto : App::DTO::CategoryDTO) : Int64
    db = App::Database.db.exec(
      "INSERT INTO categories (`name`, `slug`, `usage`) VALUES (?, ?, ?);",
      category_dto.name,
      App::Helpers::SlugGenerator.generate(category_dto.name),
      category_dto.usage
    )

    db.last_insert_id
  rescue e : Exception
    if e.message.as(String).includes?("Duplicate entry")
      raise App::Exceptions::DuplicatedIDException.new
    end

    0i64
  end

  def update(current_slug : String, category_dto : App::DTO::CategoryDTO) : Void
    App::Database.db.exec(
      "UPDATE categories SET `name` = ?, `slug` = ? WHERE slug = ?",
      category_dto.name,
      App::Helpers::SlugGenerator.generate(category_dto.name),
      current_slug
    )
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end

  def delete(slug : String) : Void
    App::Database.db.exec("DELETE FROM categories WHERE slug = ?", slug)
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end
end
