class Chaos::InstabilityFactory
  REGISTRY = {
    cpu_usage: Chaos::Instability::CpuUsage.new,
    io_wait: Chaos::Instability::IOWait.new,
    memory_usage: Chaos::Instability::MemoryUsage.new,
    exception: Chaos::Instability::Exception.new
  }

  def build(instability)
    REGISTRY.fetch(instability.to_sym)
  end
end
