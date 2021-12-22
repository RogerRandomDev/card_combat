extends Node


const menu_sfx = {"OPTION":"Menu/OPTION.wav"}

var volume_control = [0,0,0]

func do_menu_sfx(sfx_type):
	$menu_sfx.stream = load("res://Assets/Audio/"+menu_sfx[sfx_type])
	$menu_sfx.play()

func set_music(music_name):
	if get_node_or_null("music0") != null:
		get_node("music0").queue_free()
	var new_music = AudioStreamPlayer.new()
	new_music.volume_db = -40
	new_music.stream = load("res://Assets/Audio/music/"+music_name+".mp3")
	var volume_change_rate = abs((volume_control[0]-40)/40)
	$Tween.interpolate_property(new_music,"volume_db",-40,40-(abs((volume_change_rate*(volume_control[1])))+volume_change_rate*40),2.5,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($music,"volume_db",$music.volume_db,-40,2.5,Tween.TRANS_LINEAR)
	$Tween.start()
	$music.name = "music0"
	add_child(new_music)
	new_music.name = "music"
	new_music.play()
func set_volume(val,id):
	volume_control[id] = val
	var volume_change_rate = abs((volume_control[0]-40)/40)
	$music.volume_db = 40-(abs((volume_change_rate*(volume_control[1])))+volume_change_rate*40)
	$menu_sfx.volume_db = 40-(abs((volume_change_rate*(volume_control[2])))+volume_change_rate*40)
