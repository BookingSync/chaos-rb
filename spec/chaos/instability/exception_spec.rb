RSpec.describe Chaos::Instability::Exception do
  describe "#call" do
    subject(:call) { described_class.new.call(exceptions: exceptions_storage) }

    let(:exceptions_storage) do
      Class.new do
        def initialize(exception)
          @exception = exception
        end

        def sample
          @exception
        end
      end.new(exception)
    end
    let(:exception) { StandardError.new("test error") }

    it { is_expected_block.to raise_error StandardError, "test error" }
  end
end
