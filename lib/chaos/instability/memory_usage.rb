class Chaos::Instability::MemoryUsage
  attr_reader :sleep_provider, :accum, :chunk_size_in_bytes, :single_byte_character, :clock
  private     :sleep_provider, :accum, :chunk_size_in_bytes, :single_byte_character, :clock

  MEGABYTES_IN_BYTES = 1048576
  SINGLE_BYE_CHARACTER = "a".freeze
  private_constant :MEGABYTES_IN_BYTES, :SINGLE_BYE_CHARACTER

  def initialize(sleep_provider: Kernel, accum: [], chunk_size_in_bytes: MEGABYTES_IN_BYTES,
    single_byte_character: SINGLE_BYE_CHARACTER, clock: Time)
    @sleep_provider = sleep_provider
    @accum = accum
    @chunk_size_in_bytes = chunk_size_in_bytes
    @single_byte_character = single_byte_character
    @clock = clock
  end

  def call(duration_in_seconds:, memory_limit_in_megabytes:)
    start_time = clock.now
    memory_limit_in_megabytes.times.with_object(accum) do |_index, memory_leaking_accum|
      memory_leaking_accum << generate_chunk
    end
    current_time = clock.now
    time_already_spent = current_time - start_time
    time_left = [duration_in_seconds - time_already_spent , 0].max

    sleep_provider.sleep(time_left)
  end

  private

  def generate_chunk
    single_byte_character * chunk_size_in_bytes
  end
end
