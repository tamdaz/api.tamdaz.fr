class App::Entities::AdminIP
  include AVD::Validatable
  include DB::Serializable

  @[Assert::IP]
  @[Assert::NotBlank]
  property ip : String

  def initialize(@ip : String); end
end
