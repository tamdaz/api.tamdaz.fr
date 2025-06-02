@[ASRA::ExclusionPolicy(:all)]
@[ASRA::AccessorOrder(
  :custom, order: %w(id title category created_at pdf_file)
)]
class App::Models::Report < Granite::Base
  include ASR::Serializable

  table reports

  belongs_to category : App::Models::Category, foreign_key: category_id : Int64

  @[ASRA::Expose]
  column id : Int64, primary: true

  @[ASRA::Expose]
  column title : String

  @[ASRA::Expose]
  column created_at : Time

  # Serialize the thumbnail link of the report.
  @[ASRA::VirtualProperty]
  def pdf_file : String
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
