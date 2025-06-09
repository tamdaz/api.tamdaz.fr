require "spec"
require "athena"
require "athena-dotenv"
require "athena/spec"

require "./../src/modules/**"
require "./../src/resolvers/**"
require "./../src/database"
require "./../src/interfaces/**"
require "./../src/dto/**"
require "./../src/entities/**"
require "./../src/events/**"
require "./../src/helpers/**"
require "./../src/listeners/**"
require "./../src/repositories/**"
require "./../src/exceptions/**"
require "./../src/services/**"
require "./../src/commands/**"
require "./../src/controllers/**"

Athena::Dotenv.new.overload ".env.test"

ASPEC.run_all
