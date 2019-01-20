# frozen_string_literal: true

module Rutter
  RSpec.describe Routes do
    let(:router) { Rutter.new }
    let(:routes) { Routes.new(router) }
    let(:endpoint) { ->(_) {} }

    it "has a *_path helper method" do
      router.get "/books/:id", to: endpoint, as: :book

      expect(routes.book_path(id: 54))
        .to eq("/books/54")
    end

    it "has a *_url helper method" do
      router.get "/books/:id", to: endpoint, as: :book

      expect(routes.book_url(id: 54))
        .to eq("http://localhost:9292/books/54")
    end

    it "raises RuntimeError if route not found" do
      expect { routes.invalid_path }
        .to raise_error(RuntimeError)
    end

    it "raises NoMethodError if unknown method is called" do
      expect { routes.invalid }
        .to raise_error(NoMethodError)
    end

    it "support respond_to?" do
      router.get "/books/:id", to: endpoint, as: :book

      expect(routes.respond_to?(:book))
        .to eq(false)
      expect(routes.respond_to?(:book_path))
        .to eq(true)
      expect(routes.respond_to?(:book_url))
        .to eq(true)
    end
  end
end
