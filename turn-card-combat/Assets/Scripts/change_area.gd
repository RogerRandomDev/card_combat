extends Area2D


export var next_zone:String

export var enter_point:int
export var enter_offset:Vector2
export var area_size:Vector2
export var outside:bool
export var scene_loader:NodePath
export var change_music:bool=false
export var music_name:String="town_song_0"
export var music_db_offset:int=0
func _on_area_changer_body_entered(body):
	if body.name != "World_Player" || !get_node(scene_loader).get_parent().can_load():return
	if change_music:
		GlobalData.offset_volume(music_db_offset,1)
		GlobalData.set_music(music_name)
	get_node(scene_loader).get_parent().load_new_scene(next_zone,enter_point,area_size,outside)
