require "spec"
require "athena"
require "athena-dotenv"
require "athena/spec"
require "granite/adapter/mysql"

require "./../src/interfaces/**"
require "./../src/enums/**"
require "./../src/controllers/**"
require "./../src/services/**"
require "./../src/dto/**"
require "./../src/models/**"

Athena::Dotenv.new.overload ".env.test"

begin
  Granite::Connections << Granite::Adapter::Mysql.new(
    name: ENV["DATABASE_CONNECTION"],
    url: ENV["DATABASE_URL"]
  )

  ASPEC.run_all
rescue e : KeyError
  puts e.message
  exit 1
end
