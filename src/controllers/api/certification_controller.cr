@[ADI::Register]
@[ARTA::Route("/certifications")]
class App::Controllers::API::CertificationController < App::Controllers::AbstractController
  include App::Interfaces::FileUploadInterface

  def initialize(
    @form_data : App::Services::FormData,
    @event_dispatcher : AED::EventDispatcherInterface,
  ); end

  # Get all certifications.
  @[ARTA::Get("/")]
  def index : Array(App::Models::Certification)
    App::Models::Certification.all.to_a
  end

  # Get the certification by its ID.
  @[ARTA::Get("/{id}")]
  def show(id : Int64) : App::Models::Certification | ATH::StreamedResponse
    App::Models::Certification.find!(id)
  rescue e : Granite::Querying::NotFound
    send_json(404, "La certification n°#{id} n'a pas été trouvée")
  end

  # Create a new certification.
  @[ARTA::Post("/create")]
  def create(req : ATH::Request) : ATH::StreamedResponse
    @form_data.start_parse(req)

    validate_certification = AVD.validator.validate(certification_dto)

    unless validate_certification.empty?
      return send_json { |io| validate_certification.to_json io }
    end

    certification = App::Models::Certification.create!(
      name: certification_dto.name,
      has_certificate: certification_dto.has_certificate
    )

    save_file!(certification.id!, "pdf_file")

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Une nouvelle certification n°#{certification.id} a bien été créé.")
  rescue e : Granite::RecordNotSaved
    send_json(500, "Une erreur s'est produite lors de l'enregistrement d'une nouvelle certification.")
  end

  # Update the certification by its ID.
  @[ARTA::Put("/{id}/update")]
  def update(id : Int64, req : ATH::Request) : ATH::StreamedResponse
    @form_data.start_parse(req)

    validate_certification = AVD.validator.validate(certification_dto)

    unless validate_certification.empty?
      return send_json { |io| validate_certification.to_json io }
    end

    certification = App::Models::Certification.find!(id).update!(
      name: certification_dto.name,
      has_certificate: certification_dto.has_certificate
    )

    unless @form_data.data["pdf_file"]?
      update_file(id, "pdf_file")
    end

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "La certification n°#{id} a bien été mise à jour.")
  rescue e : Granite::RecordNotSaved
    send_json(500, "Une erreur s'est produite lors de la certification de la certification n°#{id}.")
  end

  # Delete the certification by its ID.
  @[ARTA::Delete("/{id}/delete")]
  def delete(id : Int64) : ATH::StreamedResponse
    found_certification = App::Models::Certification.find!(id)

    found_file = App::Models::File.find_by!(
      model_id: id,
      model_type: App::Models::Certification.name
    )

    File.delete("./uploads/#{found_file.path}")

    found_certification.destroy!
    found_file.destroy!

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "La certification n°#{id} a bien été supprimée.")
  rescue e : Granite::Querying::NotFound
    send_json(404, "La certification n°#{id} n'a pas été trouvée.")
  end

  # Store informations into the DTO for the certification's processing.
  def certification_dto : App::DTO::CertificationDTO
    has_certificate = @form_data.data["has_certificate"]? == "true"

    App::DTO::CertificationDTO.new(
      name: @form_data.data["name"],
      has_certificate: has_certificate
    )
  end

  # Save a new file into the `storage/` directory.
  private def save_file!(id : Int64, name : String) : Void
    path_file = @form_data.store_file(name, UUID.random.to_s)

    App::Models::File.create!(
      model_id: id,
      model_type: App::Models::Certification.name,
      path: path_file
    )
  end

  # Save a new file to replace, if the user have uploaded one.
  private def update_file(id : Int64, name : String) : Void
    if @form_data.find_file(name)
      found_file = App::Models::File.find_by!(model_id: id, model_type: App::Models::Certification.name)
      File.delete("./uploads/#{found_file.path}")

      path_file = @form_data.store_file(name, UUID.random.to_s)
      found_file.update!(path: path_file)
    end
  end
end
