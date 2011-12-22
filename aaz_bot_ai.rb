require 'rubygems'
require 'logger'

class AazBotAi
  include Utils

  def initialize
    @logger = Logger.new('aaz_bot.log')
  end

  def setup(ai)
    @ai = ai
    @unseen = @ai.map.flatten
    @enemy_hills = []
  end

  def next_step
    move_ants_to next_directions
  end

  private

  def next_directions
    {}.tap do |directions|
      # gathering food
      s_food = FoodGatheringStrategy.new(@ai)
      s_food.update_directions(directions)
      aimed_food = s_food.aimed_food

      # enemy hills
      update_enemy_hills

      s_hills = EnemyHillsStrategy.new(@ai, @enemy_hills)
      s_hills.update_directions(directions)

      # explore unseen locations
      update_unseen

      s_locations = ExploreLocationsStrategy.new(@ai, @unseen)
      s_locations.update_directions(directions)

      # not blocking hills
      s_blocking = NotBlockingHillStrategy.new(@ai, aimed_food)
      s_blocking.update_directions(directions)
    end
  end

  def move_ants_to(directions)
    directions.each do |ant, dir|
      ant.order dir
    end
  end

  def update_enemy_hills
    @enemy_hills.concat(@ai.enemy_hills).uniq!
  end

  def update_unseen
    @unseen.delete_if do |square|
      @ai.my_ants.any? { |ant| ant.see? square }
    end
  end
end

class Strategy
  include Utils

  def directions_for(ant, food)
    [].tap do |result|
      result << :N if ant.row > food.row
      result << :S if ant.row < food.row
      result << :W if ant.col > food.col
      result << :E if ant.col < food.col
    end
  end

  def do_location(distances, directions)
    aimed_targets = {}
    sorted_distances = distances.sort_by { |el| el[:dist] }
    sorted_distances.each do |move|
      ant = move[:ant]
      food = move[:target]

      if !aimed_targets.keys.include?(food) && !aimed_targets.values.include?(ant)
        directions_for(ant, food).each do |dir|
          if try_to_occupied(ant, dir, directions)
            aimed_targets[food] = ant
            break
          end
        end
      end
    end
    aimed_targets
  end

  def try_to_occupied(ant, dir, directions)
    loc = ant.towards(dir)
    unless loc.occupied? || planed_location?(loc, directions)
      directions[ant] = dir
      return true
    end
    false
  end

  def planed_location?(loc, directions)
    directions.map { |ant, dir| ant.towards(dir) }.include?(loc)
  end

  def build_distances(ants, targets)
    [].tap do |distances|
      ants.each do |ant|
        distances.concat targets.map { |target| { :dist => distance(ant, target), :target => target, :ant => ant } }
      end
    end
  end
end

class FoodGatheringStrategy < Strategy
  attr_reader :aimed_food

  def initialize(ai)
    @ai = ai
  end

  def update_directions(directions)
    distances = build_distances(@ai.my_ants, @ai.foods)
    @aimed_food = do_location(distances, directions)
    directions
  end
end

class EnemyHillsStrategy < Strategy
  def initialize(ai, enemy_hills)
    @ai = ai
    @enemy_hills = enemy_hills
  end

  def update_directions(directions)
    free_ants = @ai.my_ants - directions.keys
    hills_distances = build_distances(free_ants, @enemy_hills)

    sorted_distances = hills_distances.sort_by { |el| el[:dist] }
    sorted_distances.each do |move|
      ant = move[:ant]
      hill = move[:target]

      if !directions.keys.include?(ant)
        directions_for(ant, hill).each do |dir|
          if try_to_occupied(ant, dir, directions)
            break
          end
        end
      end
    end
  end
end

class ExploreLocationsStrategy < Strategy
  def initialize(ai, unseen)
    @ai = ai
    @unseen = unseen
  end

  def update_directions(directions)
    free_ants = @ai.my_ants - directions.keys
    unseen_distances = build_distances(free_ants, @unseen)

    do_location(unseen_distances, directions)
  end
end

class NotBlockingHillStrategy < Strategy
  def initialize(ai, aimed_food)
    @ai = ai
    @aimed_food = aimed_food
  end

  def update_directions(directions)
    @ai.my_ants_in_hill.each do |ant|
      unless @aimed_food.values.include?(ant)
        [:N, :S, :W, :E].each do |dir|
          if try_to_occupied(ant, dir, directions)
            break
          end
        end
      end
    end
  end
end
