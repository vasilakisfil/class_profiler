# ClassProfiler
Simple performance analyzer for Ruby classes. Just include it in the bottom of
your class and let it do its work.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'class_profiler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install class_profiler

## Usage
It can be used only for classes. You need to include it in the **bottom** of your class:

```ruby
class Foobar
  #includes/extend definitions

  #methods
  def hard_working_method
  end
  #more methods

  include ClassProfiler #include it just before closing the class
end
```

Or if you want something more configurable, to measure only specific methods and/or
modules you can use this little API:
```ruby
include ClassProfiler.for(instance_methods: [
  :on_correct_scale, :on_correct_currency, :as_financial_value
], modules: [Financial, Company])
```

It comes with a built-in rack middleware to report you the whole request-response cycle
(but you still have to `include ClassProfiler` in the classes of your interest)

```ruby
config.middleware.use ClassProfiler::Rack
```

If you want something more specific, then you only need to wrap the code of your
interest under `start` block:

```ruby
ClassProfiler::Benchmark.instance.start 'MY LABEL' do
  #code I want to benchmark
end
```

Note that `ClassProfiler::Benchmark` class is a singleton.

## How does it work?

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/class_profiler. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

