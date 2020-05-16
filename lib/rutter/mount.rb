# frozen_string_literal: true

module Rutter
  # Represents a mounted app route.
  #
  # @see Rutter::Route
  #
  # @private
  class Mount < Route
    # @see Rutter::Route#initialize
    #
    # @private
    def initialize(path, endpoint, constraints = nil, host: nil)
      @host = host

      super(path, endpoint, constraints)
    end

    # Matches the app pattern against environment.
    #
    # @param env [Hash]
    #   Rack environment hash.
    #
    # @return [nil, String]
    #   Returns the matching substring or nil on no match.
    def match?(env)
      return if @host && !@host.match?(host(env))

      @pattern.peek(env["PATH_INFO"])
    end

    private

    # @private
    def host(env)
      env["rutter.parsed_host"] ||= begin
        if (forwarded = env["HTTP_X_FORWARDED_HOST"])
          forwarded.split(/,\s?/).last
        else
          env["HTTP_HOST"] || env["SERVER_NAME"] || env["SERVER_ADDR"]
        end
      end
    end
  end
end
