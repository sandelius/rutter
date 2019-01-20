# frozen_string_literal: true

require "forwardable"

module Rutter
  # Routes URL builder.
  #
  # @see Rutter::Builder#path
  # @see Rutter::Builder#url
  #
  # @example
  #   router = Rutter.new(base: "http://rutter.org") do
  #     get "/login", to: "sessions#new", as: :login
  #     get "/books/:id", to: "books#show", as: :book
  #   end.freeze
  #
  #   routes = Rutter::Routes.new(router)
  #
  #   routes.login_path
  #     # => "/login"
  #   routes.login_path(return_to: "/")
  #     # => "/login?return_to=/"
  #   routes.book_path(id: 82)
  #     # => "/books/82"
  #
  #   routes.login_url
  #     # => "http://rutter.org/login"
  #   routes.login_url(return_to: "/")
  #     # => "http://rutter.org/login?return_to=/"
  #   routes.book_url(id: 82)
  #     # => "http://rutter.org/books/82"
  class Routes
    extend Forwardable

    # Delegate path and url method to the router.
    #
    # @see Rutter::Builder#path
    # @see Rutter::Builder#url
    def_delegators :@router, :path, :url

    # Initializes the helper.
    #
    # @param router [Rutter::Builder]
    #   Route router object.
    #
    # @return [void]
    #
    # @private
    def initialize(router)
      @router = router
    end

    protected

    # @private
    def method_missing(method_name, *args)
      named_route, type = method_name.to_s.split(/\_(path|url)\z/)
      return super unless type
      @router.public_send(type, named_route.to_sym, *args)
    end

    # @private
    def respond_to_missing?(method_name, include_private = false)
      meth = method_name.to_s
      meth.end_with?("_path", "_url") || super
    end
  end
end
