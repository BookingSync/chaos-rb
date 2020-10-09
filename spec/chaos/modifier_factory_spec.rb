RSpec.describe Chaos::ModifierFactory do
  describe "#build_module" do
    subject(:prepend_and_call) do
      target.prepend(build_module)
      target.new(sentinel).public_send(method_name, Object.new)
    end
    subject(:build_module) { modifier_factory.build_module(injection) }

    let(:modifier_factory) do
      described_class.new(logger: logger, random_numbers_generator: random_numbers_generator)
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
    let(:random_numbers_generator) do
      Class.new do
        def rand
          0.7
        end
      end.new
    end
    let(:sentinel) do
      Class.new do
        def initialize
          @called = false
        end

        def call(_useless_argument)
          @called = true
        end

        def called?
          !!@called
        end
      end.new
    end
    let(:injection) do
      Chaos::Injection.new.tap do |inj|
        inj.target = target
        inj.method_name = method_name
        inj.instability_type = instability_type
        inj.instability_arguments = instability_arguments
        inj.probability = probability
      end
    end
    let(:method_name) { :call }
    let(:instability_type) { :io_wait }
    let(:instability_arguments) do
      {
        duration_in_seconds: 1
      }
    end

    context "when probability is high enough to be satisfied" do
      let(:target) do
        Class.new do
          attr_reader :sentinel

          def initialize(sentinel)
            @sentinel = sentinel
          end

          def call(placeholder)
            sentinel.call(placeholder)
          end
        end
      end
      let(:probability) { 0.71 }

      context "when extra condition is provided" do
        context "when the extra condition is not satisfied" do
          before do
            injection.execute_if = ->(_) { false }
          end

          it "generates a module that when prepended, it does not do anything extra, just calls original method" do
            expect_any_instance_of(Chaos::Instability::IOWait).not_to receive(:call)

            expect {
              prepend_and_call
            }.to change { sentinel.called? }.from(false).to(true)
            .and avoid_changing { logger.log }
          end
        end

        context "when the extra condition is satisfied" do
          let(:execute_if) do
            Class.new do
              attr_reader :arg

              def initialize
                @arg = nil
              end

              def call(val)
                @arg = val
                true
              end
            end.new
          end

          before do
            injection.execute_if = execute_if
          end

          it "generates a module that when prepended, it calls given instability, logs it and calls original method" do
            expect_any_instance_of(Chaos::Instability::IOWait).to receive(:call).with(instability_arguments).and_call_original

            expect {
              prepend_and_call
            }.to change { sentinel.called? }.from(false).to(true)
            .and change { logger.log }.from("").to("[Chaos] Triggered :io_wait for :call on #{target} with probability: 0.71")
          end

          it "calls :execute_if with self value inside the method that is being modified" do
            expect {
              prepend_and_call
            }.to change { execute_if.arg }.from(nil).to(instance_of(target))
          end
        end
      end

      context "when extra condition is not provided" do
        it "generates a module that when prepended, it calls given instability, logs it and calls original method" do
          expect_any_instance_of(Chaos::Instability::IOWait).to receive(:call).with(instability_arguments).and_call_original

          expect {
            prepend_and_call
          }.to change { sentinel.called? }.from(false).to(true)
          .and change { logger.log }.from("").to("[Chaos] Triggered :io_wait for :call on #{target} with probability: 0.71")
        end
      end
    end

    context "when probability is exactly enough to be satisfied" do
      let(:target) do
        Class.new do
          attr_reader :sentinel

          def initialize(sentinel)
            @sentinel = sentinel
          end

          def call(placeholder)
            sentinel.call(placeholder)
          end
        end
      end
      let(:probability) { 0.70 }

      context "when extra condition is provided" do
        context "when the extra condition is not satisfied" do
          before do
            injection.execute_if = ->(_) { false }
          end

          it "generates a module that when prepended, it does not do anything extra, just calls original method" do
            expect_any_instance_of(Chaos::Instability::IOWait).not_to receive(:call)

            expect {
              prepend_and_call
            }.to change { sentinel.called? }.from(false).to(true)
            .and avoid_changing { logger.log }
          end
        end

        context "when the extra condition is satisfied" do
          let(:execute_if) do
            Class.new do
              attr_reader :arg

              def initialize
                @arg = nil
              end

              def call(val)
                @arg = val
                true
              end
            end.new
          end

          before do
            injection.execute_if = execute_if
          end

          it "generates a module that when prepended, it calls given instability, logs it and calls original method" do
            expect_any_instance_of(Chaos::Instability::IOWait).to receive(:call).with(instability_arguments).and_call_original

            expect {
              prepend_and_call
            }.to change { sentinel.called? }.from(false).to(true)
            .and change { logger.log }.from("").to("[Chaos] Triggered :io_wait for :call on #{target} with probability: 0.7")
          end

          it "calls :execute_if with self value inside the method that is being modified" do
            expect {
              prepend_and_call
            }.to change { execute_if.arg }.from(nil).to(instance_of(target))
          end
        end
      end

      context "when extra condition is not provided" do
        it "generates a module that when prepended, it calls given instability, logs it and calls original method" do
          expect_any_instance_of(Chaos::Instability::IOWait).to receive(:call).with(instability_arguments).and_call_original

          expect {
            prepend_and_call
          }.to change { sentinel.called? }.from(false).to(true)
          .and change { logger.log }.from("").to("[Chaos] Triggered :io_wait for :call on #{target} with probability: 0.7")
        end
      end
    end

    context "when probability is not satisfied" do
      let(:target) do
        Class.new do
          attr_reader :sentinel

          def initialize(sentinel)
            @sentinel = sentinel
          end

          def call(placeholder)
            sentinel.call(placeholder)
          end
        end
      end
      let(:probability) { 0.69 }

      it "generates a module that when prepended, it does not do anything extra, just calls original method" do
        expect_any_instance_of(Chaos::Instability::IOWait).not_to receive(:call)

        expect {
          prepend_and_call
        }.to change { sentinel.called? }.from(false).to(true)
        .and avoid_changing { logger.log }
      end
    end
  end
end
