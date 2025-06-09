require "spec"
require "athena"
require "athena-dotenv"
require "athena/spec"

require "./../src/app"

Athena::Dotenv.new.overload ".env.test"

ASPEC.run_all
