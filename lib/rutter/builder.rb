# frozen_string_literal: true

require "uri"

require_relative "naming"
require_relative "verbs"
require_relative "route"
require_relative "mount"
require_relative "scope"
require_relative "routes"

module Rutter
  # The builder map URL's to endpoints.
  #
  # @!attribute [r] flat_map
  #   @return [Array]
  #     Defined routes in a flat map.
  # @!attribute [r] verb_map
  #   @return [Hash]
  #     Defined routes grouped by verb.
  # @!attribute [r] named_map
  #   @return [Hash]
  #     Defined routes grouped by route name.
  class Builder
    attr_reader :flat_map
    attr_reader :verb_map
    attr_reader :named_map

    # Initializes the builder.
    #
    # @param base [String]
    #   Base URL, used for generating URLs.
    #
    # @yield
    #   Executes the block inside the created builder context.
    #
    # @return [void]
    #
    # @private
    def initialize(base: "http://localhost:9292", &block)
      @uri = URI(base).freeze
      @flat_map = []
      @verb_map = Hash.new { |h, k| h[k] = [] }
      @named_map = {}

      instance_eval(&block) if block_given?
    end

    # Create a scoped set of routes.
    #
    # @param path [String]
    #   Scope path prefix.
    # @param namespace [String, Symbol]
    #   Scope namespace.
    # @param as [Symbol]
    #   Scope name prefix.
    #
    # @yield
    #   Block is evaluated inside the created scope context.
    #
    # @return [Rutter::Scope]
    #
    # @see Rutter::Scope
    def scope(path: nil, namespace: nil, as: nil, &block)
      Scope.new(self, path: path, namespace: namespace, as: as, &block)
    end

    # Creates a scoped collection of routes with the given name as namespace.
    #
    # @param name [Symbol, String]
    #   Scope namespace.
    #
    # @yield
    #   Scope context.
    #
    # @return [Rutter::Scope]
    #
    # @example
    #   Rutter.new do
    #     namespace :admin do
    #       get "/login", to: "sessions#new", as: :login
    #     end
    #   end
    def namespace(name, &block)
      scope path: name, namespace: name, as: name, &block
    end

    # Mount a Rack compatible at the given path prefix.
    #
    # @param app [#call]
    #   Application to mount.
    # @param at [String]
    #   Path prefix to match.
    # @param host [Regexp]
    #   Match the given host pattern.
    #
    # @return [Rutter::Mount]
    def mount(app, at:, host: nil)
      route = Mount.new(at, app, host: host)
      @flat_map << route
      VERBS.each { |verb| @verb_map[verb] << route }
      route
    end

    # Generates a path from the given arguments.
    #
    # @param name [Symbol]
    #   Name of the route to generate path from.
    #
    # @overload path(name, key: value)
    #   @param key [String, Integer, Array]
    #     Key value.
    # @overload path(name, key: value, key2: value2)
    #   @param key2 [String, Integer, Array]
    #     Key value.
    #
    # @return [String]
    #   Generated path.
    #
    # @raise [RuntimeError]
    #   If the route cannot be found.
    #
    # @see Rutter::Route#expand
    #
    # @example
    #   router = Rutter.new(base: "http://rutter.org")
    #   router.get "/login", to: "sessions#new", as: :login
    #   router.get "/books/:id", to: "books#show", as: :book
    #
    #   router.path(:login)
    #     # => "/login"
    #   router.path(:login, return_to: "/")
    #     # => "/login?return_to=/"
    #   router.path(:book, id: 82)
    #     # => "/books/82"
    def path(name, **args)
      unless (route = @named_map[name])
        raise "No route called '#{name}' was found"
      end

      route.expand(**args)
    end

    # Generates a full URL from the given arguments.
    #
    # @param name [Symbol]
    #   Name of the route to generate URL from.
    #
    # @overload expand(name, subdomain: value)
    #   @param subdomain [String, Symbol]
    #     Subdomain to be added to the host.
    # @overload expand(name, key: value)
    #   @param key [String, Integer, Array]
    #     Key value.
    # @overload expand(name, key: value, key2: value2)
    #   @param key2 [String, Integer, Array]
    #     Key value.
    #
    # @return [String]
    #   Generated URL.
    #
    # @raise [RuntimeError]
    #   If the route cannot be found.
    #
    # @see Rutter::Builder#path
    #
    # @example
    #   router = Rutter.new(base: "http://rutter.org")
    #   router.get "/login", to: "sessions#new", as: :login
    #   router.get "/books/:id", to: "books#show", as: :book
    #
    #   router.url(:login)
    #     # => "http://rutter.org/login"
    #   router.url(:login, return_to: "/")
    #     # => "http://rutter.org/login?return_to=/"
    #   router.url(:book, id: 82)
    #     # => "http://rutter.org/books/82"
    def url(name, **args)
      host = @uri.scheme + "://"
      host += "#{args.delete(:subdomain)}." if args.key?(:subdomain)
      host += @uri.host
      host += ":#{@uri.port}" if @uri.port != 80 && @uri.port != 443
      host + path(name, **args)
    end

    # Add a new, frozen, route to the map.
    #
    # @param verb [String]
    #   Request verb to match.
    # @param path [String]
    #   Path template to match.
    # @param to [#call]
    #   Rack endpoint.
    # @param as [Symbol, String]
    #   Route name/identifier.
    # @param constraints [Hash]
    #   Route segment constraints.
    #
    # @return [Rutter::Route]
    #
    # @raise [ArgumentError]
    #   If verb is unsupported.
    #
    # @private
    def add(verb, path, to:, as: nil, constraints: nil)
      verb = verb.to_s.upcase

      unless VERBS.include?(verb)
        raise ArgumentError, "Unsupported verb '#{verb}'"
      end

      route = Route.new(path, to, constraints)
      @flat_map << route
      @verb_map[verb] << route
      return route unless as

      named_map[Naming.route_name(as)] = route
    end

    # Freeze the state of the router.
    #
    # @return [self]
    def freeze
      @flat_map.freeze
      @verb_map.freeze
      @verb_map.each_value(&:freeze)
      @named_map.freeze

      super
    end

    # @see #add
    VERBS.each do |verb|
      define_method verb.downcase do |path, to:, as: nil, constraints: nil|
        add verb, path, to: to, as: as, constraints: constraints
      end
    end

    # Process the request and is compatible with the Rack protocol.
    #
    # @param env [Hash]
    #   Rack environment hash.
    #
    # @return [Array]
    #   Serialized Rack response.
    #
    # @see http://rack.github.io
    #
    # @private
    def call(env)
      request_method = env["REQUEST_METHOD"]

      return NOT_FOUND_RESPONSE unless @verb_map.key?(request_method)

      routes = @verb_map[request_method]
      routes.each do |route|
        next unless route.match?(env)
        return route.call(env)
      end

      NOT_FOUND_RESPONSE
    end

    # @private
    NOT_FOUND_RESPONSE = [404, { "X-Cascade" => "pass" }, ["Not Found"]].freeze
  end
end
