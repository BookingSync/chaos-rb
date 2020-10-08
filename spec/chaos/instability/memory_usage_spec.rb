RSpec.describe Chaos::Instability::MemoryUsage do
  describe "#call" do
    subject(:call) do
      instability.call(
        duration_in_seconds: duration_in_seconds,
        memory_limit_in_megabytes: memory_limit_in_megabytes
      )
    end

    let(:instability) do
      described_class.new(sleep_provider: sleep_provider, accum: accum, chunk_size_in_bytes: 11, clock: clock)
    end
    let(:sleep_provider) do
      Class.new do
        attr_reader :value

        def initialize
          @value = 0
        end

        def sleep(time)
          @value = time
        end
      end.new
    end
    let(:accum) do
      []
    end
    let(:clock) do
      Class.new do
        attr_reader :called

        def initialize
          @called = 0
        end

        def now
          if called == 0
            @called += 1
            20
          else
            25
          end
        end
      end.new
    end

    let(:duration_in_seconds) { 10 }
    let(:memory_limit_in_megabytes) { 4 }

    it "generates some that holds memory for a specific amount of time" do
      expect {
        call
      }.to change { accum }.from([]).to(Array.new(4) { "a" * 11 })
      .and change { sleep_provider.value }.from(0).to(10 - 5)
    end
  end
end
