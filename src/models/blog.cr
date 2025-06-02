@[ASRA::ExclusionPolicy(:all)]
@[ASRA::AccessorOrder(
  :custom, order: %w(id slug title description content is_published published_at thumbnail category)
)]
class App::Models::Blog < Granite::Base
  include ASR::Serializable

  table blogs

  belongs_to category : App::Models::Category, foreign_key: category_id : Int64

  @[ASRA::Expose]
  {% if flag?(:console) %}
    column id : Int64, primary: true, auto: false
  {% else %}
    column id : Int64, primary: true
  {% end %}

  @[ASRA::Expose]
  column slug : String

  @[ASRA::Expose]
  column title : String

  @[ASRA::Expose]
  column description : String?

  @[ASRA::Expose]
  column content : String?

  @[ASRA::Expose]
  column is_published : Bool

  @[ASRA::Expose]
  column published_at : Time

  before_save :generate_slug

  def generate_slug : Void
    @slug = App::Helpers::SlugGenerator.generate(title)
  end

  before_create :add_published_at

  def add_published_at : Void
    @published_at = Time.local
  end

  # Serialize the thumbnail URL for the blog.
  @[ASRA::VirtualProperty]
  def thumbnail : String
    App::Helpers::URLGenerator.generate(
      App::Models::File.find_by!(model_id: @id, model_type: self.class.name).path
    )
  end

  # Serialize the category blog.
  @[ASRA::VirtualProperty]
  @[ASRA::Name(serialize: "category")]
  def category_name : String
    category.name
  end
end
