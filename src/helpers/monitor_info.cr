# Helper that allows to retrieve informations about the resources used by the process.
class App::Helpers::MonitorInfo
  # Returns the CPU usage by the process in percentage.
  def self.cpu_usage : String
    resources[:cpu]
  end

  # Returns the memory used by the process.
  def self.memory_usage : String
    resources[:mem]
  end

  # Retrieves informations about the used resources by the process.
  private def self.resources : NamedTuple(cpu: String, mem: String)
    output = IO::Memory.new

    Process.run("ps", ["-p", Process.pid.to_s, "-o", "%cpu,rss", "--no-headers"], output: output)

    output.rewind

    cpu, mem = output.gets_to_end.strip.split(/\s+/, 2)

    {cpu: cpu, mem: mem}
  end
end
