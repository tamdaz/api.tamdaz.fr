@[ARTA::Route("/timelines")]
class App::Controllers::API::TimelineController < App::Controllers::AbstractController
  # Get all timelines (professional experiences and formations).
  @[ARTA::Get("/")]
  def index : Array(App::Models::Timeline)
    App::Models::Timeline.all.to_a
  end

  # Get the timeline by its ID.
  @[ARTA::Get("/{id}")]
  def show(id : Int64) : App::Models::Timeline | ATH::StreamedResponse
    App::Models::Timeline.find!(id)
  rescue e : Granite::Querying::NotFound
    send_json(404, "La timeline n°#{id} n'a pas été trouvée.")
  end

  # Create a timeline.
  @[ARTA::Post("/create")]
  def create(@[ATHA::MapRequestBody] timeline_dto : App::DTO::TimelineDTO) : ATH::StreamedResponse
    found_timeline = App::Models::Timeline.create!(
      date_start: timeline_dto.date_start,
      date_end: timeline_dto.date_end,
      description: timeline_dto.description,
      type: timeline_dto.type
    )

    send_json(200, "Le timeline #{found_timeline.id} a bien été créé.")
  rescue e : Granite::RecordNotSaved
    send_json(500, "Une erreur s'est produite lors de l'enregistrement d'une nouvelle timeline.")
  end

  # Update the timeline by its ID.
  @[ARTA::Put("/{id}/update")]
  def update(id : Int64, @[ATHA::MapRequestBody] timeline_dto : App::DTO::TimelineDTO) : ATH::StreamedResponse
    found_timeline = App::Models::Timeline.find!(id)
    found_timeline.update!(
      date_start: timeline_dto.date_start,
      date_end: timeline_dto.date_end,
      description: timeline_dto.description,
      type: timeline_dto.type
    )

    send_json(200, "La timeline #{found_timeline.id} a bien été mis à jour.")
  rescue e : Granite::RecordNotSaved
    send_json(500, "Une erreur s'est produite lors de l'enregistrement de la timeline n°#{id}.")
  end

  # Delete the timeline by its ID.
  @[ARTA::Delete("/{id}/delete")]
  def delete(id : Int64) : ATH::StreamedResponse
    App::Models::Timeline.find!(id).destroy!

    send_json(200, "Le timeline #{id} a bien été supprimé.")
  rescue e : Granite::Querying::NotFound
    send_json(404, "La timeline n°#{id} n'a pas été trouvée.")
  end
end
