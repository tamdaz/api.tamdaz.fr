@[ADI::Register]
class App::Repositories::CertificationRepository
  def find_all : Array(App::Entities::Certification)
    query = <<-SQL
    SELECT C.id AS `id`, `name`, `has_certificate`, F.path AS `pdf_file`
    FROM certifications AS C
    INNER JOIN files as F ON C.id = F.model_id
    WHERE F.model_type = "App::Entities::Certification";
    SQL

    App::Entities::Certification.from_rs(App::Database.db.query(query))
  end

  def find(id : Int64) : App::Entities::Certification
    query = <<-SQL
    SELECT C.id AS `id`, `name`, `has_certificate`, F.path AS `pdf_file`
    FROM certifications AS C
    INNER JOIN files as F ON C.id = F.model_id
    WHERE C.id = ? AND F.model_type = "App::Entities::Certification";
    SQL

    App::Database.db.query_one(query, id, as: App::Entities::Certification)
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end

  def create(certification_dto : App::DTO::CertificationDTO) : Int64
    query = <<-SQL
    INSERT INTO certifications (`name`, `has_certificate`) VALUES (?, ?);
    SQL

    db = App::Database.db.exec(query, certification_dto.name, certification_dto.has_certificate)

    db.last_insert_id
  rescue e : Exception
    if e.message.as(String).includes?("Duplicate entry")
      raise App::Exceptions::DuplicatedIDException.new
    end

    0i64
  end

  def update(id : Int64, certification_dto : App::DTO::CertificationDTO) : Int64
    query = <<-SQL
    UPDATE certifications SET `name` = ?, `has_certificate` = ? WHERE id = ?;
    SQL

    App::Database.db.exec(query, certification_dto.name, certification_dto.has_certificate, id)

    id
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end

  def delete(id : Int64) : Int64
    file_path = App::Database.db.query_one(
      "SELECT path FROM files WHERE model_type = 'App::Entities::Certification' AND model_id = ?;",
      id, &.read(String)
    )

    if File.exists?("./uploads/#{file_path}")
      File.delete("./uploads/#{file_path}")
    end

    App::Database.db.exec(
      "DELETE FROM files WHERE model_type = 'App::Entities::Certification' AND model_id = ?",
      id
    )

    App::Database.db.exec("DELETE FROM certifications WHERE id = ?;", id)

    id
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end
end
