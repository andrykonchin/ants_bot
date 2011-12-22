$:.unshift File.dirname($0)
require 'ants.rb'
require 'aaz_bot_ai.rb'

ai=AI.new
aaz_bot = AazBotAi.new

ai.setup do |ai|
  aaz_bot.setup ai
end

ai.run do |ai|
  aaz_bot.next_step
end
