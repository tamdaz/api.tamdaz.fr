@[ASRA::ExclusionPolicy(:all)]
@[ASRA::AccessorOrder(:custom, order: %w(id name slug usage links))]
class App::Entities::Category
  include DB::Serializable
  include ASR::Serializable

  @[ASRA::Expose]
  property id : Int64

  @[ASRA::Expose]
  property slug : String

  @[ASRA::Expose]
  property name : String

  @[ASRA::Expose]
  property usage : String

  @[ASRA::Expose]
  property links : Int64
end
