extends Control



func _ready():
	pass # Replace with function body.
func selected_dungeon(id:int=0):
	for selected in $Dungeons.get_children():
		if selected.dungeon_id != id:continue
		GlobalData.cur_dungeon = selected.get_name().replace(" ","_")
		Util.cur_layer = 0
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Assets/Scenes/World/Overworld/World_Base.tscn")
		break

func _input(_event):
	if Input.is_action_just_pressed("exit") && visible:
		GlobalData.set_mouse(false)
		get_parent().get_parent().disable_map()
