# frozen_string_literal: true

module Rutter
  # Conveniences for inflecting and working with names in Rutter.
  module Naming
    module_function

    # Return a downcased and underscore separated version of the string.
    #
    # Revised version of `Hanami::Utils::String.underscore` implementation.
    #
    # @param string [String]
    #   String to be transformed.
    #
    # @return [String]
    #   The transformed string.
    #
    # @example
    #   string = "RutterNaming"
    #   Rutter::Naming.underscore(string) # => 'rutter_naming'
    def underscore(string)
      string = +string.to_s
      string.gsub!("::", "/")
      string.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
      string.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      string.gsub!(/[[:space:]]|\-/, '\1_\2')
      string.downcase!
      string
    end

    # Return a CamelCase version of the string.
    #
    # Revised version of `Hanami::Utils::String.classify` implementation.
    #
    # @param string [String]
    #   String to be transformed.
    #
    # @return [String]
    #   The transformed string
    #
    # @example
    #   string = "rutter_naming"
    #   Rutter::Naming.classify(string) # => 'RutterNaming'
    def classify(string)
      words = underscore(string).split(%r{_|::|\/|\-}).map!(&:capitalize)
      delimiters = underscore(string).scan(%r{_|::|\/|\-})
      delimiters.map! { |delimiter| delimiter == "_" ? "" : "::" }
      words.zip(delimiters).join
    end

    # Normalize the given string/symbol to a valid route name.
    #
    # @param string [String, Symbol]
    #   Name to be normalized.
    #
    # @return [Symbol]
    #   Normalized route name.
    def route_name(string)
      string = underscore(string)
      string.tr!("/", "_")
      string.gsub!(/[_]{2,}/, "_")
      string.gsub!(/\A_|_\z/, "")
      string.to_sym
    end

    # Normalize the given path.
    #
    # @param path [String]
    #   Path to be normalized.
    #
    # @return [String]
    #   Normalized path.
    def cleanpath(path)
      Pathname.new("/#{path}").cleanpath.to_s
    end

    # Join the given arguments with the separator.
    #
    # @overload join(part)
    #   @param part [String, nil]
    #     First part to join.
    # @overload join(part)
    #   @param ... [String, nil]
    #     Another part to join.
    #
    # @param sep [String]
    #   Part separator.
    #
    # @return [String]
    def join(*part, sep: "/")
      part.reject { |s| s.nil? || s == "" }
          .join(sep)
    end
  end
end
