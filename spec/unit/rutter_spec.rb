# frozen_string_literal: true

RSpec.describe Rutter do
  it "has a version number" do
    expect(Rutter::VERSION).to be_a(String)
  end

  describe ".new" do
    it "creates a new builder object" do
      expect(Rutter.new)
        .to be_a(Rutter::Builder)
    end
  end
end
