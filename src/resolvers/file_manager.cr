@[ADI::Register(tags: [{name: ATHR::Interface::TAG, priority: 10}])]
struct App::Resolvers::FileManager
  include ATHR::Interface

  alias ATHC = ATH::Controller

  def initialize(@form_data : App::Services::FormData); end

  def resolve(request : ATH::Request, parameter : ATHC::ParameterMetadata) : App::Services::FormData?
    if parameter.type != App::Services::FormData
      return nil
    end

    @form_data.start_parse(request)
  end
end
