class App::DTO::ProjectDTO < App::Interfaces::DTOInterface
  include AVD::Validatable
  include JSON::Serializable

  @[Assert::NotBlank(message: "Le titre ne doit pas être vide.")]
  @[Assert::Size(3..255)]
  getter title : String

  getter description : String?

  getter content : String?

  @[Assert::NotEqualTo(0, message: "Veuillez spécifier la catégorie.")]
  getter category_id : Int64?

  @[Assert::NotBlank(message: "La date de réalisation du projet est obligatoire.")]
  getter realized_at : Time?

  getter published_at : Time?

  def initialize(
    @title : String,
    @description : String?,
    @content : String?,
    @category_id : Int64?,
    @realized_at : Time?,
    @published_at : Time?,
  ); end
end
