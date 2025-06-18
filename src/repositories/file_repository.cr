@[ADI::Register]
class App::Repositories::FileRepository
  def find(id : Int64, type : String) : App::Entities::File
    query = <<-SQL
    SELECT * FROM files
    WHERE model_id = ? AND model_type = ?
    SQL

    App::Database.db.query_one(query, id, type, as: App::Entities::File)
  end

  def create(id : Int64, type : String, path : String) : Int64
    query = <<-SQL
    INSERT INTO files (`model_id`, `model_type`, `path`) VALUES (?, ?, ?);
    SQL

    db = App::Database.db.exec(query, id, type, path)

    db.last_insert_id
  end

  def update(id : Int64, type : String, new_path : String) : Int64
    file = self.find(id, type)

    query = "UPDATE files SET `path` = ? WHERE `model_id` = ? AND `model_type` = ?"

    db = App::Database.db.exec(query, new_path, id, type)

    File.delete("./uploads/#{file.path}")

    file.model_id
  end
end
