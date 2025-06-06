# Abstract controller that provides methods to send the JSON
# response easily.
class App::Controllers::AbstractController < ATH::Controller
  include App::Modules::ResponseSender
end
