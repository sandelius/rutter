# frozen_string_literal: true

# HTTP router for Rack.
module Rutter
  # Supported request verbs.
  #
  # @return [Array]
  VERBS = %w[GET POST PUT PATCH DELETE OPTIONS].freeze

  require_relative "rutter/version"
  require_relative "rutter/builder"

  # Factory method for creating a new builder object.
  #
  # @param base [String]
  #   Base URL, used for generating URLs.
  #
  # @yield
  #   Executes the block inside the created builder context.
  #
  # @see Rutter::Builder#initialize
  def self.new(base: "http://localhost:9292", &block)
    Builder.new(base: base, &block)
  end
end
