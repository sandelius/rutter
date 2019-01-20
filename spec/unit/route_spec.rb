# frozen_string_literal: true

module Rutter
  RSpec.describe Route do
    let(:endpoint) { ->(_) {} }

    it "freezes the object" do
      expect(Route.new("/", endpoint))
        .to be_frozen
    end

    describe "#match?" do
      it "returns true if path match" do
        route = Route.new("/books", endpoint)

        expect(route.match?(env_for("/books")))
          .to be(true)
      end

      it "returns false if path does not match" do
        route = Route.new("/books", endpoint)

        expect(route.match?(env_for("/")))
          .to be(false)
      end

      it "support using route constraints" do
        route = Route.new("/books/:id", endpoint, id: /\d+/)

        expect(route.match?(env_for("/books/82")))
          .to be(true)
        expect(route.match?(env_for("/books/pickaxe")))
          .to be(false)
      end
    end

    describe "#expand" do
      let(:route) do
        Route.new("/books/:book_id/reviews/:id", endpoint, {})
      end

      it "generates path from given args" do
        expect(route.expand(book_id: 1, id: 2))
          .to eq("/books/1/reviews/2")
      end

      it "raises an error if a required argument is missing" do
        expect { route.expand(book_id: 1) }
          .to raise_error(ArgumentError, /cannot expand with keys/)
      end
    end

    describe "#params" do
      it "extract params" do
        route = Route.new("/pages/:id(/:title)?", endpoint)

        expect(route.params("/pages/54/eloquent-ruby"))
          .to eq("id" => "54", "title" => "eloquent-ruby")
        expect(route.params("/pages/54"))
          .to eq("id" => "54", "title" => nil)
      end
    end
  end
end
