require 'pry'
require 'date'
require 'active_support/all'
require './lib/popularity'
require './lib/card'
require './lib/pack'

def get_set_value(pack, value)
  return value if pack['total'] > 200

  if pack['total'] > 48 && pack['total'] < 55
    value * 0.25
  else
    date = DateTime.parse pack['available']
    difference = (DateTime.now - date) / 365.25
    value / (difference + 1)
  end
end

VALUES = {
  base: 1,
  agenda: 3,
  plot: 3,
  non_loyal: 1,
  neutral: 2,
}

sets = {}

Popularity.best_agendas.map do |card|
  Card[card['name']].merge card
end.compact.each do |card|
  sets[card['pack_code']] ||= 0
  sets[card['pack_code']] += VALUES[:agenda] * card['count']
end

Popularity.best_plots.map do |card|
  Card[card['name']].merge card
end.compact.each do |card|
  sets[card['pack_code']] ||= 0
  sets[card['pack_code']] += VALUES[:plot] * card['count']
end

Popularity.all['orderedCardList'].map do |card|
  Card[card['name']].merge card
end.compact.each do |card|
  sets[card['pack_code']] ||= 0
  sets[card['pack_code']] += VALUES[:base] * card['count']

  if card['is_neutral']
    sets[card['pack_code']] += VALUES[:neutral] * card['count']
  end

  unless card['is_loyal']
    sets[card['pack_code']] += VALUES[:non_loyal] * card['count']
  end
end

sets.transform_keys! { |key| Pack[key] }
total_meta = sets.values.sum

puts "=" * 74
puts sprintf("%5s | %32s | %8s | %10s | %s",
  'META %', 'SET NAME', '# CARDS', 'TIME LEFT', 'POINTS'
)
puts "=" * 74

sets.sort_by do |pack, value|
  get_set_value(pack, value)
end.reverse.each do |pack, value|
  percentage = (value.to_f / total_meta * 100).round 2
  date = DateTime.parse pack['available']
  difference = (DateTime.now - date) / 365.25
  time_left_in_meta = sprintf('%3.1f', 4 - difference)
  time_left_in_meta = '' if pack['total'] > 20

  puts sprintf("%#5.2f%% | %32s | %8i | %10s | %4i",
    percentage,
    pack['name'],
    pack['total'],
    time_left_in_meta,
    get_set_value(pack, value).to_i
  )
end
