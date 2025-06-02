@[ADI::Register]
class App::Controllers::API::MonitorController < App::Controllers::AbstractController
  @[ARTA::Get("/monitor")]
  def show_monitor : Hash(String, String | Int64)
    {
      "cpu_count"           => System.cpu_count,
      "process_cpu_percent" => App::Helpers::MonitorInfo.cpu_usage,
      "process_memory"      => App::Helpers::MonitorInfo.memory_usage,
      "crystal_version"     => Crystal::VERSION,
    }
  end
end
