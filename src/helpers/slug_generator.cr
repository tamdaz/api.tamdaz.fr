# Helper that enables to generate the slug.
class App::Helpers::SlugGenerator
  # Generates the slug.
  def self.generate(value : String) : String
    value.downcase.unicode_normalize(:nfd)
      .gsub(/[^a-z0-9 -]/, "")
      .gsub(/\s+/, "-")
      .gsub(/-+/, "-")
      .gsub(/^-|-$/, "")
  end
end
