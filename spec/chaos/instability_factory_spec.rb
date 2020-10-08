RSpec.describe Chaos::InstabilityFactory do
  describe "#build" do
    subject(:build) { described_class.new.build(instability) }

    context "for :cpu_usage" do
      let(:instability) { :cpu_usage }

      it { is_expected.to be_instance_of(Chaos::Instability::CpuUsage) }
    end

    context "for :io_wait" do
      let(:instability) { :io_wait }

      it { is_expected.to be_instance_of(Chaos::Instability::IOWait) }
    end

    context "for :memory_usage" do
      let(:instability) { :memory_usage }

      it { is_expected.to be_instance_of(Chaos::Instability::MemoryUsage) }
    end

    context "for :exception" do
      let(:instability) { :exception }

      it { is_expected.to be_instance_of(Chaos::Instability::Exception) }
    end
  end
end
