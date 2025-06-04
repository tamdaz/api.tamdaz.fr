@[ADI::Register]
class App::Repositories::ReportRepository
  def find_all : Array(App::Entities::Report)
    query = <<-SQL
    SELECT
      R.id AS `id`, `title`, F.path AS `path_file`, C.name AS `category`,
      `created_at`
    FROM reports
    INNER JOIN files AS F ON F.model_id = R.id
    INNER JOIN categories AS C ON R.category_id = C.id
    SQL

    App::Entities::Report.from_rs(App::Database.db.query(query))
  end

  def find(id : Int64) : App::Entities::Report
    query = <<-SQL
    SELECT
      R.id AS `id`, `title`, F.path AS `path_file`, C.name AS `category`,
      `created_at`
    FROM reports
    INNER JOIN files AS F ON F.model_id = R.id
    INNER JOIN categories AS C ON R.category_id = C.id
    WHERE R.id = ?
    SQL

    App::Database.db.query_one(query, id, as: App::Entities::Report)
  end

  def create(report_dto : App::DTO::ReportDTO) : Int64
    query = <<-SQL
    INSERT INTO
      reports (`title`, `category_id`, `created_at`)
    VALUES
      (?, ?, ?)
    SQL

    db = App::Database.db.exec(
      query, report_dto.title, report_dto.category_id, report_dto.created_at
    )

    db.last_insert_id
  end

  def update(id : Int64, report_dto : App::DTO::ReportDTO) : Int64
    query = <<-SQL
    UPDATE reports
    SET title = ?, category_id = ?, created_at = ?
    WHERE id = ?
    SQL

    App::Database.db.exec(
      query, report_dto.title, report_dto.category_id, report_dto.created_at, id
    )

    id
  end

  def delete(id : Int64) : Int64
    file_path = App::Database.db.query_one(
      "SELECT path FROM files WHERE model_id = ?", id, &.read(String)
    )

    if File.exists?("./uploads/#{file_path}")
      File.delete("./uploads/#{file_path}")
    end

    App::Database.db.exec(
      "DELETE FROM files WHERE model_id = ? AND model_type = ?",
      id, App::Entities::Report.name
    )

    App::Database.db.exec("DELETE FROM reports WHERE id = ?", id)

    id
  end
end
