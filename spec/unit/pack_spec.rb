require 'pack'

describe Pack do
  describe ".all" do
    it "is an array" do
      expect(described_class.all).to be_an Array
    end
  end
end
