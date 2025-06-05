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
  def show(id : Int64) : App::Entities::Skill | ATH::StreamedResponse
    @skill_repository.find(id)
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "La compétence n°#{id} n'a pas été trouvée.")
  end

  # Create a skill.
  @[ARTA::Post("/create")]
  def create(@[TZ::MapFormRequest] dto : App::DTO::SkillDTO) : ATH::StreamedResponse
    last_skill_id = @skill_repository.create(dto)

    save_file!(last_skill_id, "logo", ENTITY_NAME)

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "Une nouvelle compétence a bien été créée.")
  end

  # Update the skill by its ID.
  @[ARTA::Put("/{id}/update")]
  def update(id : Int64, @[TZ::MapFormRequest] dto : App::DTO::SkillDTO) : ATH::StreamedResponse
    @skill_repository.update(id, dto)

    unless @form_data.data["logo"]?
      update_file(id, "logo", ENTITY_NAME)
    end

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "La compétence n°#{id} a bien été mise à jour.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "La compétence n°#{id} n'a pas été trouvée.")
  end

  # Delete the skill by its ID.
  @[ARTA::Delete("/{id}/delete")]
  def delete(id : Int64) : ATH::StreamedResponse
    @skill_repository.delete(id)

    @event_dispatcher.dispatch(
      App::Events::ClearTemporaryFilesEvent.new
    )

    send_json(200, "La compétence n°#{id} a bien été supprimée.")
  rescue App::Exceptions::DataNotFoundException
    send_json(404, "La compétence n°#{id} n'a pas été trouvée.")
  end
end
