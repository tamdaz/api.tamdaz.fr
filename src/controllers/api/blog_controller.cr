require "uuid"

@[ADI::Register]
@[ARTA::Route("/blogs")]
class App::Controllers::API::BlogController < App::Controllers::AbstractController
  include App::Modules::FileManager
  include App::Modules::Validator

  ENTITY_NAME = App::Entities::Blog.name

  def initialize(
    @form_data : App::Services::FormData,
    @event_dispatcher : AED::EventDispatcherInterface,
    @blog_repository : App::Repositories::BlogRepository,
    @category_repository : App::Repositories::CategoryRepository,
    @file_repository : App::Repositories::FileRepository,
  ); end

  # Retrieves all blogs.
  @[ARTA::Get("/")]
  def index : Array(App::Entities::Blog)
    @blog_repository.find_all
  end

  # Retrieves the blog by its slug.
  @[ARTA::Get("/{slug}")]
  def show(slug : String) : App::Entities::Blog | ATH::StreamedResponse
    @blog_repository.find(slug)
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "Le blog #{slug} n'a pas été trouvée.")
  end

  # Createss a blog.
  @[ARTA::Post("/create")]
  def create(@[TZ::MapFormRequest] dto : App::DTO::BlogDTO) : ATH::StreamedResponse
    if @category_repository.find_all.size != 0
      last_blog_id = @blog_repository.create(dto)
      save_file!(last_blog_id, "thumbnail", ENTITY_NAME)
      @event_dispatcher.dispatch(App::Events::ClearUploadedFiles.new)
      send_json(200, "Un nouveau blog a bien été créé.")
    else
      send_json(422, "Pour créer un blog, il faut créer une catégorie.")
    end
  rescue App::Exceptions::DuplicatedIDException
    send_json(422, "Impossible de créer un blog qui a le même slug qu'un autre.")
  end

  # Updatess the blog by its slug.
  @[ARTA::Put("/{slug}/update")]
  def update(slug : String, @[TZ::MapFormRequest] dto : App::DTO::BlogDTO) : ATH::StreamedResponse
    blog_id = @blog_repository.update(dto, slug)

    unless @form_data.data["thumbnail"]?
      update_file(blog_id, "thumbnail", ENTITY_NAME)
    end

    @event_dispatcher.dispatch(App::Events::ClearUploadedFiles.new)

    send_json(200, "Le blog #{slug} a bien été mis à jour.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "Le blog #{slug} n'a pas été trouvée.")
  rescue App::Exceptions::DuplicatedIDException
    send_json(422, "Impossible de modifier un blog qui a le même slug qu'un autre.")
  end

  # Deletess the blog by its slug.
  @[ARTA::Delete("/{slug}/delete")]
  def delete(slug : String) : ATH::StreamedResponse
    @blog_repository.delete(slug)

    @event_dispatcher.dispatch(App::Events::ClearUploadedFiles.new)

    send_json(200, "Le blog #{slug} a bien été supprimé.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "Le blog #{slug} n'a pas été trouvée.")
  end
end
