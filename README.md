# Chaos::Rb

Bring [chaos engineering](https://en.wikipedia.org/wiki/Chaos_engineering) to your Ruby apps - destroy production for fun and profit :).

If you want to introduce some instability to your application in a controlled - way and see what's going to happen (verifying alerts, checking what metrics are going to be collected etc.), this is a gem for you.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chaos-rb'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install chaos-rb

## Usage

Chaos RB supports the following types of instabilities:

- CPU Usage - simulate 100% of the CPU core load for a specified amount of time
- Exception - simulate raising exceptions
- IO Wait - simulate some blocking I/O operation for a specified amount of time
- Memory Usage - simulate memory usage of a given amount in megabytes for a specified amount of time

The way to use them is to use `Chaos::Injector` that modified the specific class/method. You also need to provide probability of the instability being executed (a number between 0 and 1 - 0 means never, 1 means always, 0.7 means 70% of the change that the instability will be executed etc.).

You can also provide a lambda or an object responding to `call` method taking one argument which is going to be an object that gets the chaos injection if the logic when given instability should be executed is more complex - that way you can take advantage of the state of the object to decide, e.g. if you only want some users to experience problems.

Here are examples how to use `Chaos::Injector`:


``` rb
injector = Chaos::Injector.build(logger: Rails.logger)

injector.inject do |builder|
  builder.target = ExampleService # required
  builder.method_name = :call # required
  builder.instability_type = :cpu_usage # required
  builder.instability_arguments = { duration_in_seconds: 30.0 } # required
  builder.probability = 0.9 # required
end

injector.inject do |builder|
  builder.target = ExampleService
  builder.method_name = :call
  builder.instability_type = :io_wait
  builder.instability_arguments = { duration_in_seconds: 30.0 }
  builder.probability = 0.5
  builder.execute_if = ->(example_service_instance) { example_service_instance.current_user.admin? } # optional
end

injector.inject do |builder|
  builder.target = ExampleService
  builder.method_name = :call
  builder.instability_type = :memory_usage
  builder.instability_arguments = { duration_in_seconds: 30.0, memory_limit_in_megabytes: 1000 }
  builder.probability = 1
end

injector.inject do |builder|
  builder.target = ExampleService
  builder.method_name = :call
  builder.instability_type = :exception
  builder.instability_arguments = { exceptions: [Faraday::ClientError.new("HTTP connection error"), ActiveRecord::RecordInvalid] }
  builder.probability = 0.1
end
```

If `Chaos::Injector` looks like too much magic to you, you can use instability classes directly:

``` rb
instability_type = :io_wait
instability_arguments = { duration_in_seconds: 30.0 }

Chaos::InstabilityFactory.new.build(instability_type).call(instability_arguments)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/chaos-rb.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
