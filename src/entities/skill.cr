@[ASRA::ExclusionPolicy(:all)]
class App::Entities::Skill
  include DB::Serializable
  include ASR::Serializable

  @[ASRA::Expose]
  property id : Int64

  @[ASRA::Expose]
  property name : String

  @[ASRA::Expose]
  property description : String

  @[ASRA::Expose]
  property? has_colors : Bool

  @[ASRA::VirtualProperty]
  def logo : String
    App::Helpers::URLGenerator.generate(@logo)
  end

  setter logo : String
end
