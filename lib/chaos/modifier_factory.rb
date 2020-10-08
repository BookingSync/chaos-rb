class Chaos::ModifierFactory
  def initialize(random_numbers_generator: Kernel, logger:)
    @random_numbers_generator = random_numbers_generator
    @logger = logger
  end

  def build_module(injection)
    instability_type = injection.instability_type
    instability = injection.instability
    target = injection.target
    method_name = injection.method_name
    probability = injection.probability
    execute_if = injection.execute_if
    random_numbers_generator = @random_numbers_generator
    logger = @logger

    Module.new do
      define_method method_name do |*args, &block|
        if probability >= random_numbers_generator.rand && execute_if.call(self)
          instability.call(injection.instability_arguments)
          logger.info "[Chaos] Triggered :#{instability_type} for :#{method_name} on #{target} with probability: #{probability}"
        end
        super(*args, &block)
      end
    end
  end
end
