extends Node







var player_position = Vector2.ZERO
var player_stats = []
var unconsious_players = []
var achievement_actions = {}
var complete_achievments = []
var achievment_list = []
var stored_items = []
var cur_layer = 0
var last_scene = "Map"
var conditions_done = {}
var dont_speak_again = []
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
			load_achievement(achievement[0],achievement[1])
func get_achievment_progress(achievement_name):
	if !achievement_actions.has(achievement_name):return 0
	return achievement_actions[achievement_name]["count"]



func _input(_event):
	if Input.is_key_pressed(KEY_L):
		get_tree().paused = false
		Save.save_game()
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Assets/Scenes/Menu/MENU.tscn")


func load_achievement(Name,Tex):
	if !get_tree().get_nodes_in_group("achievement_object").size() != 0:return
	get_tree().get_nodes_in_group("achievement_object")[0].load_achievement(Name,Tex)
	
func update_conditions(condition_name,value):
	if !conditions_done.has(condition_name):
		conditions_done[condition_name] = value
	else:
		conditions_done[condition_name] += value
func get_condition(condition_name):
	if conditions_done.has(condition_name):return conditions_done[condition_name]
	if achievement_actions.has(condition_name):return achievement_actions[condition_name].values()[0]
	return -1
