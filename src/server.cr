require "mysql"
require "athena"
require "file_utils"
require "athena-dotenv"
require "./app"

Athena::Dotenv.load

ATH.configure({
  framework: {
    cors: {
      enabled:  true,
      defaults: {
        allow_credentials: false,
        allow_origin:      ["*"],
        allow_methods:     ["GET", "POST", "PATCH", "PUT", "DELETE"],
        allow_headers:     ["Content-Type"],
        expose_headers:    ["Content-Type"],
      },
    },
  },
})

Dir.mkdir_p("/tmp/athena")

ATH.run(host: ENV["APP_HOST"].to_s, port: ENV["APP_PORT"].to_i)

FileUtils.rm_r("/tmp/athena")
