extends Node2D



func _ready():
	load_new_scene("scene_house_0",0,Vector2(20.125,12))

func load_new_scene(scene,enter_point,area):
	$AnimationPlayer.play("new_scene_loader")
	area_size = area
	scene_name = scene
	scene_enter_point = enter_point
	$World_Player.can_move = false
	
var area_size = Vector2.ZERO
var scene_name = ""
var scene_enter_point = 0
func load_next_scene():
	for node in get_tree().get_nodes_in_group("game_maps"):
		node.queue_free()
		
	area_size *= 16
	var new_scene = load("res://Assets/Scenes/World/Overworld/main_land/map_scenes/"+scene_name+".tscn").instance()
	var enter_point = new_scene.get_node("Interactions").get_child(scene_enter_point)
	call_deferred('add_child',new_scene)
	new_scene.set_deferred('name',"game_map")
	new_scene.add_to_group("game_maps")
	$World_Player.position = enter_point.position+enter_point.enter_offset
	$World_Player.set_camera_limits(Vector2.ZERO,area_size)
func enable_motion():$World_Player.can_move = true


func load_shop():
	$shop.toggle_shop()
