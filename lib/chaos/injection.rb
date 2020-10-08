class Chaos::Injection
  ATTRIBUTES = %i(target method_name instability_type instability_arguments probability execute_if).freeze

  attr_accessor *ATTRIBUTES

  attr_reader :instability_factory
  private     :instability_factory

  def initialize(instability_factory: Chaos::InstabilityFactory.new)
    @instability_factory = instability_factory
  end

  def validate!
    ATTRIBUTES.each do |attribute|
      present?(public_send(attribute)) or raise ":#{attribute} is not set!"
    end
  end

  def instability
    instability_factory.build(instability_type)
  end

  def execute_if
    @execute_if || ->(_arg) { true }
  end

  def execute_if=(val)
    raise "is not a lambda-like object" if !val.respond_to?(:call)
    @execute_if = val
  end

  private

  def present?(value)
    !value.nil?
  end
end
