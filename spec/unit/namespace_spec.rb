# frozen_string_literal: true

module Rutter
  RSpec.describe Builder do
    let(:router) { Rutter.new }

    describe "namespace" do
      it "support nested namespacees" do
        router.namespace :species do
          namespace :mammals do
            get "/cats", to: "cats#index", as: :cats
          end
        end

        route = router.flat_map.first

        expect(route.path)
          .to eq("/species/mammals/cats")
        expect(route.endpoint)
          .to eq(controller: "Species::Mammals::Cats", action: "index")
        expect(router.named_map[:species_mammals_cats])
          .to eq(route)
      end
    end
  end
end
