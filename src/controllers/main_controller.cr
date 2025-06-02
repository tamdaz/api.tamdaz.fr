@[ADI::Register]
class App::Controllers::MainController < ATH::Controller
  # API's home page.
  @[ARTA::Get("/")]
  def index : ATH::Response
    render "templates/index.ecr"
  end
end
