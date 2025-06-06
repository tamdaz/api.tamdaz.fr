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
  def show(slug : String) : App::Entities::Project | ATH::StreamedResponse
    @project_repository.find(slug)
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "Le projet #{slug} n'a pas été trouvée.")
  end

  # Create a project.
  @[ARTA::Post("/create")]
  def create(@[TZ::MapFormRequest] dto : App::DTO::ProjectDTO) : ATH::StreamedResponse
    last_project_id = @project_repository.create(dto)

    save_file!(last_project_id, "thumbnail", ENTITY_NAME)

    @event_dispatcher.dispatch(App::Events::ClearUploadedFiles.new)

    send_json(200, "Un nouveau projet a bien été créé.")
  rescue App::Exceptions::DuplicatedIDException
    send_json(422, "Vous ne pouvez pas créer un projet qui a le même slug qu'un autre.")
  end

  # Update a project by its slug.
  @[ARTA::Put("/{slug}/update")]
  def update(slug : String, @[TZ::MapFormRequest] dto : App::DTO::ProjectDTO) : ATH::StreamedResponse
    project_id = @project_repository.update(slug, dto)

    # Store the thumbnail if it was uploaded by the client.
    unless @form_data.data["thumbnail"]?
      update_file(project_id, "thumbnail", ENTITY_NAME)
    end

    @event_dispatcher.dispatch(App::Events::ClearUploadedFiles.new)

    send_json(200, "Le projet #{slug} a bien été mis à jour.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "Le projet #{slug} n'a pas été trouvée.")
  rescue App::Exceptions::DuplicatedIDException
    send_json(422, "Vous ne pouvez pas créer un projet qui a le même slug qu'un autre.")
  end

  # Delete the project by its slug.
  @[ARTA::Delete("/{slug}/delete")]
  def delete(slug : String) : ATH::StreamedResponse
    @project_repository.delete(slug)

    @event_dispatcher.dispatch(App::Events::ClearUploadedFiles.new)

    send_json(200, "Le projet #{slug} a bien été supprimé.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "Le projet #{slug} n'a pas été trouvée.")
  end
end
