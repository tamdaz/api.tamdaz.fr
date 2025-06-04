@[ADI::Register]
@[ARTA::Route("/categories")]
class App::Controllers::API::CategoryController < App::Controllers::AbstractController
  def initialize(
    @category_repository : App::Repositories::CategoryRepository,
  ); end

  # Get all categories
  @[ARTA::Get("/")]
  def index : Array(App::Entities::Category)
    @category_repository.find_all
  end

  # Get the category by its slug.
  @[ARTA::Get("/{slug}")]
  def show(slug : String) : App::Entities::Category
    @category_repository.find(slug)
  end

  # Create a new category.
  @[ARTA::Post("/create")]
  def create(
    @[ATHA::MapRequestBody] category_dto : App::DTO::CategoryDTO,
  ) : ATH::StreamedResponse
    @category_repository.create(category_dto)

    send_json(200, "Une nouvelle catégorie (#{category_dto.name}) a bien été créé.")
  end

  # Update the category by its slug.
  @[ARTA::Put("/{slug}/update")]
  def update(
    slug : String, @[ATHA::MapRequestBody] category_dto : App::DTO::CategoryDTO,
  ) : ATH::StreamedResponse
    @category_repository.update(slug, category_dto)

    send_json(200, "La catégorie #{slug} a bien été mise à jour.")
  end

  # Delete the category by its slug.
  @[ARTA::Delete("/{slug}/delete")]
  def delete(slug : String) : ATH::StreamedResponse
    @category_repository.delete(slug)

    send_json(200, "La catégorie #{slug} a bien été supprimée.")
  end
end
