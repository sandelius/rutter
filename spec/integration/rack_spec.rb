# frozen_string_literal: true

RSpec.describe "Rack compatible", type: :request do
  let :router do
    Rutter.new do
      get "/say/:message", to: (lambda do |env|
        [200, {}, ["I say, #{env['rutter.params']['message']}"]]
      end)
    end
  end

  def app
    router.freeze
  end

  context "with match" do
    it "calls the matched endpoint" do
      get "/say/hello-world"

      expect(last_response.status)
        .to eq(200)
      expect(last_response.body)
        .to eq("I say, hello-world")
      expect(last_response.headers["Content-Length"])
        .to eq("18")
    end
  end

  context "with no match" do
    it "returns 404" do
      get "/authors"

      expect(last_response.status)
        .to eq(404)
      expect(last_response.body)
        .to eq("Not Found")
      expect(last_response.headers["X-Cascade"])
        .to eq("pass")
    end
  end
end
