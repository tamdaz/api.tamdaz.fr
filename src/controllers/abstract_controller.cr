class App::Controllers::AbstractController < ATH::Controller
  # Sends a JSON response easily.
  protected def send_json(&block : IO -> _) : ATH::StreamedResponse
    header = HTTP::Headers{"content-type" => "application/json; charset=UTF-8"}

    ATH::StreamedResponse.new(headers: header) do |io|
      block.call(io)
    end
  end

  # Sends a JSON response with the status code and the message.
  protected def send_json(status_code : Int32, message : String) : ATH::StreamedResponse
    header = HTTP::Headers{"content-type" => "application/json; charset=UTF-8"}

    ATH::StreamedResponse.new(headers: header, status: status_code) do |io|
      io << {
        status_code: status_code,
        message:     message,
      }
    end
  end
end
