# frozen_string_literal: true

require File.expand_path("lib/rutter/version", __dir__)

Gem::Specification.new do |spec|
  spec.name = "rutter"
  spec.version = Rutter::VERSION
  spec.summary = "HTTP router for Rack."

  spec.required_ruby_version = ">= 2.5.0"
  spec.required_rubygems_version = ">= 2.5.0"

  spec.license = "MIT"

  spec.author = "Tobias Sandelius"
  spec.email = "tobias@sandeli.us"
  spec.homepage = "https://github.com/sandelius/rutter"

  spec.files = `git ls-files -z`.split("\x0")
  spec.test_files = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "mustermann", "~> 1.0"
  spec.add_runtime_dependency "rack", "~> 2.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rack-test"
end
