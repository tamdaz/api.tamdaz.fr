require "uuid"

@[ADI::Register]
@[ARTA::Route("/skills")]
class App::Controllers::API::SkillController < App::Controllers::AbstractController
  include App::Interfaces::FileUploadInterface

  def initialize(
    @form_data : App::Services::FormData,
    @event_dispatcher : AED::EventDispatcherInterface,
  ); end

  # Get all skills.
  @[ARTA::Get("/")]
  def index : Array(App::Models::Skill)
    App::Models::Skill.all.to_a
  end

  # Get the skill by its ID.
  @[ARTA::Get("/{id}")]
  def show(id : String) : App::Models::Skill | ATH::StreamedResponse
    App::Models::Skill.find!(id)
  rescue e : Granite::Querying::NotFound
    send_json(404, "La compétence n°#{id} n'a pas été trouvée.")
  end

  # Create a skill.
  @[ARTA::Post("/create")]
  def create(req : ATH::Request) : ATH::StreamedResponse
    @form_data.start_parse(req)

    validate_skill = AVD.validator.validate(skill_dto)

    unless validate_skill.empty?
      return send_json { |io| validate_skill.to_json io }
    end

    skill = App::Models::Skill.create!(
      name: skill_dto.name,
      description: skill_dto.description,
      has_colors: skill_dto.has_colors
    )

    save_file!(skill.id!, "logo")

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Une nouvelle compétence n°#{skill.id} a bien été créée.")
  rescue e : Granite::RecordNotSaved
    send_json(500, "Une erreur s'est produite lors de l'enregistrement d'une nouvelle compétence.")
  end

  # Update the skill by its ID.
  @[ARTA::Put("/{id}/update")]
  def update(id : Int64, req : ATH::Request) : ATH::StreamedResponse
    @form_data.start_parse(req)

    validate_skill = AVD.validator.validate(skill_dto)

    unless validate_skill.empty?
      return send_json { |io| validate_skill.to_json io }
    end

    skill = App::Models::Skill.find!(id)

    skill.update!(
      name: skill_dto.name,
      description: skill_dto.description,
      has_colors: skill_dto.has_colors
    )

    unless @form_data.data["logo"]?
      update_file(skill.id!, "logo")
    end

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "La compétence n°#{skill.id} a bien été mise à jour.")
  rescue e : Granite::RecordNotSaved
    send_json(500, "Une erreur s'est produite lors de l'enregistrement de la compétence n°#{id}.")
  end

  # Delete the skill by its ID.
  @[ARTA::Delete("/{id}/delete")]
  def delete(id : Int64) : ATH::StreamedResponse
    found_file = App::Models::File.find_by!(model_id: id, model_type: App::Models::Skill.name)
    File.delete("./uploads/#{found_file.path}")

    App::Models::Skill.find!(id).destroy!
    found_file.destroy!

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "La compétence n°#{id} a bien été supprimée.")
  rescue e : Granite::Querying::NotFound
    send_json(404, "La compétence n°#{id} n'a pas été trouvée.")
  end

  # Store informations into the DTO the skill's processing.
  private def skill_dto : App::DTO::SkillDTO
    has_colors = @form_data.data["has_colors"]? == "true"

    App::DTO::SkillDTO.new(
      name: @form_data.data["name"],
      description: @form_data.data["description"],
      has_colors: has_colors
    )
  end

  # Save the file into the `storage/` directory.
  private def save_file!(id : Int64, name : String) : Void
    path_file = @form_data.store_file(name, UUID.random.to_s)

    App::Models::File.create!(
      model_id: id,
      model_type: App::Models::Skill.name,
      path: path_file
    )
  end

  # Save a new file to replace, if the user have uploaded one.
  private def update_file(id : Int64, name : String) : Void
    if @form_data.find_file(name)
      found_file = App::Models::File.find_by!(model_id: id, model_type: App::Models::Skill.name)
      File.delete("./uploads/#{found_file.path}")

      path_file = @form_data.store_file(name, UUID.random.to_s)
      found_file.update!(path: path_file)
    end
  end
end
