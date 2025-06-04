require "uuid"

@[ADI::Register]
@[ARTA::Route("/skills")]
class App::Controllers::API::SkillController < App::Controllers::AbstractController
  include App::Modules::FileManager
  include App::Modules::Validator

  ENTITY_NAME = App::Entities::Skill.name

  def initialize(
    @form_data : App::Services::FormData,
    @event_dispatcher : AED::EventDispatcherInterface,
    @file_repository : App::Repositories::FileRepository,
    @skill_repository : App::Repositories::SkillRepository,
  ); end

  # Get all skills.
  @[ARTA::Get("/")]
  def index : Array(App::Entities::Skill)
    @skill_repository.find_all
  end

  # Get the skill by its ID.
  @[ARTA::Get("/{id}")]
  def show(id : Int64) : App::Entities::Skill
    @skill_repository.find(id)
  end

  # Create a skill.
  @[ARTA::Post("/create")]
  def create(form_data : App::Services::FormData) : ATH::StreamedResponse
    do_validation(skill_dto)

    last_skill_id = @skill_repository.create(skill_dto)

    save_file!(last_skill_id, "logo", ENTITY_NAME)

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Une nouvelle compétence a bien été créée.")
  end

  # Update the skill by its ID.
  @[ARTA::Put("/{id}/update")]
  def update(id : Int64, form_data : App::Services::FormData) : ATH::StreamedResponse
    do_validation(skill_dto)

    @skill_repository.update(id, skill_dto)

    unless @form_data.data["logo"]?
      update_file(id, "logo", ENTITY_NAME)
    end

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "La compétence n°#{id} a bien été mise à jour.")
  end

  # Delete the skill by its ID.
  @[ARTA::Delete("/{id}/delete")]
  def delete(id : Int64) : ATH::StreamedResponse
    @skill_repository.delete(id)

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "La compétence n°#{id} a bien été supprimée.")
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
end
