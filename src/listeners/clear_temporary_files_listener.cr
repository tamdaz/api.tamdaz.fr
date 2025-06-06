# Listener that consists of deleting files from the tmpfs.
# This will be trigerred when creating, updating or deleting
# data from the resource controller.
@[ADI::Register]
class App::Listeners::ClearTemporaryFilesListener
  def initialize(@form_data : App::Services::FormData); end

  @[AEDA::AsEventListener]
  def on_delete_tmp_files(event : App::Events::ClearUploadedFiles) : Nil
    @form_data.files.each do |file|
      File.delete?(file[:path])
    end
  end
end
