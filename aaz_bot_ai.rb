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
      ai.my_ants.each do |ant|
        [:N, :E, :S, :W].each do |dir|
          loc = next_location(ant, dir)
          if unoccupied_location?(loc) && !planed_location?(loc, directions)
            directions[ant] = dir
            break
          end
        end
      end
    end
  end

  def move_ants_to(directions)
    directions.each do |ant, dir|
      ant.order dir
    end
  end

  def unoccupied_location?(loc)
    !loc.water? && !loc.food? && !loc.hill? && !loc.ant?
  end

  def planed_location?(loc, directions)
    directions.map { |a, d| next_location(a, d) }.include?(loc)
  end

  def next_location(ant, dir)
    ant.square.neighbor(dir)
  end
end
