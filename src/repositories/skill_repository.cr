@[ADI::Register]
class App::Repositories::SkillRepository
  def find_all : Array(App::Entities::Skill)
    query = <<-SQL
    SELECT S.id AS `id`, `name`, `description`, `has_colors`, F.path AS `logo`
    FROM skills AS S
    INNER JOIN files AS F ON F.model_id = S.id
    WHERE F.model_type = "App::Entities::Skill";
    SQL

    App::Entities::Skill.from_rs(App::Database.db.query(query))
  end

  def find(id : Int64) : App::Entities::Skill
    query = <<-SQL
    SELECT S.id AS `id`, `name`, `description`, `has_colors`, F.path AS `logo`
    FROM skills AS S
    INNER JOIN files AS F ON F.model_id = S.id
    WHERE S.id = ? AND F.model_type = "App::Entities::Skill";
    SQL

    App::Database.db.query_one(query, id, as: App::Entities::Skill)
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end

  def create(skill_dto : App::DTO::SkillDTO) : Int64
    query = <<-SQL
    INSERT INTO
      skills (`name`, `description`, `has_colors`)
    VALUES
      (?, ?, ?)
    SQL

    db = App::Database.db.exec(
      query, skill_dto.name, skill_dto.description, skill_dto.has_colors
    )

    db.last_insert_id
  rescue e : Exception
    if e.message.as(String).includes?("Duplicate entry")
      raise App::Exceptions::DuplicatedIDException.new
    end

    0i64
  end

  def update(id : Int64, skill_dto : App::DTO::SkillDTO) : Int64
    query = <<-SQL
    UPDATE skills SET `name` = ?, `description` = ?, `has_colors` = ?
    WHERE id = ?
    SQL

    App::Database.db.exec(
      query, skill_dto.name, skill_dto.description, skill_dto.has_colors, id
    )

    id
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end

  def delete(id : Int64) : Int64
    file_path = App::Database.db.query_one(
      "SELECT path FROM files WHERE model_type = 'App::Entities::Skill' AND model_id = ?", id, &.read(String)
    )

    if File.exists?("./uploads/#{file_path}")
      File.delete("./uploads/#{file_path}")
    end

    App::Database.db.exec(
      "DELETE FROM files WHERE model_type = 'App::Entities::Skill' AND model_id = ?",
      id, App::Entities::Skill.name
    )

    App::Database.db.exec("DELETE FROM skills WHERE id = ?", id)

    id
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end
end
