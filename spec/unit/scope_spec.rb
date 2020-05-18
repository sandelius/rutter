# frozen_string_literal: true

module Rutter
  RSpec.describe Scope do
    let(:router) { Rutter.new }
    let(:endpoint) { ->(_) {} }

    it "support nested scopes" do
      router.scope path: "animals", namespace: "species", as: :animals do
        scope path: "mammals", namespace: "mammals", as: :mammals do
          get "/cats", to: "cats#index", as: :cats
        end
      end

      route = router.flat_map.first

      expect(route.path)
        .to eq("/animals/mammals/cats")
      expect(route.endpoint)
        .to eq(controller: "Species::Mammals::Cats", action: "index")
      expect(router.named_map[:animals_mammals_cats])
        .to eq(route)
    end

    describe "#add" do
      it "support using route constraints" do
        scope = router.scope path: "/books"
        route = scope.get "/:id",
                          to: endpoint,
                          constraints: { id: /\d+/ }

        expect(route.match?(env_for("/books/82")))
          .to be(true)
        expect(route.match?(env_for("/books/pickaxe")))
          .to be(false)
      end

      it "support block as endpoint" do
        scope = router.scope path: "/books"
        scope.get "/" do |env|
          [200, {}, [env["message"]]]
        end

        _, _, body = router.call("REQUEST_METHOD" => "GET",
                                 "PATH_INFO" => "/books",
                                 "message" => "Hello World")

        expect(body.join)
          .to eq("Hello World")
      end
    end

    describe "#mount" do
      it "matches path prefixes" do
        scope = router.scope path: "/api"
        route = scope.mount endpoint, at: "/v1"

        expect(route.match?(env_for("/")))
          .to be_nil
        expect(route.match?(env_for("/api")))
          .to be_nil
        expect(route.match?(env_for("/api/v1")))
          .to eq("/api/v1")
        expect(route.match?(env_for("/api/v1/books")))
          .to eq("/api/v1")
      end
    end

    describe "verbs" do
      let(:scope) { router.scope }

      VERBS.each do |verb|
        describe "##{verb.downcase}" do
          it "recognize #{verb} verb" do
            route = scope.public_send verb.downcase, "/", to: endpoint

            expect(router.verb_map[verb])
              .to eq([route])
          end
        end
      end
    end
  end
end
