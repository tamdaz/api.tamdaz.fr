class App::DTO::TWDTO < App::Interfaces::DTOInterface
  include AVD::Validatable
  include JSON::Serializable

  @[Assert::NotBlank(message: "Le titre ne doit pas être vide.")]
  getter title : String

  @[Assert::NotBlank(message: "La description ne doit pas être vide.")]
  getter description : String

  @[Assert::URL(message: "L'URL de l'image spécifiée n'est pas valide.")]
  @[Assert::NotBlank(message: "Veuillez spécifier l'URL de l'image présentant l'article de la VT.")]
  getter image_url : String

  @[Assert::URL(message: "L'URL de la source spécifiée n'est pas valide.")]
  @[Assert::NotBlank(message: "Veuillez spécifier l'URL de la source présentant l'article de la VT.")]
  getter source_url : String

  getter published_at : Time?

  @[Assert::NotBlank(message: "Le nom de la source est requise.")]
  getter source : String

  def initialize(
    @title : String,
    @description : String,
    @image_url : String,
    @source_url : String,
    @source : String,
    @published_at : Time? = nil,
  ); end
end
