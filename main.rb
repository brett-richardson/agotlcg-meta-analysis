require 'pry'
require 'date'
require 'active_support/all'
require './lib/popularity'
require './lib/card'
require './lib/pack'

CORE_SET_PRICE = 29_00
DELUXE_PRICE   = 26_00
CHAPTER_PRICE  = 15_00

def set_value(pack, value)
  value *
    quality_multipler(pack, value) *
    expiry_multiplier(pack) *
    card_cost_multiplier(pack)
end

def quality_multipler(pack, value)
  value / pack['total']
end

def card_cost_multiplier(pack)
  case
  when pack['total'] > 200 then CORE_SET_PRICE
  when pack['total'] > 50 then DELUXE_PRICE
  else CHAPTER_PRICE
  end / pack['total']
end

def expiry_multiplier(pack)
  return 1 if pack['total'] > 20
  date = DateTime.parse pack['available']
  difference = (DateTime.now - date) / 365.25
  (4 - difference) / 4
end

VALUES = {
  base: 10,
  agenda: 40,
  plot: 30,
  non_loyal: 15,
  neutral: 20,
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
  set_value(pack, value)
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
    set_value(pack, value).to_i
  )
end
