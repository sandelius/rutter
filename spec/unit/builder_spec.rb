# frozen_string_literal: true

module Rutter
  RSpec.describe Builder do
    let(:router) { Builder.new }
    let(:endpoint) { ->(_) {} }

    describe "#mount" do
      it "matches path prefixes" do
        route = router.mount endpoint, at: "/admin"

        expect(route.match?(env_for("/")))
          .to be_nil
        expect(route.match?(env_for("/books")))
          .to be_nil
        expect(route.match?(env_for("/admin")))
          .to eq("/admin")
        expect(route.match?(env_for("/admin/books")))
          .to eq("/admin")
      end

      it "matches host if given" do
        route = router.mount endpoint, at: "/v1", host: /\Aapi\./

        expect(route.match?(env_for("http://example.com/v1/books")))
          .to be_nil
        expect(route.match?(env_for("http://api.example.com/v1/books")))
          .to eq("/v1")
      end

      it "HTTP_X_FORWARDED_HOST are supported" do
        route = router.mount endpoint, at: "/v1", host: /\Aapi\./
        env = env_for("/v1/books", "HTTP_X_FORWARDED_HOST" => "api.example.com")

        expect(route.match?(env))
          .to eq("/v1")
      end
    end

    describe "#path" do
      it "generates a path for named routes" do
        router.get "/login", to: "sessions#new", as: :login
        router.get "/books/:id", to: "books#show", as: :book

        expect(router.path(:login))
          .to eq("/login")
        expect(router.path(:login, return_to: "/"))
          .to eq("/login?return_to=%2F")
        expect(router.path(:book, id: 82))
          .to eq("/books/82")
      end

      it "raises an error if route not founf" do
        expect { router.path(:book) }
          .to raise_error(RuntimeError, "No route called 'book' was found")
      end
    end

    describe "#url" do
      it "generates a full URL for named routes" do
        router = Rutter.new(base: "http://rutter.org")
        router.get "/login", to: "sessions#new", as: :login
        router.get "/books/:id", to: "books#show", as: :book

        expect(router.url(:login))
          .to eq("http://rutter.org/login")
        expect(router.url(:login, return_to: "/"))
          .to eq("http://rutter.org/login?return_to=%2F")
        expect(router.url(:book, id: 82))
          .to eq("http://rutter.org/books/82")
      end

      it "supports adding a subdomain" do
        router = Rutter.new(base: "http://rutter.org")
        router.get "/login", to: "sessions#new", as: :login

        expect(router.url(:login, subdomain: "auth"))
          .to eq("http://auth.rutter.org/login")
      end

      it "raises an error if route not founf" do
        expect { router.url(:book) }
          .to raise_error(RuntimeError, "No route called 'book' was found")
      end
    end

    describe "#add" do
      it "raises an error if the verb is unsupported" do
        expect { router.add("unknown", "/", to: endpoint) }
          .to raise_error(ArgumentError, "Unsupported verb 'UNKNOWN'")
      end

      it "normalize route names" do
        route = router.get "/", to: endpoint, as: "_wierd/__name__"

        expect(router.named_map[:wierd_name])
          .to eq(route)
      end

      it "support using route constraints" do
        route = router.get "/books/:id",
                           to: endpoint,
                           constraints: { id: /\d+/ }

        expect(route.match?(env_for("/books/82")))
          .to be(true)
        expect(route.match?(env_for("/books/pickaxe")))
          .to be(false)
      end
    end

    describe "verbs" do
      VERBS.each do |verb|
        describe "##{verb.downcase}" do
          it "recognize #{verb} verb" do
            route = router.public_send verb.downcase, "/", to: endpoint

            expect(router.verb_map[verb])
              .to eq([route])
          end
        end
      end
    end

    describe "#freeze" do
      it "freezes the router and its maps" do
        router.freeze

        expect(router)
          .to be_frozen
        expect(router.flat_map)
          .to be_frozen
        expect(router.verb_map)
          .to be_frozen
        expect(router.named_map)
          .to be_frozen
      end
    end
  end
end
