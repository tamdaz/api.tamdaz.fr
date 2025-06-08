class App::DTO::AdminIPDTO
  include AVD::Validatable
  include JSON::Serializable

  @[Assert::IP]
  @[Assert::NotBlank]
  property ip : String

  def initialize(@ip : String); end
end
