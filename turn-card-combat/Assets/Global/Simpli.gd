extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player_characters = [0,0,0]
var cur_dungeon = 0


func in_range_Vector2(position,start,end):
	return (
		position.x>=start.x &&
		position.y>=start.y &&
		position.x<=end.x &&
		position.y<=end.y
	)


var cards=[]
var level_data = []
var character_data = []
var enemy_data = []
var char_dat = []
func _ready():
	var file = File.new()
	file.open("res://Data/character_data.dat",File.READ)
	char_dat = str2var(file.get_as_text())
	file.close()
	cards = get_all_cards_data()
func get_character_data():
	var dat = []
	for pos in player_characters.size():
		dat.append(char_dat[player_characters[pos]])
	return dat
func get_cards_data(card_ids):
	var dat = []
	var file = File.new()
	file.open("res://Data/card_data.dat",File.READ)
	var card_dat = str2var(file.get_as_text())
	for card in card_ids:
		dat.append(card_dat[card[0]][card[1]])
	return dat

func get_all_cards_data():
	var file = File.new()
	file.open("res://Data/card_data.dat",File.READ)
	var card_dat = str2var(file.get_as_text())
	return card_dat
var cur_map_data = []
var enemy_dat = []
func get_enemy_data(enemy_map=null,enemy_count=1):
	if enemy_map == null:enemy_map = cur_dungeon
	var dat = []
	for enemy in enemy_count:
		var enemy_id = round(rand_range(0.0,cur_map_data.size()-1))
		dat.append(enemy_dat[cur_map_data[enemy_id]])
	return dat
func load_enemy_data(enemy_map=0):
	var file = File.new()
	file.open("res://Data/level_dat.dat",File.READ)
	var data_map = str2var(file.get_as_text())[enemy_map]
	cur_map_data = []
	for enemy in data_map.keys():
		for enemy_count in data_map[enemy]:
			cur_map_data.append(enemy)
	file.close()
	file.open("res://Data/enemy_data.dat",File.READ)
	enemy_dat = str2var(file.get_as_text())
	file.close()
	
func calculate_damage_modifier(strength,defence,attribute,resistance,weakness):
	var modified_damage = (-int(attribute==resistance)*0.75)+(int(attribute==weakness)+1)
	return float(float(strength)/float(defence))*modified_damage
	
