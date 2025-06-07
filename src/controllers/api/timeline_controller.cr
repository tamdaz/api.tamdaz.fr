@[ADI::Register]
@[ARTA::Route("/timelines")]
class App::Controllers::API::TimelineController < App::Controllers::AbstractController
  def initialize(
    @timeline_repository : App::Repositories::TimelineRepository,
  ); end

  # Retrieves all timelines (professional experiences and formations).
  @[ARTA::Get("")]
  def index : Array(App::Entities::Timeline)
    @timeline_repository.find_all
  end

  # Retrieves the timeline by its ID.
  @[ARTA::Get("/{id}")]
  def show(id : Int64) : App::Entities::Timeline | ATH::StreamedResponse
    @timeline_repository.find(id)
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "La timeline n°#{id} n'a pas été trouvée.")
  end

  # Creates a timeline.
  @[ARTA::Post("/create")]
  def create(@[ATHA::MapRequestBody] dto : App::DTO::TimelineDTO) : ATH::StreamedResponse
    @timeline_repository.create(dto)
    send_json(200, "Le nouveau timeline a bien été créé.")
  end

  # Updates the timeline by its ID.
  @[ARTA::Put("/{id}/update")]
  def update(id : Int64, @[ATHA::MapRequestBody] dto : App::DTO::TimelineDTO) : ATH::StreamedResponse
    @timeline_repository.update(id, dto)
    send_json(200, "La timeline #{id} a bien été mis à jour.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "La timeline n°#{id} n'a pas été trouvée.")
  end

  # Deletes the timeline by its ID.
  @[ARTA::Delete("/{id}/delete")]
  def delete(id : Int64) : ATH::StreamedResponse
    @timeline_repository.delete(id)
    send_json(200, "Le timeline #{id} a bien été supprimé.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "La timeline n°#{id} n'a pas été trouvée.")
  end
end
