extends Node







var player_position = Vector2.ZERO
var player_stats = []
var unconsious_players = []
var achievement_actions = {"Kills":{0:0,1:0}}
var complete_achievments = []
var achievment_list = []
func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	var file = File.new()
	file.open("res://Data/achievements.dat",File.READ)
	achievment_list = str2var(file.get_as_text())
	file.close()
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

func update_achievement_progress(achievement_name,data,increase):
	if ! achievement_actions.has(achievement_name):
		achievement_actions[achievement_name] = {}
	if ! achievement_actions[achievement_name].has(data):
		achievement_actions[achievement_name][data] = increase
	else:
		achievement_actions[achievement_name][data] += increase
	var value_now = achievement_actions[achievement_name][data]
	for achievement in achievment_list:
		if !achievement[2].keys().has(achievement_name) || complete_achievments.has(achievement[0]):continue
		if achievement[2].values()[0] <= value_now:
			complete_achievments.append(achievement[0])
			print(achievement[0])
func _input(_event):
	if Input.is_key_pressed(KEY_L):
		get_tree().paused = false
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Assets/Scenes/Menu/MENU.tscn")
