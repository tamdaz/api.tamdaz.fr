@[ADI::Register]
class App::Repositories::TimelineRepository
  def find_all : Array(App::Entities::Timeline)
    query = <<-SQL
    SELECT `id`, `date_start`, `date_end`, `description`, `type` FROM timelines
    SQL

    App::Entities::Timeline.from_rs(App::Database.db.query(query))
  end

  def find(id : Int64) : App::Entities::Timeline
    query = <<-SQL
    SELECT `id`, `date_start`, `date_end`, `description`, `type` FROM timelines WHERE `id` = ?
    SQL

    App::Database.db.query_one(query, id, as: App::Entities::Timeline)
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end

  def create(timeline_dto : App::DTO::TimelineDTO) : Int64
    query = <<-SQL
    INSERT INTO timelines (`date_start`, `date_end`, `description`, `type`) VALUES (?, ?, ?, ?)
    SQL

    db = App::Database.db.exec(
      query, timeline_dto.date_start, timeline_dto.date_end,
      timeline_dto.description, timeline_dto.type
    )

    db.last_insert_id
  rescue e : Exception
    if e.message.as(String).includes?("Duplicate entry")
      raise App::Exceptions::DuplicatedIDException.new
    end

    0i64
  end

  def update(id : Int64, timeline_dto : App::DTO::TimelineDTO) : Int64
    query = <<-SQL
    UPDATE timelines
    SET `date_start` = ?, `date_end` = ?, `description` = ?, `type` = ?
    WHERE `id` = ?
    SQL

    App::Database.db.exec(
      query, timeline_dto.date_start, timeline_dto.date_end,
      timeline_dto.description, timeline_dto.type, id
    )

    id
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end

  def delete(id : Int64) : Int64
    App::Database.db.exec("DELETE FROM timelines WHERE `id` = ?", id)

    id
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end
end
