extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var player_menu_scene:PackedScene


	
func load_players(player_data):
	for player in $TabContainer/Characters/VBoxContainer.get_children():
		player.queue_free()
	for player in player_data:
		var icon = player_menu_scene.instance()
		$TabContainer/Characters/VBoxContainer.add_child(icon)
		icon.set_data(player)
