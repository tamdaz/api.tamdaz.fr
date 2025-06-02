require "uuid"

@[ADI::Register]
@[ARTA::Route("/blogs")]
class App::Controllers::API::BlogController < App::Controllers::AbstractController
  include App::Interfaces::FileUploadInterface

  def initialize(
    @form_data : App::Services::FormData,
    @event_dispatcher : AED::EventDispatcherInterface,
  ); end

  # Get all blogs.
  @[ARTA::Get("/")]
  def index : Array(App::Models::Blog)
    App::Models::Blog.all.to_a
  end

  # Get the blog by its slug.
  @[ARTA::Get("/{slug}")]
  def show(slug : String) : App::Models::Blog | ATH::StreamedResponse
    App::Models::Blog.find_by!(slug: slug)
  rescue e : Granite::Querying::NotFound
    send_json(404, "Le blog #{slug} n'a pas été trouvée.")
  end

  # Create a blog.
  @[ARTA::Post("/create")]
  def create(req : ATH::Request) : ATH::StreamedResponse | String
    @form_data.start_parse(req)

    validate_blog = AVD.validator.validate(blog_dto)

    unless validate_blog.empty?
      return send_json { |io| validate_blog.to_json io }
    end

    blog = App::Models::Blog.create!(
      title: blog_dto.title,
      description: blog_dto.description,
      content: blog_dto.content,
      is_published: blog_dto.is_published,
      category_id: blog_dto.category_id
    )

    save_file!(blog.id!, "thumbnail")

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Un nouveau blog a bien été créé.")
  rescue e : Granite::RecordNotSaved
    send_json(500, "Une erreur s'est produite lors de l'enregistrement du nouveau blog.")
  end

  # Update the blog by its slug.
  @[ARTA::Put("/{slug}/update")]
  def update(slug : String, req : ATH::Request) : ATH::StreamedResponse | String
    @form_data.start_parse(req)

    validate_blog = AVD.validator.validate(blog_dto)

    unless validate_blog.empty?
      return send_json { |io| validate_blog.to_json io }
    end

    blog = App::Models::Blog.find_by!(slug: slug)
    blog.update!(
      title: @form_data.data["title"],
      description: @form_data.data["description"],
      content: @form_data.data["content"],
      is_published: @form_data.data["is_published"],
      category_id: @form_data.data["category_id"]
    )

    unless @form_data.data["thumbnail"]?
      update_file(blog.id!, "thumbnail")
    end

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Le blog #{slug} a bien été mis à jour.")
  rescue e : Granite::RecordNotSaved
    send_json(500, "Une erreur s'est produite lors de la modification du blog #{slug}.")
  end

  # Delete the blog by its slug.
  @[ARTA::Delete("/{slug}/delete")]
  def delete(slug : String) : ATH::StreamedResponse
    found_blog = App::Models::Blog.find_by!(slug: slug)

    found_file = App::Models::File.find_by!(model_id: found_blog.id, model_type: App::Models::Blog.name)
    File.delete("./uploads/#{found_file.path}")

    found_blog.destroy!
    found_file.destroy!

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Le blog #{slug} a bien été supprimé.")
  # rescue e : Granite::Querying::NotFound
  #   send_json(404, "Le blog #{slug} n'a pas été trouvée.")
  rescue e : Exception
    send_json(500, e.message.not_nil!)
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

  # Save the file into the `storage/` directory.
  private def save_file!(id : Int64, name : String) : Void
    path_file = @form_data.store_file(name, UUID.random.to_s)

    App::Models::File.create!(
      model_id: id,
      model_type: App::Models::Blog.name,
      path: path_file
    )
  end

  # Save a new file to replace, if the user have uploaded one.
  private def update_file(id : Int64, name : String) : Void
    if @form_data.find_file(name)
      found_file = App::Models::File.find_by!(model_id: id, model_type: App::Models::Blog.name)
      File.delete("./uploads/#{found_file.path}")

      path_file = @form_data.store_file(name, UUID.random.to_s)
      found_file.update!(path: path_file)
    end
  end
end
