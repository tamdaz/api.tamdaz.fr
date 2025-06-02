@[ASRA::ExclusionPolicy(:all)]
@[ASRA::AccessorOrder(
  :custom,
  order: %w(id name has_certificate pdf_file)
)]
class App::Models::Certification < Granite::Base
  include ASR::Serializable

  table certifications

  {% if flag?(:console) %}
    @[ASRA::Expose]
    column id : Int64, primary: true, auto: false
  {% else %}
    @[ASRA::Expose]
    column id : Int64, primary: true
  {% end %}

  @[ASRA::Expose]
  column name : String

  @[ASRA::Expose]
  column has_certificate : Bool

  # Serialize the certification URL.
  @[ASRA::VirtualProperty]
  def pdf_file : String
    App::Helpers::URLGenerator.generate(
      App::Models::File.find_by!(model_id: @id, model_type: self.class.name).path
    )
  end
end
