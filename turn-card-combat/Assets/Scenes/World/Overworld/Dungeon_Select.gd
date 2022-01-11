extends Button



var starting_pos = Vector2.ZERO
export var dungeon_id:int=0
export var required_to_open = 0
export var invis_if_not_open:bool=false
func _ready():
	starting_pos = rect_global_position
	$dungeon_name.text = GlobalData.grab_dungeon_names(dungeon_id).replace("_"," ")
	if required_to_open != -1:
		if !Util.complete_dungeons.has(required_to_open):
			disabled = true
			if invis_if_not_open:hide()


func _on_selector_mouse_entered():
	$Tween.interpolate_property(self,'rect_scale',rect_scale,Vector2(1.5,1.5),0.25,Tween.TRANS_CUBIC)
	$Tween.interpolate_property(self,"rect_global_position",rect_global_position,starting_pos-Vector2(4,4),0.25,Tween.TRANS_CUBIC)
	$Tween.start()
	$dungeon_name.show()
func _on_selector_mouse_exited():
	$Tween.interpolate_property(self,'rect_scale',rect_scale,Vector2.ONE,0.25,Tween.TRANS_CUBIC)
	$Tween.interpolate_property(self,"rect_global_position",rect_global_position,starting_pos,0.25,Tween.TRANS_CUBIC)
	$Tween.start()
	$dungeon_name.hide()


func _on_selector_pressed():
	get_parent().get_parent().selected_dungeon(dungeon_id)
