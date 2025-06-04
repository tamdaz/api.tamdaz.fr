@[ADI::Register]
class App::Repositories::TWRepository
  def find_all : Array(App::Entities::TW)
    App::Entities::TW.from_rs(
      App::Database.db.query("SELECT * FROM tw")
    )
  end

  def find(id : Int64) : App::Entities::TW
    App::Database.db.query_one(
      "SELECT * FROM tw WHERE id = ?", id, as: App::Entities::TW
    )
  end

  def create(tw_dto : App::DTO::TWDTO) : Int64
    query = <<-SQL
    INSERT INTO
      tw (`title`, `description`, `image_url`, `source_url`, `published_at`, `source`)
    VALUES
      (?, ?, ?, ?, ?, ?)
    SQL

    db = App::Database.db.exec(
      query,
      tw_dto.title, tw_dto.description, tw_dto.image_url,
      tw_dto.source_url, tw_dto.published_at, tw_dto.source
    )

    db.last_insert_id
  end

  def update(id : Int64, tw_dto : App::DTO::TWDTO) : Int64
    query = <<-SQL
    UPDATE tw SET
      `title` = ?, `description` = ?, `image_url` = ?,
      `source_url` = ?, `published_at` = ?, `source` = ?
    WHERE id = ?
    SQL

    result = App::Database.db.exec(
      query,
      tw_dto.title, tw_dto.description, tw_dto.image_url,
      tw_dto.source_url, tw_dto.published_at, tw_dto.source, id
    )

    id
  end

  def delete(id : Int64) : Int64
    App::Database.db.exec("DELETE FROM tw WHERE id = ?", id)

    id
  end
end
