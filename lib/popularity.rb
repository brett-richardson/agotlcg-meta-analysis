require 'json'

class Popularity
  DATA_PATH = 'data/popularity.json'

  def self.all
    @all ||= JSON.parse File.read DATA_PATH
  end

  def self.best_agendas
    all['orderedAgendaList']
  end

  def self.best_plots
    all['orderedPlotLists']['all']
  end
end
