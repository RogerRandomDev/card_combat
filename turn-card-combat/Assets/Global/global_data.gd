extends Node


const menu_sfx = {"OPTION":"Menu/OPTION.wav"}


func do_menu_sfx(sfx_type):
	$menu_sfx.stream = load("res://Assets/Audio/"+menu_sfx[sfx_type])
	$menu_sfx.play()

func set_music(music_name):
	$music.stream = load("res://Assets/Audio/music/"+music_name+".mp3")
	$music.play()
