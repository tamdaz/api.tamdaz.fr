@[ADI::Register]
struct App::Events::StaticFilesListener
  private PUBLIC_DIR = Path.new("public").expand

  @[AEDA::AsEventListener(priority: 256)]
  def on_request(event : ATH::Events::Request) : Nil
    return unless event.request.method.in? "GET", "HEAD"

    original_path = event.request.path
    request_path = URI.decode original_path

    if request_path.includes? '\0'
      raise ATH::Exception::BadRequest.new "File path cannot contain NUL bytes."
    end

    request_path = Path.posix request_path
    expanded_path = request_path.expand "/"

    file_path = PUBLIC_DIR.join expanded_path.to_kind Path::Kind.native

    is_dir = Dir.exists? file_path
    is_dir_path = original_path.ends_with? '/'

    event.response = if request_path != expanded_path || is_dir && !is_dir_path
                       redirect_path = expanded_path
                       if is_dir && !is_dir_path
                         redirect_path = expanded_path.join ""
                       end

                       ATH::RedirectResponse.new redirect_path
                     elsif File.file? file_path
                       ATH::BinaryFileResponse.new file_path
                     else
                       return
                     end
  end
end
