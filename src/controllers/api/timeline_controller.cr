@[ADI::Register]
@[ARTA::Route("/timelines")]
class App::Controllers::API::TimelineController < App::Controllers::AbstractController
  def initialize(
    @timeline_repository : App::Repositories::TimelineRepository,
  ); end

  # Get all timelines (professional experiences and formations).
  @[ARTA::Get("/")]
  def index : Array(App::Entities::Timeline)
    @timeline_repository.find_all
  end

  # Get the timeline by its ID.
  @[ARTA::Get("/{id}")]
  def show(id : Int64) : App::Entities::Timeline
    @timeline_repository.find(id)
  end

  # Create a timeline.
  @[ARTA::Post("/create")]
  def create(@[ATHA::MapRequestBody] timeline_dto : App::DTO::TimelineDTO) : ATH::StreamedResponse
    @timeline_repository.create(timeline_dto)
    send_json(200, "Le nouveau timeline a bien été créé.")
  end

  # Update the timeline by its ID.
  @[ARTA::Put("/{id}/update")]
  def update(id : Int64, @[ATHA::MapRequestBody] timeline_dto : App::DTO::TimelineDTO) : ATH::StreamedResponse
    @timeline_repository.update(id, timeline_dto)
    send_json(200, "La timeline #{id} a bien été mis à jour.")
  end

  # Delete the timeline by its ID.
  @[ARTA::Delete("/{id}/delete")]
  def delete(id : Int64) : ATH::StreamedResponse
    @timeline_repository.delete(id)
    send_json(200, "Le timeline #{id} a bien été supprimé.")
  end
end
