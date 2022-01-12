extends Node2D



const combat = preload("res://Assets/Scenes/Combat/combat_scene.tscn")
export var player_menu:PackedScene

var dungeon_data = {}
func _ready():
	if GlobalData.cur_dungeon == "Level_0":GlobalData.cur_dungeon = "Slime_Haven"
	dungeon_data = GlobalData.get_dungeon_data()
	GlobalData.offset_volume(int(dungeon_data["level_song"][1]),1)
	GlobalData.set_music(dungeon_data["level_song"][0])
	if Util.last_scene !="Dungeon":
		Util.cur_layer = 0
	Util.last_scene = "Dungeon"
	$Menu.add_child(player_menu.instance())
	$Combat.add_child(combat.instance())
	$Combat.get_child(0).hide()
	Simpli.load_enemy_data(0)
	var file = File.new()
	if file.file_exists("res://Assets/Textures/"+dungeon_data["level_tileset"]+".tres"):
		$Map/Map.tile_set = load("res://Assets/Textures/"+dungeon_data["level_tileset"]+".tres")
	$Map/Map.ready()
	var stair_menu = load("res://Assets/Scenes/World/dungeon_stairs.tscn").instance()
	$stair_options.add_child(stair_menu)
	stair_menu.hide()
	for ally in Util.player_stats:
		ally[2] = ally[10][2]*(ally[8]-1)+ally[11][2]
		ally[1] = ally[10][1]*(ally[8]-1)+ally[11][1]
		ally[0] = ally[10][0]*(ally[8]-1)+ally[11][0]
		ally[4] = ally[10][3]*(ally[8]-1)+ally[11][3]
		ally[3] = ally[4]
	$World/Player.ready()
	$World/Player.load_followers()

func load_combat(visibility=true):
	GlobalData.do_controller_updates = visibility
	if visibility:$Combat.get_child(0).load_new_round()
	get_tree().paused = visibility
	$AnimationPlayer.play("Load_Combat",-1,(int(visibility)*2-1.0),!visibility)
	if !visibility:
		$Combat.get_child(0).get_node("win_screen").visible = true
		for ally in Util.player_stats:
			ally[2] = ally[10][2]*(ally[8]-1)+ally[11][2]
			ally[1] = ally[10][1]*(ally[8]-1)+ally[11][1]
			ally[0] = ally[10][0]*(ally[8]-1)+ally[11][0]
			ally[4] = ally[10][3]*(ally[8]-1)+ally[11][3]
	$World/Player.load_followers()
func combat_visible(visibility):
	$Combat.get_child(0).visible = visibility
	$Menu.get_child(0).visible = !visibility
	if !visibility:
		var combat = $Combat.get_child(0)
		combat.selected_card = null
		combat.active_card = false
		combat.active_card_type = "AAAAA"
		combat.return_cards_to_hand()
		
func activate_blocker(do):
	if do:
		$Combat.get_child(0).get_node("Cards").visible = !do
	$Combat.get_child(0).get_node("Interaction").visible = !do
	$Combat.get_child(0).get_node("win_screen").visible = !do
func stairs_entered(body):
	if body.name != "Player":return
	get_tree().paused = true
	$stair_options.get_child(0).show()
	
	
func next_floor():
	Util.cur_layer += 1
	get_tree().paused = false
	$stair_options.get_child(0).hide()
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

func return_to_home():
	get_tree().paused = false
	$stair_options.get_child(0).hide()
	if Util.cur_layer >= 10:
		
		Util.complete_dungeons.append(GlobalData.cur_dungeon)
	get_tree().change_scene("res://Assets/Scenes/World/Overworld/main_land/World.tscn")
