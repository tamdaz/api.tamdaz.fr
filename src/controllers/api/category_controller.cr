@[ARTA::Route("/categories")]
class App::Controllers::API::CategoryController < App::Controllers::AbstractController
  # Get all categories
  @[ARTA::Get("/")]
  def index : Array(App::Models::Category)
    App::Models::Category.all.to_a
  end

  # Get the category by its slug.
  @[ARTA::Get("/{slug}")]
  def show(slug : String) : App::Models::Category | ATH::StreamedResponse
    App::Models::Category.find_by!(slug: slug)
  rescue e : Granite::Querying::NotFound
    send_json(404, "Le blog #{slug} n'a pas été trouvée.")
  end

  # Create a new category.
  @[ARTA::Post("/create")]
  def create(@[ATHA::MapRequestBody] category_dto : App::DTO::CategoryDTO) : ATH::StreamedResponse
    App::Models::Category.create!(
      name: category_dto.name,
      usage: select_usage!(category_dto.usage)
    )

    send_json(200, "Une nouvelle catégorie #{category_dto.name} a bien été créé.")
  rescue e : Granite::RecordNotSaved
    send_json(500, "Une erreur s'est produite lors de l'enregistrement d'une nouvelle catégorie.")
  end

  # Update the category by its slug.
  @[ARTA::Put("/{slug}/update")]
  def update(slug : String, @[ATHA::MapRequestBody] category_dto : App::DTO::CategoryDTO) : ATH::StreamedResponse
    App::Models::Category.find_by!(slug: slug).update!(
      name: category_dto.name,
      usage: select_usage!(category_dto.usage)
    )

    send_json(200, "La catégorie #{category_dto.name} a bien été mise à jour.")
  rescue e : Granite::RecordNotSaved
    send_json(500, "Une erreur s'est produite lors de la modification de la catégorie #{category_dto.name}.")
  end

  # Delete the category by its slug.
  @[ARTA::Delete("/{slug}/delete")]
  def delete(slug : String) : ATH::StreamedResponse
    found_category = App::Models::Category.find_by!(slug: slug)
    found_category.destroy!

    send_json(200, "La catégorie #{found_category.name} a bien été supprimée.")
  rescue e : Granite::Querying::NotFound
    send_json(404, "Le blog #{slug} n'a pas été trouvée.")
  end

  # Select an usage for an created or updated category.
  private def select_usage!(usage : String) : App::Enums::Categories::Usage
    case usage
    when "Blogs"    then App::Enums::Categories::Usage::Blogs
    when "Reports"  then App::Enums::Categories::Usage::Reports
    when "Projects" then App::Enums::Categories::Usage::Projects
    else
      raise "L'utilisation de la catégorie est inconnue."
    end
  end
end
