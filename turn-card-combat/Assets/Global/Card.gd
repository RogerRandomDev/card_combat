extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


const card_type = ["Attack","Shield","Heal"]



func get_card_method(card_id):
	return card_type[card_id]
