@[ADI::Register]
@[ARTA::Route("/tws")]
class App::Controllers::API::TWController < App::Controllers::AbstractController
  include App::Modules::Validator

  def initialize(@tw_repository : App::Repositories::TWRepository); end

  # Get all articles of the technology watch.
  @[ARTA::Get("/")]
  def index : Array(App::Entities::TW)
    @tw_repository.find_all
  end

  # Get the article of the technology watch by its ID.
  @[ARTA::Get("/{id}")]
  def show(id : Int64) : App::Entities::TW | ATH::StreamedResponse
    @tw_repository.find(id)
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "L'article de la V.T n°#{id} n'a pas été trouvée.")
  end

  # Create an article of the technology watch by its ID.
  @[ARTA::Post("/create")]
  def create(@[ATHA::MapRequestBody] dto : App::DTO::TWDTO) : ATH::StreamedResponse
    @tw_repository.create(dto)
    send_json(200, "Une nouvelle article de la V.T a bien été créé.")
  end

  # Update the article of the technology watch by its ID.
  @[ARTA::Put("/{id}/update")]
  def update(id : Int64, @[ATHA::MapRequestBody] dto : App::DTO::TWDTO) : ATH::StreamedResponse
    @tw_repository.update(id, dto)
    send_json(200, "L'article de la V.T #{id} a bien été mis à jour.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "L'article de la V.T n°#{id} n'a pas été trouvée.")
  end

  # Delete the article of the technology watch by its ID.
  @[ARTA::Delete("/{id}/delete")]
  def delete(id : Int64) : ATH::StreamedResponse
    @tw_repository.delete(id)
    send_json(200, "L'article de la V.T #{id} a bien été supprimé.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "L'article de la V.T n°#{id} n'a pas été trouvée.")
  end
end
