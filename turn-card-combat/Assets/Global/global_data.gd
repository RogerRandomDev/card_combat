extends Node


const menu_sfx = {"OPTION":"Menu/OPTION.wav"}


func do_menu_sfx(sfx_type):
	$menu_sfx.stream = load("res://Assets/Audio/"+menu_sfx[sfx_type])
	$menu_sfx.play()

func set_music(music_name):
	if get_node_or_null("music0") != null:
		get_node("music0").queue_free()
	var new_music = AudioStreamPlayer.new()
	new_music.volume_db = -40
	new_music.stream = load("res://Assets/Audio/music/"+music_name+".mp3")
	$Tween.interpolate_property(new_music,"volume_db",-40,-15,2.5,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($music,"volume_db",$music.volume_db,-40,2.5,Tween.TRANS_LINEAR)
	$Tween.start()
	$music.name = "music0"
	add_child(new_music)
	new_music.name = "music"
	new_music.play()
