require "uuid"

@[ADI::Register]
@[ARTA::Route("/reports")]
class App::Controllers::API::ReportController < App::Controllers::AbstractController
  include App::Interfaces::FileUploadInterface

  def initialize(
    @form_data : App::Services::FormData,
    @event_dispatcher : AED::EventDispatcherInterface,
  ); end

  # Get all reports.
  @[ARTA::Get("/")]
  def index : Array(App::Models::Report)
    App::Models::Report.all.to_a
  end

  # Get the report by its ID.
  @[ARTA::Get("/{id}")]
  def show(id : String) : App::Models::Report | ATH::StreamedResponse
    App::Models::Report.find!(id)
  rescue e : Granite::Querying::NotFound
    send_json(404, "Le compte rendu n°#{id} n'a pas été trouvé")
  end

  # Create a report.
  @[ARTA::Post("/create")]
  def create(req : ATH::Request) : ATH::StreamedResponse
    @form_data.start_parse(req)

    validate_report = AVD.validator.validate(report_dto)

    unless validate_report.empty?
      return send_json { |io| validate_report.to_json io }
    end

    report = App::Models::Report.create!(
      title: report_dto.title,
      category_id: report_dto.category_id,
      created_at: report_dto.created_at
    )

    save_file!(report.id!, "pdf_file")

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Un nouveau compte-rendu a bien été créé.")
  rescue e : Granite::RecordNotSaved
    send_json(500, "Une erreur s'est produite lors de l'enregistrement d'un nouveau compte-rendu.")
  end

  # Update the report by its ID.
  @[ARTA::Put("/{id}/update")]
  def update(id : Int64, req : ATH::Request) : ATH::StreamedResponse
    @form_data.start_parse(req)

    validate_report = AVD.validator.validate(report_dto)

    unless validate_report.empty?
      return send_json { |io| validate_report.to_json io }
    end

    report = App::Models::Report.find!(id)

    report.update!(
      title: report_dto.title,
      category_id: report_dto.category_id,
      created_at: report_dto.created_at
    )

    unless @form_data.data["pdf_file"]?
      update_file(report.id!, "pdf_file")
    end

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Le compte-rendu n°#{id} a bien été mis à jour.")
  rescue e : Granite::RecordNotSaved
    send_json(500, "Une erreur s'est produite lors de la modification du compre-rendu n°#{id}.")
  end

  # Delete the report by its ID.
  @[ARTA::Delete("/{id}/delete")]
  def delete(id : Int64) : ATH::StreamedResponse
    found_report = App::Models::Report.find!(id)

    found_file = App::Models::File.find_by!(model_id: id, model_type: App::Models::Report.name)
    File.delete("./uploads/#{found_file.path}")

    found_report.destroy!
    found_file.destroy!

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Le compte-rendu n°#{id} a bien été supprimé.")
  rescue e : Granite::Querying::NotFound
    send_json(500, "Une erreur s'est produite lors de la suppression du compte-rendu n°#{id}.")
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

  # Save a new file into the `storage/` directory.
  private def save_file!(id : Int64, name : String) : Void
    path_file = @form_data.store_file(name, UUID.random.to_s)

    App::Models::File.create!(
      model_id: id,
      model_type: App::Models::Report.name,
      path: path_file
    )
  end

  # Save a new file to replace, if the user have uploaded one.
  private def update_file(id : Int64, name : String) : Void
    if @form_data.find_file(name)
      found_file = App::Models::File.find_by!(model_id: id, model_type: App::Models::Report.name)
      File.delete("./uploads/#{found_file.path}")

      path_file = @form_data.store_file(name, UUID.random.to_s)
      found_file.update!(path: path_file)
    end
  end
end
