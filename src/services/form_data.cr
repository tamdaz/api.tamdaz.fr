require "uuid"

@[ADI::Register]
class App::Services::FormData
  # All values in the form data.
  getter data = {} of String => String

  # All uploaded files in the form data.
  getter files = [] of NamedTuple(name: String, filename: String, path: String)

  # Starts parsing data when using multipart/form data.
  def start_parse(req : ATH::Request) : Void
    HTTP::FormData.parse(req.request) do |part|
      io_copy_proc = ->(io : IO) { IO.copy(part.body, io) }
      tmp_filename = "/tmp/athena/#{UUID.random}"

      if part.filename
        File.open(tmp_filename, "w") do |file|
          IO.copy(part.body, file)
        end

        @files << {
          name:     part.name.as(String),
          filename: part.filename.as(String),
          path:     tmp_filename,
        }
      else
        @data[part.name] = String.build(&io_copy_proc)
      end
    end
  end

  # Find an uploaded file from the form data.
  def find_file(name : String) : NamedTuple(name: String, filename: String, path: String)?
    files.find { |file| file["name"] == name }
  end

  # Find an uploaded file from the form data, raises if not found.
  def find_file!(name : String) : NamedTuple(name: String, filename: String, path: String)
    files.find! { |file| file["name"] == name }
  end

  # Store a file into the storage directory.
  def store_file(name : String, custom_filename : String? = nil) : String
    found_file = find_file!(name)

    filename = custom_filename || found_file["filename"]
    filename += '.' + found_file["filename"].split(".").last

    File.copy(found_file[:path], "./uploads/#{filename}")

    filename
  end
end
