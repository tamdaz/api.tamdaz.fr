@[ADI::Register]
class App::Controllers::MainController < ATH::Controller
  # Sends the API's home page.
  @[ARTA::Get("/")]
  def index : ATH::Response
    render "templates/index.ecr"
  end
end
