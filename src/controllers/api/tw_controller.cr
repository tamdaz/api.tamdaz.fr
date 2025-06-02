@[ARTA::Route("/tws")]
class App::Controllers::API::TWController < App::Controllers::AbstractController
  # Get all articles of the technology watch.
  @[ARTA::Get("/")]
  def index : Array(App::Models::TW)
    App::Models::TW.all.to_a
  end

  # Get the article of the technology watch by its ID.
  @[ARTA::Get("/{id}")]
  def show(id : Int64) : App::Models::TW | ATH::StreamedResponse
    App::Models::TW.find!(id)
  rescue e : Granite::Querying::NotFound
    send_json(404, "L'article de la veille technologique n°#{id} n'a pas été trouvée.")
  end

  # Create an article of the technology watch by its ID.
  @[ARTA::Post("/create")]
  def create(@[ATHA::MapRequestBody] tw_dto : App::DTO::TWDTO) : ATH::StreamedResponse
    found_tw = App::Models::TW.create!(
      title: tw_dto.title,
      description: tw_dto.description,
      image_url: tw_dto.image_url,
      source_url: tw_dto.source_url,
      published_at: tw_dto.published_at,
      source: tw_dto.source,
    )

    send_json(200, "L'article de la veille technologique #{found_tw.id} a bien été créé.")
  rescue e : Granite::RecordNotSaved
    send_json(500, "Une erreur s'est produite lors de l'enregistrement d'un nouvel article de la veille technologique.")
  end

  # Update the article of the technology watch by its ID.
  @[ARTA::Put("/{id}/update")]
  def update(id : Int64, @[ATHA::MapRequestBody] tw_dto : App::DTO::TWDTO) : ATH::StreamedResponse
    found_dto = App::Models::TW.find!(id)
    found_dto.update!(
      title: tw_dto.title,
      description: tw_dto.description,
      image_url: tw_dto.image_url,
      source_url: tw_dto.source_url,
      published_at: tw_dto.published_at,
      source: tw_dto.source,
    )

    send_json(200, "L'article de la veille technologique #{id} a bien été mis à jour.")
  rescue e : Granite::RecordNotSaved
    send_json(500, "Une erreur s'est produite lors de la mise à jour de L'article de la veille technologique n°#{id}.")
  end

  # Delete the article of the technology watch by its ID.
  @[ARTA::Delete("/{id}/delete")]
  def delete(id : Int64) : ATH::StreamedResponse
    App::Models::TW.find!(id).destroy!

    send_json(200, "L'article de la veille technologique #{id} a bien été supprimé.")
  rescue e : Granite::Querying::NotFound
    send_json(404, "L'article de la veille technologique n°#{id} n'a pas été trouvée.")
  end
end
