RSpec.describe Chaos::Injector do
  describe ".build" do
    subject(:build) { described_class.build(logger: logger) }

    let(:logger) { double(:logger) }

    it { is_expected.to be_instance_of(described_class) }
  end

  describe "#inject" do
    subject(:call) { target.new(sentinel).call }
    subject(:inject) do
      injector.inject do |builder|
        builder.target = target
        builder.method_name = method_name
        builder.instability_type = instability_type
        builder.instability_arguments = instability_arguments
        builder.probability = probability
      end
    end

    let(:injector) { described_class.build(logger: logger, random_numbers_generator: random_numbers_generator) }
    let(:method_name) { :call }
    let(:instability_type) { :io_wait }
    let(:instability_arguments) do
      {
        duration_in_seconds: 1
      }
    end
    let(:random_numbers_generator) { double(:random_numbers_generator, rand: 0.7) }
    let(:target) do
      Class.new do
        attr_reader :sentinel

        def initialize(sentinel)
          @sentinel = sentinel
        end

        def call
          sentinel.call
        end
      end
    end
    let(:logger) do
      Class.new do
        attr_reader :log

        def initialize
          @log = ""
        end

        def info(value)
          @log += value
        end
      end.new
    end
    let(:sentinel) do
      Class.new do
        def initialize
          @called = false
        end

        def call
          @called = true
        end

        def called?
          !!@called
        end
      end.new
    end

    context "when all attributes for injection setup are provided" do
      let(:probability) { 0.71 }

      it "creates an injection and modifies the target class" do
        expect_any_instance_of(Chaos::Instability::IOWait).to receive(:call).with(instability_arguments).and_call_original

        expect {
          inject
          call
        }.to change { sentinel.called? }.from(false).to(true)
        .and change { logger.log }.from("").to("[Chaos] Triggered :io_wait for :call on #{target} with probability: 0.71")
      end

      it "stores the injection" do
        expect {
          inject
        }.to change { injector.injections.size }.from(0).to(1)
        expect(injector.injections.first).to be_instance_of(Chaos::Injection)
      end
    end

    context "when not all attributes for injection setup are provided" do
      let(:probability) { nil }

      it { is_expected_block.to raise_error ":probability is not set!" }
    end
  end
end
