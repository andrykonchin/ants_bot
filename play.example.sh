#!/usr/bin/env sh
#./playgame.py --player_seed 42 --end_wait=0.25 --verbose --log_dir game_logs --turns 1000 --map_file maps/maze/maze_04p_01.map "$@" "python sample_bots/python/HunterBot.py" "python sample_bots/python/LeftyBot.py" "python sample_bots/python/HunterBot.py" "python sample_bots/python/GreedyBot.py"

#./playgame.py --player_seed 42 --end_wait=0.25 --verbose --log_dir game_logs --turns 1000 --map_file maps/maze/maze_04p_01.map "$@" "python sample_bots/python/HunterBot.py" "python sample_bots/python/LeftyBot.py" "python sample_bots/python/HunterBot.py" "ruby ~/projects/ants_bot/MyBot.rb"

python playgame.py "ruby ../MyBot.rb" "python sample_bots/python/HunterBot.py" --map_file maps/example/tutorial1.map --log_dir game_logs --turns 100 --scenario --food none --player_seed 7 --verbose -e
