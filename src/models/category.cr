@[ASRA::ExclusionPolicy(:all)]
@[ASRA::AccessorOrder(
  :custom,
  order: %w(id slug name usage links)
)]
class App::Models::Category < Granite::Base
  include ASR::Serializable

  table categories

  has_many :blogs, class_name: App::Models::Blog, foreign_key: :category_id

  has_many :projects, class_name: App::Models::Project, foreign_key: :category_id

  has_many :reports, class_name: App::Models::Report, foreign_key: :category_id

  @[ASRA::Expose]
  column id : Int64, primary: true

  @[ASRA::Expose]
  column slug : String

  @[ASRA::Expose]
  column name : String

  @[ASRA::Expose]
  column usage : App::Enums::Categories::Usage, converter: Granite::Converters::Enum(App::Enums::Categories::Usage, String)

  before_save :generate_slug

  def generate_slug
    @slug = @name.as(String).downcase.unicode_normalize(:nfd).gsub(/\s+/, '-')
  end

  @[ASRA::VirtualProperty]
  @[ASRA::Name(serialize: "links")]
  def links : Array(App::Models::Blog | App::Models::Project | App::Models::Report)
    blogs.to_a + projects.to_a + reports.to_a
  end
end
