@[ADI::Register]
@[ARTA::Route("/projects")]
class App::Controllers::API::ProjectController < App::Controllers::AbstractController
  include App::Interfaces::FileUploadInterface

  def initialize(
    @form_data : App::Services::FormData,
    @event_dispatcher : AED::EventDispatcherInterface,
  ); end

  # Get all projects.
  @[ARTA::Get("/")]
  def index : Array(App::Models::Project)
    App::Models::Project.all.to_a
  end

  # Get the project by its slug.
  @[ARTA::Get("/{slug}")]
  def show(slug : String) : App::Models::Project | ATH::StreamedResponse
    App::Models::Project.find_by!(slug: slug)
  rescue e : Granite::Querying::NotFound
    send_json(404, "Le projet #{slug} n'a pas été trouvée")
  end

  # Create a project.
  @[ARTA::Post("/create")]
  def create(req : ATH::Request) : ATH::StreamedResponse
    @form_data.start_parse(req)

    validate_project = AVD.validator.validate(project_dto)

    unless validate_project.empty?
      return send_json { |io| validate_project.to_json io }
    end

    project = App::Models::Project.create!(
      title: project_dto.title,
      description: project_dto.description,
      content: project_dto.content,
      category_id: project_dto.category_id,
      realized_at: project_dto.realized_at,
      published_at: project_dto.published_at
    )

    save_file!(project.id!, "thumbnail")

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Un nouveau projet a bien été créé.")
  rescue e : Granite::RecordNotSaved
    send_json(500, "Une erreur s'est produite lors de l'enregistrement d'un nouveau projet.")
  end

  # Update a project by its slug.
  @[ARTA::Put("/{slug}/update")]
  def update(slug : String, req : ATH::Request) : ATH::StreamedResponse
    @form_data.start_parse(req)

    validate_project = AVD.validator.validate(project_dto)

    unless validate_project.empty?
      return send_json { |io| validate_project.to_json io }
    end

    found_project = App::Models::Project.find_by!(slug: slug)

    found_project.update!(
      title: project_dto.title,
      description: project_dto.description,
      content: project_dto.content,
      category_id: project_dto.category_id,
      realized_at: project_dto.realized_at,
      published_at: project_dto.published_at
    )

    # Store the thumbnail if it was uploaded by the client.
    unless @form_data.data["thumbnail"]?
      update_file(found_project.id!, "thumbnail")
    end

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Le projet #{slug} a bien été mis à jour.")
  rescue e : Granite::RecordNotSaved
    send_json(404, "Le projet #{slug} n'a pas été trouvée")
  end

  # Delete the project by its slug.
  @[ARTA::Delete("/{slug}/delete")]
  def delete(slug : String) : ATH::StreamedResponse
    found_project = App::Models::Project.find_by!(slug: slug)

    found_file = App::Models::File.find_by!(
      model_id: found_project.id,
      model_type: App::Models::Project.name
    )

    File.delete("./uploads/#{found_file.path}")

    found_project.destroy!
    found_file.destroy!

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Le projet #{slug} a bien été supprimé.")
  rescue e : Granite::Querying::NotFound
    send_json(500, "Une erreur s'est produite lors de la suppression du projet #{slug}.")
  end

  # Store informations into the DTO for the project's processing.
  private def project_dto : App::DTO::ProjectDTO
    category_id = @form_data.data["category_id"]

    published_at = if !@form_data.data["published_at"].empty?
                     Time.parse_local(@form_data.data["published_at"], "%F")
                   else
                     nil
                   end

    App::DTO::ProjectDTO.new(
      title: @form_data.data["title"],
      description: @form_data.data["description"],
      content: @form_data.data["content"],
      category_id: category_id.empty? ? 0i64 : category_id.to_i64,
      realized_at: Time.parse_local(@form_data.data["realized_at"], "%F"),
      published_at: published_at
    )
  end

  # Save a file into the `storage/` directory.
  private def save_file!(id : Int64, name : String) : Void
    path_file = @form_data.store_file(name, UUID.random.to_s)

    App::Models::File.create!(
      model_id: id,
      model_type: App::Models::Project.name,
      path: path_file
    )
  end

  # Save a new file to replace, if the user have uploaded one.
  private def update_file(id : Int64, name : String) : Void
    if @form_data.find_file(name)
      found_file = App::Models::File.find_by!(model_id: id, model_type: App::Models::Project.name)
      File.delete("./uploads/#{found_file.path}")

      path_file = @form_data.store_file(name, UUID.random.to_s)
      found_file.update!(path: path_file)
    end
  end
end
