@[ASRA::ExclusionPolicy(:all)]
@[ASRA::AccessorOrder(:custom, order: %w(id title description image_url source_url published_at source))]
class App::Entities::TW
  include DB::Serializable
  include ASR::Serializable

  @[ASRA::Expose]
  property id : Int64

  @[ASRA::Expose]
  property title : String

  @[ASRA::Expose]
  property description : String

  @[ASRA::Expose]
  property image_url : String

  @[ASRA::Expose]
  property source_url : String

  @[ASRA::Expose]
  property published_at : Time

  @[ASRA::Expose]
  property source : String
end
