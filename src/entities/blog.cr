@[ASRA::ExclusionPolicy(:all)]
class App::Entities::Blog
  include DB::Serializable
  include ASR::Serializable

  @[ASRA::Expose]
  property id : Int64

  @[ASRA::Expose]
  property title : String

  @[ASRA::Expose]
  property slug : String

  @[ASRA::Expose]
  property description : String

  @[ASRA::Expose]
  property content : String

  @[ASRA::Expose]
  property category : String

  @[ASRA::Expose]
  property thumbnail : String

  @[ASRA::Expose]
  property? is_published : Bool

  @[ASRA::Expose]
  property published_at : Time
end
