extends Area2D


export var next_zone:String

export var enter_point:int
export var enter_offset:Vector2
export var area_size:Vector2
export var outside:bool
export var scene_loader:NodePath
func _on_area_changer_body_entered(body):
	if body.name != "World_Player" || !get_node(scene_loader).get_parent().can_load():return
	get_node(scene_loader).get_parent().load_new_scene(next_zone,enter_point,area_size,outside)
