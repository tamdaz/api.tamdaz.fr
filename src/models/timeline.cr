@[ASRA::ExclusionPolicy(:all)]
@[ASRA::AccessorOrder(
  :custom, order: %w(id date_start date_end description type)
)]
class App::Models::Timeline < Granite::Base
  include ASR::Serializable

  table timelines

  @[ASRA::Expose]
  column id : Int64, primary: true

  @[ASRA::Expose]
  column date_start : Time

  @[ASRA::Expose]
  column date_end : Time

  @[ASRA::Expose]
  column description : String

  @[ASRA::Expose]
  column type : String
end
