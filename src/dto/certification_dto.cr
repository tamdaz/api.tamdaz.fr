struct App::DTO::CertificationDTO
  include AVD::Validatable
  include JSON::Serializable

  @[Assert::NotBlank(message: "Le nom ne doit pas être vide.")]
  getter name : String

  @[Assert::NotNil(message: "Veuillez spécifier si la certification est fournie ou non.")]
  getter has_certificate : Bool?

  def initialize(
    @name : String,
    @has_certificate : Bool?,
  ); end
end
