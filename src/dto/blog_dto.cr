struct App::DTO::BlogDTO
  include AVD::Validatable
  include JSON::Serializable

  @[Assert::NotBlank(message: "Le titre ne doit pas être vide.")]
  getter title : String

  getter description : String?

  getter content : String?

  @[Assert::NotNil(message: "Veuillez spécifier si le blog doit être publié ou non.")]
  getter is_published : Bool?

  @[Assert::NotEqualTo(0, message: "Veuillez spécifier la catégorie.")]
  getter category_id : Int64

  def initialize(
    @title : String,
    @description : String?,
    @content : String?,
    @is_published : Bool?,
    @category_id : Int64,
  ); end
end
