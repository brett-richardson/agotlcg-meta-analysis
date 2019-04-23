require 'card'

describe Card do
  describe ".all" do
    it "is an array" do
      expect(described_class.all).to be_an Array
    end
  end

  describe ".[]" do
    it "finds the card by name" do
      expect(described_class["Fealty"]).to be_a Hash
    end
  end
end
