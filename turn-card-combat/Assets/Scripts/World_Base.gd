extends Node2D



const combat = preload("res://Assets/Scenes/Combat/combat_scene.tscn")
export var player_menu:PackedScene

var dungeon_data = {}
func _ready():
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
	for ally in Util.player_stats:
		ally[2] = ally[10][2]*(ally[8]-1)+ally[11][2]
		ally[1] = ally[10][1]*(ally[8]-1)+ally[11][1]
		ally[0] = ally[10][0]*(ally[8]-1)+ally[11][0]
		ally[4] = ally[10][3]*(ally[8]-1)+ally[11][3]
		ally[3] = ally[4]
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
	Util.cur_layer += 1
