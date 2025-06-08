@[ADI::Register]
class App::Repositories::AdminIPRepository
  def find_all : Array(App::Entities::AdminIP)
    query = App::Database.db.query("SELECT `ip` FROM admin_ips")

    App::Entities::AdminIP.from_rs(query)
  end

  def find(ip : String) : App::Entities::AdminIP
    query = <<-SQL
    SELECT `ip` FROM admin_ips WHERE `ip` = ?
    SQL

    App::Database.db.query_one(query, ip, as: App::Entities::AdminIP)
  rescue DB::NoResultsError
    raise App::Exceptions::DataNotFoundException.new
  end

  def create(dto : App::DTO::AdminIPDTO) : Void
    query = <<-SQL
    INSERT INTO admin_ips (`ip`) VALUES (?);
    SQL

    App::Database.db.exec(query, dto.ip)
  rescue e : Exception
    if e.message.as(String).includes?("Duplicate entry")
      raise App::Exceptions::DuplicatedIDException.new
    end
  end

  def delete(ip : String) : Void
    # just checking if the IP exists in the DB.
    find(ip)

    query = <<-SQL
    DELETE FROM admin_ips WHERE `ip` = ?;
    SQL

    App::Database.db.exec(query, ip)
  end
end
