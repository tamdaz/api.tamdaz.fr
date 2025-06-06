@[ADI::Register]
@[ARTA::Route("/certifications")]
class App::Controllers::API::CertificationController < App::Controllers::AbstractController
  include App::Modules::FileManager
  include App::Modules::Validator

  ENTITY_NAME = App::Entities::Certification.name

  def initialize(
    @form_data : App::Services::FormData,
    @event_dispatcher : AED::EventDispatcherInterface,
    @certification_repository : App::Repositories::CertificationRepository,
    @file_repository : App::Repositories::FileRepository,
  ); end

  # Retrieves all certifications.
  @[ARTA::Get("/")]
  def index : Array(App::Entities::Certification)
    @certification_repository.find_all
  end

  # Retrieves the certification by its ID.
  @[ARTA::Get("/{id}")]
  def show(id : Int64) : App::Entities::Certification
    @certification_repository.find(id)
  end

  # Creates a new certification.
  @[ARTA::Post("/create")]
  def create(@[TZ::MapFormRequest] dto : App::DTO::CertificationDTO) : ATH::StreamedResponse
    last_certification_id = @certification_repository.create(dto)
    save_file!(last_certification_id, "pdf_file", ENTITY_NAME)

    @event_dispatcher.dispatch(App::Events::ClearUploadedFiles.new)

    send_json(200, "Une nouvelle certification n°#{last_certification_id} a bien été créé.")
  end

  # Updates the certification by its ID.
  @[ARTA::Put("/{id}/update")]
  def update(id : Int64, @[TZ::MapFormRequest] dto : App::DTO::CertificationDTO) : ATH::StreamedResponse
    certification_id = @certification_repository.update(id, dto)

    unless @form_data.data["pdf_file"]?
      update_file(id, "pdf_file", ENTITY_NAME)
    end

    @event_dispatcher.dispatch(App::Events::ClearUploadedFiles.new)

    send_json(200, "La certification n°#{id} a bien été mise à jour.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "La certification n°#{id} n'a pas été trouvée.")
  end

  # Deletes the certification by its ID.
  @[ARTA::Delete("/{id}/delete")]
  def delete(id : Int64) : ATH::StreamedResponse
    @certification_repository.delete(id)

    @event_dispatcher.dispatch(App::Events::ClearUploadedFiles.new)

    send_json(200, "La certification n°#{id} a bien été supprimée.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "La certification n°#{id} n'a pas été trouvée.")
  end
end
