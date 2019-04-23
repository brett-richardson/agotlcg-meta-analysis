require 'json'

class Card
  DATA_PATH = 'data/cards.json'
  SET_MATCHER = /.+\((.*)\)/

  def self.all
    @all ||= JSON.parse File.read DATA_PATH
  end

  def self.[](key)
    found = all.find { |c| c['name'].downcase == key.downcase }
    return found if found

    {
      'name' => key,
      'pack_name' => "CARD NOT FOUND: #{key}",
      'pack_code' => SET_MATCHER.match(key)[1]
    }
  end
end
