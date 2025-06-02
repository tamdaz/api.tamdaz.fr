struct App::DTO::CategoryDTO
  include AVD::Validatable
  include JSON::Serializable

  @[Assert::NotBlank(message: "Le nom ne doit pas être vide.")]
  getter name : String

  @[Assert::Choice(
    App::Enums::Categories::Usage.names,
    message: "Veuillez choisir l'une des 3 usages : 'Blogs', 'Categories' et 'Reports'."
  )]
  getter usage : String
end
