@[ASRA::ExclusionPolicy(:all)]
@[ASRA::AccessorOrder(
  :custom, order: %w(id name description has_colors logo)
)]
class App::Models::Skill < Granite::Base
  include ASR::Serializable

  table skills

  @[ASRA::Expose]
  column id : Int64, primary: true

  @[ASRA::Expose]
  column name : String

  @[ASRA::Expose]
  column description : String

  @[ASRA::Expose]
  column has_colors : Bool

  # Serialize the logo's URL for a skill.
  @[ASRA::VirtualProperty]
  def logo : String
    App::Helpers::URLGenerator.generate(
      App::Models::File.find_by!(model_id: @id, model_type: self.class.name).path
    )
  end
end
