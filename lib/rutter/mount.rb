# frozen_string_literal: true

module Rutter
  # Represents a mounted app route.
  #
  # @see Rutter::Route
  #
  # @private
  class Mount < Route
    # Matches the app pattern against environment.
    #
    # @param env [Hash]
    #   Rack environment hash.
    #
    # @return [nil, String]
    #   Returns the matching substring or nil on no match.
    def match?(env)
      @pattern.peek(env["PATH_INFO"])
    end
  end
end
