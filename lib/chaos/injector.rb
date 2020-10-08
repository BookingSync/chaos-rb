class Chaos::Injector
  attr_reader :modifier_factory, :injections
  private     :modifier_factory

  def self.build(logger:, random_numbers_generator: Kernel)
    new(Chaos::ModifierFactory.new(logger: logger, random_numbers_generator: random_numbers_generator))
  end

  def initialize(modifier_factory)
    @modifier_factory = modifier_factory
    @injections = []
  end

  def inject
    injection = Chaos::Injection.new
    yield injection
    injection.validate!
    injections << injection

    injection.target.prepend(build_module(injection))
  end

  private

  def build_module(injection)
    modifier_factory.build_module(injection)
  end
end
