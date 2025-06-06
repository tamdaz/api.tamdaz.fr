@[ASRA::ExclusionPolicy(:all)]
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
