class Chaos::Instability::CpuUsage
  attr_reader :clock
  private     :clock

  def initialize(clock: Time)
    @clock = clock
  end

  def call(duration_in_seconds:)
    expected_execution_end_time = clock.now + duration_in_seconds

    generate_100_percent_load_on_a_single_cpu_limit(expected_execution_end_time)
  end

  private

  def generate_100_percent_load_on_a_single_cpu_limit(expected_execution_end_time)
    while clock.now < expected_execution_end_time
      true
    end
  end
end
