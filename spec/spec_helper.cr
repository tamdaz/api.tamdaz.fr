require "spec"
require "athena"
require "athena-dotenv"
require "athena/spec"

require "./../src/commands/**"
require "./../src/app"

def send_form_data(&block : HTTP::FormData::Builder -> _) : String
  io = IO::Memory.new

  HTTP::FormData.build(io, "a4VF") do |builder|
    block.call(builder)
  end

  io.to_s
end

def form_data_header : HTTP::Headers
  HTTP::Headers{"Content-Type" => "multipart/form-data; boundary=\"a4VF\""}
end

Athena::Dotenv.new.overload ".env.test"

ASPEC.run_all
