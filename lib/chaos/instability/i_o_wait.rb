class Chaos::Instability::IOWait
  attr_reader :sleep_provider
  private     :sleep_provider

  def initialize(sleep_provider: Kernel)
    @sleep_provider = sleep_provider
  end

  def call(duration_in_seconds:)
    sleep_provider.sleep(duration_in_seconds)
  end
end
