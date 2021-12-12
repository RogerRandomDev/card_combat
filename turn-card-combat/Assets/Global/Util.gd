extends Node







var player_position = Vector2.ZERO
var player_stats = []
var unconsious_players = []

# Util.choose(["one", "two"])   returns one or two
func choose(choices):
	randomize()

	var rand_index = randi() % choices.size()
	return choices[rand_index]

# the percent chance something happens
func chance(num):
	randomize()

	if randi() % 100 <= num: return true
	else:                    return false

# returns random int between low and high
func randi_range(low, high):
	return floor(rand_range(low, high))
