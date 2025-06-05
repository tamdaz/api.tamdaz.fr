@[ADI::Register(tags: [{name: ATHR::Interface::TAG, priority: 110}])]
struct App::Resolvers::MapFormRequest
  include App::Modules::ResponseSender
  include App::Modules::Validator
  include App::Modules::DTOMaker
  include ATHR::Interface

  configuration ::TZ::MapFormRequest

  def initialize(@form_data : App::Services::FormData); end

  def resolve(request : ATH::Request, parameter : ATH::Controller::ParameterMetadata) : App::Interfaces::DTOInterface?
    @form_data.start_parse(request)

    return unless parameter.annotation_configurations.has? ::TZ::MapFormRequest

    puts "Parameter type => #{parameter.type}"

    return blog_dto if parameter.type == App::DTO::BlogDTO
    return certification_dto if parameter.type == App::DTO::CertificationDTO
    return project_dto if parameter.type == App::DTO::BlogDTO
    return report_dto if parameter.type == App::DTO::ReportDTO
  end
end
