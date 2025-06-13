class App::DTO::SkillDTO < App::Interfaces::DTOInterface
  include AVD::Validatable
  include JSON::Serializable

  @[Assert::NotBlank(message: "Le nom est requis.")]
  getter name : String

  @[Assert::NotBlank(message: "La description est requise.")]
  getter description : String

  @[Assert::NotNil(message: "Veuillez spécifier si le logo a des couleurs ou non.")]
  getter has_colors : Bool?

  def initialize(@name : String, @description : String, @has_colors : Bool?); end

  def initialize(form_data : App::Services::FormData)
    has_keys = %w(name description has_colors).all? do |key|
      form_data.data.has_key?(key)
    end

    if has_keys
      @name = form_data.data["name"]
      @description = form_data.data["description"]
      @has_colors = form_data.data["has_colors"]? == "true"
    else
      raise ATH::Exception::BadRequest.new "Some keys are missing in the request"
    end
  end
end
