@[ASRA::ExclusionPolicy(:all)]
@[ASRA::AccessorOrder(
  :custom, order: %w(id title description image_url source_url published_at source)
)]
class App::Models::TW < Granite::Base
  include ASR::Serializable

  table tw

  @[ASRA::Expose]
  column id : Int64, primary: true

  @[ASRA::Expose]
  column title : String

  @[ASRA::Expose]
  column description : String

  @[ASRA::Expose]
  column image_url : String

  @[ASRA::Expose]
  column source_url : String

  @[ASRA::Expose]
  column published_at : Time

  @[ASRA::Expose]
  column source : String
end
