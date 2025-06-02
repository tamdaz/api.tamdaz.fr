@[ASRA::ExclusionPolicy(:all)]
@[ASRA::AccessorOrder(
  :custom,
  order: %w(
    id slug title description content category realized_at
    published_at thumbnail
  )
)]
class App::Models::Project < Granite::Base
  include ASR::Serializable

  table projects

  belongs_to category : App::Models::Category, foreign_key: category_id : Int64

  before_save :generate_slug

  @[ASRA::Expose]
  column id : Int64, primary: true

  @[ASRA::Expose]
  column slug : String

  @[ASRA::Expose]
  column title : String

  @[ASRA::Expose]
  column description : String

  @[ASRA::Expose]
  column content : String

  column category_id : Int64

  @[ASRA::Expose]
  column realized_at : Time = Time.local

  @[ASRA::Expose]
  column published_at : Time?

  def generate_slug : Void
    @slug = title.downcase.unicode_normalize(:nfd).gsub(/\s+/, '-')
  end

  # Returns the thumbnail URL of the project.
  @[ASRA::VirtualProperty]
  def thumbnail : String
    App::Helpers::URLGenerator.generate(
      App::Models::File.find_by!(model_id: @id, model_type: self.class.name).path
    )
  end

  # Serialize the report's category.
  @[ASRA::VirtualProperty]
  @[ASRA::Name(serialize: "category")]
  def category_name : String
    category.name
  end
end
