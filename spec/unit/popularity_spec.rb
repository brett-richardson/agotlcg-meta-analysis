require 'popularity'

describe Popularity do
  describe ".all" do
    it "is an array" do
      expect(described_class.all).to be_a Hash
    end
  end

  describe ".best_agendas" do
    it "is an array" do
      expect(described_class.best_agendas).to be_an Array
    end
  end

  describe ".best_plots" do
    it "is an array" do
      expect(described_class.best_plots).to be_an Array
    end
  end
end
