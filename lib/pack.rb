require 'json'

class Pack
  DATA_PATH = 'data/packs.json'

  def self.all
    @all ||= JSON.parse File.read DATA_PATH
  end

  def self.[](key)
    all.find { |c| c['code'].downcase == key.downcase }
  end
end
