require "uuid"

@[ADI::Register]
@[ARTA::Route("/reports")]
class App::Controllers::API::ReportController < App::Controllers::AbstractController
  include App::Modules::FileManager
  include App::Modules::Validator

  ENTITY_NAME = App::Entities::Report.name

  def initialize(
    @form_data : App::Services::FormData,
    @event_dispatcher : AED::EventDispatcherInterface,
    @file_repository : App::Repositories::FileRepository,
    @report_repository : App::Repositories::ReportRepository,
  ); end

  # Retrieves all reports.
  @[ARTA::Get("/")]
  def index : Array(App::Entities::Report)
    @report_repository.find_all
  end

  # Retrieves the report by its ID.
  @[ARTA::Get("/{id}")]
  def show(id : Int64) : App::Entities::Report | ATH::StreamedResponse
    @report_repository.find(id)
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "Le compte-rendu n°#{id} n'a pas été trouvée.")
  end

  # Creates a report.
  @[ARTA::Post("/create")]
  def create(@[TZ::MapFormRequest] dto : App::DTO::ReportDTO) : ATH::StreamedResponse
    last_report_id = @report_repository.create(dto)

    save_file!(last_report_id, "pdf_file", ENTITY_NAME)

    @event_dispatcher.dispatch(App::Events::ClearUploadedFiles.new)

    send_json(200, "Un nouveau compte-rendu a bien été créé.")
  rescue App::Exceptions::DuplicatedIDException
    send_json(422, "Vous ne pouvez pas mettre à jour un compte-rendu qui a le même slug qu'un autre.")
  end

  # Updates the report by its ID.
  @[ARTA::Put("/{id}/update")]
  def update(id : Int64, @[TZ::MapFormRequest] dto : App::DTO::ReportDTO) : ATH::StreamedResponse
    report_id = @report_repository.update(id, dto)

    unless @form_data.data["pdf_file"]?
      update_file(report_id, "pdf_file", ENTITY_NAME)
    end

    @event_dispatcher.dispatch(App::Events::ClearUploadedFiles.new)

    send_json(200, "Le compte-rendu n°#{id} a bien été mis à jour.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "Le compte-rendu n°#{id} n'a pas été trouvée.")
  rescue App::Exceptions::DuplicatedIDException
    send_json(422, "Vous ne pouvez pas mettre à jour un blog qui a le même slug qu'un autre.")
  end

  # Deletes the report by its ID.
  @[ARTA::Delete("/{id}/delete")]
  def delete(id : Int64) : ATH::StreamedResponse
    @report_repository.delete(id)

    @event_dispatcher.dispatch(App::Events::ClearUploadedFiles.new)

    send_json(200, "Le compte-rendu n°#{id} a bien été supprimé.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "Le compte-rendu n°#{id} n'a pas été trouvée.")
  end
end
