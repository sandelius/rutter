# frozen_string_literal: true

require "mustermann"

module Rutter
  # Represents a single route.
  #
  # @!attribute [r] path
  #   @return [String] Raw path template.
  # @!attribute [r] endpoint
  #   @return [Hash] Route endpoint.
  #
  # @private
  class Route
    attr_reader :path
    attr_reader :endpoint

    # Initializes the route.
    #
    # @param path [String]
    #   Path template to match.
    # @param endpoint [#call]
    #   Rack endpoint.
    # @param constraints [Hash]
    #   Route segment constraints.
    #
    # @return [void]
    #
    # @private
    def initialize(path, endpoint, constraints = nil)
      @path = Naming.cleanpath(path)
      @endpoint = endpoint_to_hash(endpoint)
      @pattern = ::Mustermann.new(@path, capture: constraints)
      freeze
    end

    # Matches the route pattern against environment.
    #
    # @param env [Hash]
    #   Rack environment hash.
    #
    # @return [Boolean]
    def match?(env)
      @pattern === env["PATH_INFO"] # rubocop:disable Style/CaseEquality
    end

    # Generates a path from the given arguments.
    #
    # @overload expand(key: value)
    #   @param key [String, Integer, Array]
    #     Key value.
    # @overload expand(key: value, key2: value2)
    #   @param key2 [String, Integer, Array]
    #     Key value.
    #
    # @return [String]
    #   Generated path.
    #
    # @raise [ArguemntError]
    #   If the path cannot be generated. Mostly due to missing key(s).
    def expand(**args)
      @pattern.expand(:append, **args)
    rescue ::Mustermann::ExpandError => e
      raise ArgumentError, e.message
    end

    # Extract params from the given path.
    #
    # @param path [String]
    #   Path used to extract params from.
    #
    # @return [Hash]
    def params(path)
      @pattern.params(path)
    end

    # Calls the endpoint.
    #
    # @param env [Hash]
    #   Rack's environment hash.
    #
    # @return [Array]
    #   Rack response array.
    #
    # @private
    def call(env)
      env["rutter.params"] ||= {}
      env["rutter.params"].merge!(params(env["PATH_INFO"]))
      env["rutter.action"] = @endpoint[:action]

      ctrl = @endpoint[:controller]
      ctrl = ::Object.const_get(ctrl) if ctrl.is_a?(String)
      ctrl.call(env)
    end

    private

    # @private
    def endpoint_to_hash(endpoint)
      ctrl, action = if endpoint.is_a?(String)
                       ctrl, action = endpoint.split("#")
                       ctrl = Naming.classify(ctrl)
                       [ctrl, action]
                     else
                       [endpoint, nil]
                     end

      { controller: ctrl, action: action }
    end
  end
end
