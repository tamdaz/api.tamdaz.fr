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

  # Get all certifications.
  @[ARTA::Get("/")]
  def index : Array(App::Entities::Certification)
    @certification_repository.find_all
  end

  # Get the certification by its ID.
  @[ARTA::Get("/{id}")]
  def show(id : Int64) : App::Entities::Certification
    @certification_repository.find(id)
  end

  # Create a new certification.
  @[ARTA::Post("/create")]
  def create(form_data : App::Services::FormData) : ATH::StreamedResponse
    do_validation(certification_dto)

    last_certification_id = @certification_repository.create(certification_dto)
    save_file!(last_certification_id, "pdf_file", ENTITY_NAME)

    @event_dispatcher.dispatch(App::Events::ClearTemporaryFilesEvent.new)

    send_json(200, "Une nouvelle certification  a bien été créé.")
  end

  # Update the certification by its ID.
  @[ARTA::Put("/{id}/update")]
  def update(id : Int64, form_data : App::Services::FormData) : ATH::StreamedResponse
    do_validation(certification_dto)

    certification_id = @certification_repository.update(id, certification_dto)

    unless @form_data.data["pdf_file"]?
      update_file(id, "pdf_file", ENTITY_NAME)
    end

    @event_dispatcher.dispatch(App::Events::ClearTemporaryFilesEvent.new)

    send_json(200, "La certification n°#{id} a bien été mise à jour.")
  end

  # Delete the certification by its ID.
  @[ARTA::Delete("/{id}/delete")]
  def delete(id : Int64) : ATH::StreamedResponse
    @certification_repository.delete(id)

    @event_dispatcher.dispatch(App::Events::ClearTemporaryFilesEvent.new)

    send_json(200, "La certification n°#{id} a bien été supprimée.")
  end

  # Store informations into the DTO for the certification's processing.
  def certification_dto : App::DTO::CertificationDTO
    has_certificate = @form_data.data["has_certificate"]? == "true"

    App::DTO::CertificationDTO.new(
      name: @form_data.data["name"],
      has_certificate: has_certificate
    )
  end
end
