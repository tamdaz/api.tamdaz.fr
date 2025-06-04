require "db"
require "mysql"

class App::Database
  class_getter db : DB::Database do
    DB.open ENV["DATABASE_URL"]
  end
end
