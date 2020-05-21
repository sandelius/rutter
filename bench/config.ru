# frozen_string_literal: true

# puma -e production -t 16:16

require "bundler/setup"
require "rutter"

router = Rutter.new do
  # wrk -t 2 http://localhost:9292/
  get "/", to: ->(_) { [200, {}, ["Hello World"]] }

  # wrk -t 2 http://localhost:9292/ruby
  get "/:lang", to: ->(env) { [200, {}, [env["router.params"]["lang"]]] }
end.freeze

run router
