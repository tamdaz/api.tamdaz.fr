class App::DTO::ReportDTO < App::Interfaces::DTOInterface
  include AVD::Validatable
  include JSON::Serializable

  @[Assert::NotBlank(message: "Le titre ne doit pas être vide.")]
  getter title : String

  @[Assert::NotEqualTo(0, message: "Veuillez spécifier la catégorie.")]
  getter category_id : Int64

  getter created_at : Time

  def initialize(@title : String, @category_id : Int64, @created_at : Time); end

  def initialize(form_data : App::Services::FormData)
    if has_keys?(form_data)
      category_id = form_data.data["category_id"]

      @title = form_data.data["title"]
      @category_id = category_id.empty? ? 0i64 : category_id.to_i64
      @created_at = Time.parse_utc(form_data.data["created_at"], "%F")
    else
      raise ATH::Exception::BadRequest.new "Some keys are missing in the request"
    end
  end
end
