RSpec.describe Chaos::Instability::IOWait do
  describe "#call" do
    subject(:call) { instability.call(duration_in_seconds: duration_in_seconds) }

    let(:instability) { described_class.new(sleep_provider: sleep_provider) }
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
    let(:duration_in_seconds) { 9 }

    it "sleeps for a given amount of time" do
      expect {
        call
      }.to change { sleep_provider.value }.from(0).to(duration_in_seconds)
    end
  end
end
