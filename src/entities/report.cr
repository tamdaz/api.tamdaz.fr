@[ASRA::ExclusionPolicy(:all)]
class App::Entities::Report
  include DB::Serializable
  include ASR::Serializable

  @[ASRA::Expose]
  property id : Int64

  @[ASRA::Expose]
  property title : String

  @[ASRA::Expose]
  property pdf_file : String

  @[ASRA::Expose]
  property category : String

  @[ASRA::Expose]
  property created_at : Time
end
