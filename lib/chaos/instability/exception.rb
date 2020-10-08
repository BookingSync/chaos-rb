class Chaos::Instability::Exception
  def call(exceptions:)
    raise exceptions.sample
  end
end
