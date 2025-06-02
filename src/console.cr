require "mysql"
require "athena-dotenv"
require "athena"
require "granite/adapter/mysql"
require "./commands/**"
require "./enums/**"
require "./models/**"
require "./helpers/**"

# Athena::Dotenv.load

Granite::Connections << Granite::Adapter::Mysql.new(
  name: "mariadb",
  url: "mysql://root:root@localhost/tamdaz_portfolio?encoding=utf8mb4"
)

ATH.run_console
