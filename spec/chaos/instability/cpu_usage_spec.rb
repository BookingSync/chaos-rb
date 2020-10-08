RSpec.describe Chaos::Instability::CpuUsage do
  describe "#call" do
    subject(:call) { instability.call(duration_in_seconds: duration_in_seconds) }

    let(:instability) { described_class.new }
    let(:duration_in_seconds) { 2.1 }

    it "generates 100% CPU load for a given amount of times" do
      time_before = Time.now
      call
      time_after = Time.now

      expect(time_after - time_before).to be_between(2.0, 3.0)
    end
  end
end
