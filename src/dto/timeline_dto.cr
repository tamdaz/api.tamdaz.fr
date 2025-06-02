struct App::DTO::TimelineDTO
  include AVD::Validatable
  include JSON::Serializable

  @[Assert::NotNil(message: "La date de début est obligatoire.")]
  getter date_start : Time

  @[Assert::NotNil(message: "La date de fin est obligatoire.")]
  getter date_end : Time

  @[Assert::NotBlank(message: "La description est obligatoire.")]
  getter description : String

  @[Assert::NotBlank(message: "Le type de timeline doit être spécifiée.")]
  @[Assert::Choice(
    ["formation", "experience"],
    message: "Veuillez choisir l'une des 2 usages : 'formation' et 'experience'."
  )]
  getter type : String

  def initialize(
    @date_start : Time,
    @date_end : Time,
    @description : String,
    @type : String,
  ); end
end
