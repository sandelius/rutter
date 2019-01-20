# Rutter

HTTP router for Rack.

## Status

Under development, not ready for prime-time just yet.

[![Build Status](https://travis-ci.org/sandelius/rutter.svg?branch=master)](https://travis-ci.org/sandelius/rutter)
[![Test Coverage](https://codeclimate.com/github/sandelius/rutter/badges/coverage.svg)](https://codeclimate.com/github/sandelius/rutter/coverage)
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
