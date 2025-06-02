# Helper that enables to generate the URL, this is useful for models to
# display the storage file path.
class App::Helpers::URLGenerator
  # Generates the URL.
  def self.generate(path : String) : String
    String.build do |io|
      io << (ENV["APP_ENABLE_HTTPS"] == true ? "https" : "http") << "://"
      io << ENV["APP_HOST"] << ':' << (ENV["APP_PORT"] if ENV["APP_PORT"])
      io << "/uploads/"
      io << path
    end
  end
end
