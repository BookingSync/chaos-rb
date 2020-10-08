RSpec.describe Chaos::Injection do
  describe "attributes" do
    subject(:injection) do
      described_class.new.tap do |inj|
        inj.target = target
        inj.method_name = method_name
        inj.instability_type = instability_type
        inj.instability_arguments = instability_arguments
        inj.probability = probability
      end
    end

    let(:target) { "target" }
    let(:method_name) { "method_name" }
    let(:instability_type) { "instability_type" }
    let(:instability_arguments) { "instability_arguments" }
    let(:probability) { "probability" }

    it "implements attr accessors for attributes" do
      expect(injection.target).to eq target
      expect(injection.method_name).to eq method_name
      expect(injection.instability_type).to eq instability_type
      expect(injection.instability_arguments).to eq instability_arguments
      expect(injection.probability).to eq probability
    end
  end

  describe "#validate!" do
    subject(:validate!) do
      described_class.new.tap do |inj|
        inj.target = target
        inj.method_name = method_name
        inj.instability_type = instability_type
        inj.instability_arguments = instability_arguments
        inj.probability = probability
      end.validate!
    end

    let(:target) { "target" }
    let(:method_name) { "method_name" }
    let(:instability_type) { "instability_type" }
    let(:instability_arguments) { "instability_arguments" }
    let(:probability) { "probability" }

    context "when all attributes are present" do
      it { is_expected_block.not_to raise_error }
    end

    context "when :target is not present" do
      let(:target) { nil }

      it { is_expected_block.to raise_error ":target is not set!" }
    end

    context "when :method_name is not present" do
      let(:method_name) { nil }

      it { is_expected_block.to raise_error ":method_name is not set!" }
    end

    context "when :instability_type is not present" do
      let(:instability_type) { nil }

      it { is_expected_block.to raise_error ":instability_type is not set!" }
    end

    context "when :instability_arguments is not present" do
      let(:instability_arguments) { nil }

      it { is_expected_block.to raise_error ":instability_arguments is not set!" }
    end

    context "when :probability is not present" do
      let(:probability) { nil }

      it { is_expected_block.to raise_error ":probability is not set!" }
    end
  end

  describe "#instability" do
    subject(:injection) do
      described_class.new.tap do |inj|
        inj.instability_type = :exception
      end.instability
    end

    it { is_expected.to be_instance_of(Chaos::Instability::Exception) }
  end

  describe "execute_if" do
    subject(:execute_if) { injection.execute_if }

    context "when it's set" do
      let(:injection) do
        described_class.new.tap do |inj|
          inj.execute_if = execute_if_lambda
        end
      end
      let(:execute_if_lambda) { ->(_arg) { false } }

      it "returns whatever was set" do
        expect(execute_if).to eq execute_if_lambda
      end

      context "when passing something that is not a lambda-like object" do
        let(:execute_if_lambda) { double }

        it { is_expected_block.to raise_error "is not a lambda-like object" }
      end
    end

    context "when it's not set" do
      let(:injection) { described_class.new }

      it "returns a lambda taking one argument and always returning true" do
        expect(execute_if.call(double)).to eq true
      end
    end
  end
end
