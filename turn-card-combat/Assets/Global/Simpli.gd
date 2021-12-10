extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player_characters = [0,0,0]



func in_range_Vector2(position,start,end):
	return (
		position.x>=start.x &&
		position.y>=start.y &&
		position.x<=end.x &&
		position.y<=end.y
	)


func get_character_data():
	var file = File.new()
	var dat = []
	file.open("res://Data/character_data.dat",File.READ)
	var char_dat = str2var(file.get_as_text())
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
