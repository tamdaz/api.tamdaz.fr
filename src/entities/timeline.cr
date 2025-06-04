@[ASRA::ExclusionPolicy(:all)]
@[ASRA::AccessorOrder(:custom, order: %w(id date_start date_end description type))]
class App::Entities::Timeline
  include DB::Serializable
  include ASR::Serializable

  @[ASRA::Expose]
  property id : Int64

  @[ASRA::Expose]
  property date_start : Time

  @[ASRA::Expose]
  property date_end : Time

  @[ASRA::Expose]
  property description : String

  @[ASRA::Expose]
  property type : String
end
