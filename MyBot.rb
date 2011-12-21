$:.unshift File.dirname($0)
require 'ants.rb'
require 'aaz_bot_ai.rb'

ai=AI.new
bot_ai = AazBotAi.new

ai.setup do |ai|
	# your setup code here, if any
end

ai.run do |ai|
	# your turn code here
  bot_ai.next_step(ai)
end
