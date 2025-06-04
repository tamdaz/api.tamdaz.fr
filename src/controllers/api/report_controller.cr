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

  # Get all reports.
  @[ARTA::Get("/")]
  def index : Array(App::Entities::Report)
    @report_repository.find_all
  end

  # Get the report by its ID.
  @[ARTA::Get("/{id}")]
  def show(id : Int64) : App::Entities::Report
    @report_repository.find(id)
  end

  # Create a report.
  @[ARTA::Post("/create")]
  def create(form_data : App::Services::FormData) : ATH::StreamedResponse
    do_validation(report_dto)

    last_report_id = @report_repository.create(report_dto)

    save_file!(last_report_id, "pdf_file", ENTITY_NAME)

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Un nouveau compte-rendu a bien été créé.")
  end

  # Update the report by its ID.
  @[ARTA::Put("/{id}/update")]
  def update(id : Int64, form_data : App::Services::FormData) : ATH::StreamedResponse
    do_validation(report_dto)

    report_id = @report_repository.update(id, report_dto)

    unless @form_data.data["pdf_file"]?
      update_file(report_id, "pdf_file", ENTITY_NAME)
    end

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Le compte-rendu n°#{id} a bien été mis à jour.")
  end

  # Delete the report by its ID.
  @[ARTA::Delete("/{id}/delete")]
  def delete(id : Int64) : ATH::StreamedResponse
    @report_repository.delete(id)

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Le compte-rendu n°#{id} a bien été supprimé.")
  end

  # Store all informations into the DTO for the report's processing.
  private def report_dto : App::DTO::ReportDTO
    category_id = @form_data.data["category_id"]

    App::DTO::ReportDTO.new(
      title: @form_data.data["title"],
      category_id: category_id.empty? ? 0i64 : category_id.to_i64,
      created_at: Time.parse_local(@form_data.data["created_at"], "%F")
    )
  end
end
