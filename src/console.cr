require "mysql"
require "athena"
require "athena-dotenv"
require "./commands/**"
require "./app"

Athena::Dotenv.load

ATH.run_console
