@[ASRA::ExclusionPolicy(:all)]
class App::Entities::Certification
  include DB::Serializable
  include ASR::Serializable

  @[ASRA::Expose]
  property id : Int64

  @[ASRA::Expose]
  property name : String

  @[ASRA::Expose]
  property? has_certificate : Bool

  @[ASRA::Expose]
  property pdf_file : String
end
