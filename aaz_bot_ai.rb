require 'rubygems'
require 'logger'

class AazBotAi

  class Location
    attr_accessor :row, :col

    def initialize(coord)
      @col = coord[:col]
      @row = coord[:row]
    end
  end

  def initialize
    @logger = Logger.new('aaz_bot.log')
  end

  def next_step(ai)
    move_ants_to next_directions(ai)
  end

  private

  def next_directions(ai)
    {}.tap do |directions|
      distances = []
      foods(ai).each do |food|
        distances.concat ai.my_ants.map { |ant| { :dist => distance(ant, food), :food => food, :ant => ant } }
      end

      aimed_food = {}
      sorted_distances = distances.sort_by { |el| el[:dist] }
      sorted_distances.each do |move|
        ant = move[:ant]
        food = move[:food]

        if !aimed_food.keys.include?(food) && !aimed_food.values.include?(ant)
          directions_for(ant, food).each do |dir|
            if try_to_occupied(ant, dir, directions)
              aimed_food[food] = ant
              break
            end
          end
        end
      end

      my_ants_in_hill(ai).each do |ant|
        unless aimed_food.values.include?(ant)
          [:N, :S, :W, :E].each do |dir|
            if try_to_occupied(ant, dir, directions)
              break
            end
          end
        end
      end
    end
  end

  def try_to_occupied(ant, dir, directions)
    loc = next_location(ant, dir)
    if unoccupied_location?(loc) && !planed_location?(loc, directions)
      directions[ant] = dir
      return true
    end
    false
  end

  def move_ants_to(directions)
    directions.each do |ant, dir|
      ant.order dir
    end
  end

  def unoccupied_location?(loc)
    !loc.water? && !loc.food? && !loc.hill? && !loc.ant? && !loc.hill?
  end

  def planed_location?(loc, directions)
    directions.map { |a, d| next_location(a, d) }.include?(loc)
  end

  def next_location(ant, dir)
    ant.square.neighbor(dir)
  end

  def foods(ai)
    ai.map.flatten.select(&:food?)
  end

  def my_ants_in_hill(ai)
    ai.my_ants.select { |ant| ant.square.hill? }
  end

  def distance(loc1, loc2)
    Math.hypot(loc1.col - loc2.col, loc1.row - loc2.row)
  end

  def directions_for(ant, food)
    [].tap do |result|
      result << :N if ant.row > food.row
      result << :S if ant.row < food.row
      result << :W if ant.col > food.col
      result << :E if ant.col < food.col
    end
  end
end
