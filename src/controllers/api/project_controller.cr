@[ADI::Register]
@[ARTA::Route("/projects")]
class App::Controllers::API::ProjectController < App::Controllers::AbstractController
  include App::Modules::FileManager
  include App::Modules::Validator

  ENTITY_NAME = App::Entities::Project.name

  def initialize(
    @form_data : App::Services::FormData,
    @event_dispatcher : AED::EventDispatcherInterface,
    @project_repository : App::Repositories::ProjectRepository,
    @file_repository : App::Repositories::FileRepository,
  ); end

  # Get all projects.
  @[ARTA::Get("/")]
  def index : Array(App::Entities::Project)
    @project_repository.find_all
  end

  # Get the project by its slug.
  @[ARTA::Get("/{slug}")]
  def show(slug : String) : App::Entities::Project
    @project_repository.find(slug)
  end

  # Create a project.
  @[ARTA::Post("/create")]
  def create(form_data : App::Services::FormData) : ATH::StreamedResponse
    do_validation(project_dto)

    last_project_id = @project_repository.create(project_dto)

    save_file!(last_project_id, "thumbnail", ENTITY_NAME)

    @event_dispatcher.dispatch(App::Events::ClearTemporaryFilesEvent.new)

    send_json(200, "Un nouveau projet a bien été créé.")
  end

  # Update a project by its slug.
  @[ARTA::Put("/{slug}/update")]
  def update(slug : String, form_data : App::Services::FormData) : ATH::StreamedResponse
    do_validation(project_dto)

    project_id = @project_repository.update(slug, project_dto)

    # Store the thumbnail if it was uploaded by the client.
    unless @form_data.data["thumbnail"]?
      update_file(project_id, "thumbnail", ENTITY_NAME)
    end

    @event_dispatcher.dispatch(App::Events::ClearTemporaryFilesEvent.new)

    send_json(200, "Le projet #{slug} a bien été mis à jour.")
  end

  # Delete the project by its slug.
  @[ARTA::Delete("/{slug}/delete")]
  def delete(slug : String) : ATH::StreamedResponse
    @project_repository.delete(slug)

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Le projet #{slug} a bien été supprimé.")
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
end
