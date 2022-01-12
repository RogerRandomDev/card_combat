extends Node


const menu_sfx = {"OPTION":"Menu/OPTION.wav"}

var volume_control = [0,0,0]
var volume_offset = [0,0,0]
export var cur_dungeon = "Level_0"
var using_controller = true
var do_controller_updates=true
var dungeon_names = []
func _ready():
	using_controller = ProjectSettings.get_setting("global/controller in use")
	if using_controller:Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var file = File.new()
	file.open("res://Data/level_dat.dat",File.READ)
	var base = str2var(file.get_as_text())
	dungeon_names = base
	file.close()

func do_menu_sfx(sfx_type):
	$menu_sfx.stream = load("res://Assets/Audio/"+menu_sfx[sfx_type])
	$menu_sfx.play()

func set_music(music_name):
	if get_node_or_null("music0") != null:
		get_node("music0").queue_free()
	var new_music = AudioStreamPlayer.new()
	new_music.volume_db = -40
	new_music.stream = load("res://Assets/Audio/music/"+music_name+".mp3")
	var volume_change_rate = abs(((volume_control[0]+volume_offset[0])-40)/40)
	$Tween.interpolate_property(new_music,"volume_db",-40,40-(abs((volume_change_rate*(volume_control[1]+volume_offset[1])))+volume_change_rate*40),2.5,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($music,"volume_db",$music.volume_db,-40,2.5,Tween.TRANS_LINEAR)
	$Tween.start()
	$music.name = "music0"
	add_child(new_music)
	new_music.name = "music"
	new_music.play()
func set_volume(val,id):
	volume_control[id] = val
	var volume_change_rate = abs(((volume_control[0]+volume_offset[0])-40)/40)
	$music.volume_db = 40-(abs((volume_change_rate*(volume_control[1]+volume_offset[1])))+volume_change_rate*40)
	$menu_sfx.volume_db = 40-(abs((volume_change_rate*(volume_control[2]+volume_offset[0])))+volume_change_rate*40)

func grab_dungeon_names(dungeon_id:int=0):
	return dungeon_names[dungeon_id]["Name"]
func get_dungeon_data(dungeon_name=cur_dungeon):
	for level in dungeon_names:
		if level["Name"]==dungeon_name:
			return level
func offset_volume(volume,id):
	volume_offset[id] = volume
	
