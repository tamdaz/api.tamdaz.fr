@[ADI::Register]
@[ARTA::Route("/categories")]
class App::Controllers::API::CategoryController < App::Controllers::AbstractController
  def initialize(@category_repository : App::Repositories::CategoryRepository); end

  # Retrieves all categories
  @[ARTA::Get("")]
  def index : Array(App::Entities::Category)
    @category_repository.find_all
  end

  # Retrieves the category by its slug.
  @[ARTA::Get("/{slug}")]
  def show(slug : String) : App::Entities::Category | ATH::StreamedResponse
    @category_repository.find(slug)
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "La catégorie #{slug} n'a pas été trouvée.")
  end

  # Creates a new category.
  @[ARTA::Post("/create")]
  def create(
    @[ATHA::MapRequestBody] category_dto : App::DTO::CategoryDTO,
  ) : ATH::StreamedResponse
    @category_repository.create(category_dto)
    send_json(200, "Une nouvelle catégorie (#{category_dto.name}) a bien été créé.")
  rescue App::Exceptions::DuplicatedIDException
    send_json(422, "Vous ne pouvez pas créer une catégorie qui a le même nom.")
  end

  # Updates the category by its slug.
  @[ARTA::Put("/{slug}/update")]
  def update(slug : String, @[ATHA::MapRequestBody] category_dto : App::DTO::CategoryDTO) : ATH::StreamedResponse
    @category_repository.update(slug, category_dto)
    send_json(200, "La catégorie #{slug} a bien été mise à jour.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "La catégorie #{slug} n'a pas été trouvée.")
  rescue App::Exceptions::DuplicatedIDException
    send_json(422, "Vous ne pouvez pas mettre à jour une catégorie qui a le même nom.")
  end

  # Deletes the category by its slug.
  @[ARTA::Delete("/{slug}/delete")]
  def delete(slug : String) : ATH::StreamedResponse
    @category_repository.delete(slug)
    send_json(200, "La catégorie #{slug} a bien été supprimée.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "La catégorie #{slug} n'a pas été trouvée.")
  end
end
