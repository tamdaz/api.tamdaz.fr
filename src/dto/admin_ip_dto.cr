class App::DTO::AdminIPDTO
  include AVD::Validatable
  include JSON::Serializable

  @[Assert::IP]
  property ip : String

  def initialize(@ip : String); end
end
