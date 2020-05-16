# Rutter

HTTP router for Ramverk and Rack.

[![Build Status](https://travis-ci.org/sandelius/rutter.svg?branch=master)](https://travis-ci.org/sandelius/rutter)
[![codecov](https://codecov.io/gh/sandelius/rutter/branch/master/graph/badge.svg)](https://codecov.io/gh/sandelius/rutter)
[![Inline docs](http://inch-ci.org/github/sandelius/rutter.svg?branch=master)](http://inch-ci.org/github/sandelius/rutter)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rutter"
```

## Usage

The main purpose of a router is to map URL's to endpoints. An endpoint needs to
be either an object that responds to `call(env)` or a string that can be resolved
to one.

Below are examples of both endpoint styles:

```ruby
Rutter.new do
  # Endpoint that implements #call
  get "/books", to: ->(env) { [200, {}, ["My Bookshelf"]] }
end.freeze
```

```ruby
class Books
  def self.call(env)
    [200, {}, ["My Bookshelf"]]
  end
end

Rutter.new do
  # String that resolves to endpoint
  get "/books", to: "books" # This will be resolved to <Books>
end.freeze
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sandelius/rutter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
