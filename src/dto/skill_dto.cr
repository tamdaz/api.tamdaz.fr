struct App::DTO::SkillDTO
  include AVD::Validatable
  include JSON::Serializable

  @[Assert::NotBlank(message: "Le nom est requis.")]
  getter name : String

  @[Assert::NotBlank(message: "La description est requise.")]
  getter description : String

  @[Assert::NotNil(message: "Veuillez spécifier si le logo a des couleurs ou non.")]
  getter has_colors : Bool?

  def initialize(
    @name : String,
    @description : String,
    @has_colors : Bool?,
  ); end
end
