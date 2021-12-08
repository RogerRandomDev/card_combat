extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


const card_type = ["Attack","Heal","Defend"]
const team_cards = [1]
const self_cards = [2]


func get_card_data(card_id):
	var file = File.new()
	file.open("res://Data/card_data.dat",File.READ)
	var card_data = str2var(file.get_as_text())
	if !card_type.has(card_id):
		return card_data[card_type[card_id]]
	return card_type[card_id]
