class App::DTO::BlogDTO < App::Interfaces::DTOInterface
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
    @title : String, @description : String?, @content : String?,
    @is_published : Bool?, @category_id : Int64,
  ); end

  def initialize(form_data : App::Services::FormData)
    has_keys = %w(title description content is_published category_id thumbnail).all? do |key|
      form_data.data.has_key?(key)
    end

    if has_keys
      category_id = form_data.data["category_id"]
      is_published = form_data.data["is_published"]? == "true"

      @title = form_data.data["title"]
      @description = form_data.data["description"]
      @content = form_data.data["content"]
      @is_published = is_published
      @category_id = category_id.empty? ? 0i64 : category_id.to_i64
    else
      raise ATH::Exception::BadRequest.new "Some keys are missing in the request"
    end
  end
end
