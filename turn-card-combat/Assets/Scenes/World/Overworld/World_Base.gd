extends Node2D



const combat = preload("res://Assets/Scenes/Combat/combat_scene.tscn")
func _ready():
	$Combat.add_child(combat.instance())
	$Combat.get_child(0).hide()


func load_combat(visibility=true):
	if visibility:$Combat.get_child(0).load_new_round()
	for child in $World.get_children():
		child.set_process(!visibility)
		child.set_process_input(!visibility)
		child.set_process_internal(!visibility)
		child.set_process_unhandled_input(!visibility)
		child.set_process_unhandled_key_input(!visibility)

	$Combat.get_child(0).visible = visibility
