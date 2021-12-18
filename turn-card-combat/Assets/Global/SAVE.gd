extends Node







func _ready():
	load_game()

func load_game():
	var stored_data = []
	var file = File.new()
	if !file.file_exists("user://TCB_SAVE.dat"):return
	file.open("user://TCB_SAVE.dat",File.READ)
	stored_data = str2var(file.get_as_text())
	Util.player_stats = stored_data[0]
	Util.unconsious_players = stored_data[1]
	Util.achievement_actions = stored_data[2]
	Util.complete_achievments = stored_data[3]
	Util.stored_items = stored_data[4]
	Util.dont_speak_again = stored_data[5]
	file.close()
	Dialogic.load('dialogue')
func save_game():
	var save_data = []
	save_data.append(Util.player_stats)
	save_data.append(Util.unconsious_players)
	save_data.append(Util.achievement_actions)
	save_data.append(Util.complete_achievments)
	save_data.append(Util.stored_items)
	save_data.append(Util.dont_speak_again)
	var file = File.new()
	file.open("user://TCB_SAVE.dat",File.WRITE)
	file.store_line(var2str(save_data))
	file.close()
	Dialogic.save('dialogue')
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_game()
