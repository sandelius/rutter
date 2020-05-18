# frozen_string_literal: true

module Rutter
  # Represents a scoped set.
  #
  # @see Rutter::Builder#scope
  #
  # @private
  class Scope
    # Initializes the scope.
    #
    # @param router [Rutter::Builder]
    #   Router object.
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
    # @return [void]
    #
    # @private
    def initialize(router, path: nil, namespace: nil, as: nil, &block)
      @router = router
      @path = path
      @namespace = namespace
      @as = as

      instance_eval(&block) if block_given?
    end

    # @see Rutter::Builder#mount
    def mount(app, at:, host: nil)
      @router.mount app, at: Naming.join(@path, at), host: host
    end

    # @see Rutter::Builder#scope
    def scope(path: nil, namespace: nil, as: nil, &block)
      Scope.new(self, path: path, namespace: namespace, as: as, &block)
    end

    # @see Rutter::Builder#namespace
    def namespace(name, &block)
      scope path: name, namespace: name, as: name, &block
    end

    # @see Rutter::Builder#add
    def add(verb, path, to: nil, as: nil, constraints: nil, &block)
      path = Naming.join(@path, path)
      to = Naming.join(@namespace, to) if to.is_a?(String)
      as = Naming.join(@as, as) if as

      @router.add verb, path, to: to, as: as, constraints: constraints, &block
    end

    # @see Rutter::Builder#add
    VERBS.each do |verb|
      define_method verb.downcase do |path, to: nil, as: nil, constraints: nil, &block|
        add verb, path, to: to, as: as, constraints: constraints, &block
      end
    end
  end
end
