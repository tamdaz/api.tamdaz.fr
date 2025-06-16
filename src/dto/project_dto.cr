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
    @title : String, @description : String?, @content : String?,
    @category_id : Int64?, @realized_at : Time?, @published_at : Time?,
  ); end

  def initialize(form_data : App::Services::FormData)
    if has_keys?(form_data)
      category_id = form_data.data["category_id"]

      published_at = if !form_data.data["published_at"].empty?
                       Time.parse_local(form_data.data["published_at"], "%F")
                     else
                       nil
                     end

      @title = form_data.data["title"]
      @description = form_data.data["description"]
      @content = form_data.data["content"]
      @category_id = category_id.empty? ? 0i64 : category_id.to_i64
      @realized_at = Time.parse_local(form_data.data["realized_at"], "%F")
      @published_at = published_at
    else
      raise ATH::Exception::BadRequest.new "Some keys are missing in the request"
    end
  end
end
