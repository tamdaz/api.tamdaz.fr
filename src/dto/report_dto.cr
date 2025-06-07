class App::DTO::ReportDTO < App::Interfaces::DTOInterface
  include AVD::Validatable
  include JSON::Serializable

  @[Assert::NotBlank(message: "Le titre ne doit pas être vide.")]
  getter title : String

  @[Assert::NotEqualTo(0, message: "Veuillez spécifier la catégorie.")]
  getter category_id : Int64

  getter created_at : Time

  def initialize(@title : String, @category_id : Int64, @created_at : Time); end
end
