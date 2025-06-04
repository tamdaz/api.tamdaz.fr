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
    @file_repository : App::Repositories::FileRepository,
  ); end

  # Get all blogs.
  @[ARTA::Get("/")]
  def index : Array(App::Entities::Blog)
    @blog_repository.find_all
  end

  # Get the blog by its slug.
  @[ARTA::Get("/{slug}")]
  def show(slug : String) : App::Entities::Blog
    @blog_repository.find(slug)
  end

  # Create a blog.
  @[ARTA::Post("/create")]
  def create(form_data : App::Services::FormData) : ATH::StreamedResponse
    do_validation(blog_dto)

    last_blog_id = @blog_repository.create(blog_dto)

    save_file!(last_blog_id, "thumbnail", ENTITY_NAME)

    @event_dispatcher.dispatch(App::Events::ClearTemporaryFilesEvent.new)

    send_json(200, "Un nouveau blog a bien été créé.")
  end

  # Update the blog by its slug.
  @[ARTA::Put("/{slug}/update")]
  def update(slug : String, form_data : App::Services::FormData) : ATH::StreamedResponse
    do_validation(blog_dto)

    blog_id = @blog_repository.update(blog_dto, slug)

    unless @form_data.data["thumbnail"]?
      update_file(blog_id, "thumbnail", ENTITY_NAME)
    end

    @event_dispatcher.dispatch(App::Events::ClearTemporaryFilesEvent.new)

    send_json(200, "Le blog #{slug} a bien été mis à jour.")
  end

  # Delete the blog by its slug.
  @[ARTA::Delete("/{slug}/delete")]
  def delete(slug : String) : ATH::StreamedResponse
    @blog_repository.delete(slug)

    @event_dispatcher.dispatch(App::Events::ClearTemporaryFilesEvent.new)

    send_json(200, "Le blog #{slug} a bien été supprimé.")
  end

  # Store informations into the DTO for the blog's processing.
  private def blog_dto : App::DTO::BlogDTO
    category_id = @form_data.data["category_id"]
    is_published = @form_data.data["is_published"]? == "true"

    App::DTO::BlogDTO.new(
      title: @form_data.data["title"],
      description: @form_data.data["description"],
      content: @form_data.data["content"],
      is_published: is_published,
      category_id: category_id.empty? ? 0i64 : category_id.to_i64
    )
  end
end
