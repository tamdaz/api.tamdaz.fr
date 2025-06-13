class App::DTO::CertificationDTO < App::Interfaces::DTOInterface
  include AVD::Validatable
  include JSON::Serializable

  @[Assert::NotBlank(message: "Le nom ne doit pas être vide.")]
  getter name : String

  @[Assert::NotNil(message: "Veuillez spécifier si la certification est fournie ou non.")]
  getter has_certificate : Bool?

  def initialize(@name : String, @has_certificate : Bool?); end

  def initialize(form_data : App::Services::FormData)
    has_keys = %w(name has_certificate).all? do |key|
      form_data.data.has_key?(key)
    end

    if has_keys
      @name = form_data.data["name"]
      @has_certificate = form_data.data["has_certificate"]? == "true"
    else
      raise ATH::Exception::BadRequest.new "Some keys are missing in the request"
    end
  end
end
