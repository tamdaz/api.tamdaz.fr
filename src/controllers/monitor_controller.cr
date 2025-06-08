@[ADI::Register]
class App::Controllers::API::MonitorController < App::Controllers::AbstractController
  # Sends informations about the server's resources
  # (CPU count, %CPU, memory usage and the Crystal's version).
  @[ARTA::Get("/monitor")]
  def show_monitor : Hash(String, String | Int64)
    {
      "cpu_count"           => System.cpu_count,
      "process_cpu_percent" => App::Helpers::MonitorInfo.cpu_usage,
      "process_memory"      => App::Helpers::MonitorInfo.memory_usage,
      "crystal_version"     => Crystal::VERSION,
    }
  end

  # TODO: For later, it's interesting to send informations about backups;
  # where the program sends the %FS used, %FS remaining and all directories (YYYYDDMMHHMMSS).
end
