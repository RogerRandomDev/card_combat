extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var max_cards = 3
export var card_scene:PackedScene
var selected_enemy = null
export var enemy_count = 3
export var enemy_scene:PackedScene
var hovering_ally = null
export var ally_count = 3
export var ally_scene:PackedScene
var active_ally = null
var active_card = false
var active_card_type = 0
var selected_card = null
var in_attack = false
var hovering_cards = false
export var round_count = 0
var cur_round = 0
var cur_turn = "Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Resources/Round.text = str(min(cur_round,round_count)+1)+"/"+str(round_count+1)
	$Resources/Energy.max_value = ally_count
	$Resources/Energy.value = ally_count
	randomize()
# warning-ignore:shadowed_variable
	var card_count = 0
	for card in max_cards:
		var n_card = card_scene.instance()
		n_card.card_type = card_count
		$Cards.add_child(n_card)
		card_count += 1
	for enemy in enemy_count:
		var en = enemy_scene.instance()
		$Interaction/Enemies.add_child(en)
	var char_dat = Simpli.get_character_data()
	for ally in char_dat.size():
		var n_ally = ally_scene.instance()
		$Interaction/Allies.add_child(n_ally)
		n_ally.set_stats(char_dat[ally])
	if Util.player_stats == []:
		for ally in char_dat.size():
			Util.player_stats.append($Interaction/Allies.get_child(ally).get_stats())
	get_parent().get_parent().get_node("Menu/Player_Menu").load_players(Util.player_stats)
	redo_foil()
	
# warning-ignore:unused_argument
func _process(delta):
	$Card_Effect.position = get_global_mouse_position()
func update_cards(active=false,color=Color(0,0,0,1.0)):
	$Card_Effect/Particles2D.color = color
	$Card_Effect/Particles2D.emitting = active


# warning-ignore:unused_argument
func _on_check_cards_timeout(disable_select = false):
	var al_select = false
	for card in $Cards.get_children():
		if card.get_child(0).rect_size.x > 95.9:
			if al_select:card.call_deferred('_on_Card_mouse_exited')
			al_select = true
	if $Cards.get_child(0) && $Cards.get_child(0).get_child(0).rect_size.x > 95 && al_select:
		$Cards.get_child(0).call_deferred('_on_Card_mouse_exited')

func update_enemy():
	if selected_enemy==null:return
	if selected_card==null:return
	var time = Timer.new()
	time.wait_time = 0.5
	add_child(time)
	time.connect("timeout",self,"hide_cards",[time])
	time.start()
	var output_val = selected_card.get_output_value()
	selected_enemy.hurt(output_val)
func disable_cards(energy = true):
	active_card = false
	selected_card = null
	var time = Timer.new()
	time.wait_time = 0.25
	add_child(time)
	time.connect("timeout",self,"hide_cards",[time])
	time.start()
	$Card_Effect/Particles2D.emitting = false
	if !energy:return
	var can_do_again = $Resources.add_energy(-1)
	if !can_do_again:
		cur_enemy = 0
		$Cards.hide()
		for ally in $Interaction/Allies.get_children():
			ally.get_node("Sprite/CPUParticles2D").emitting = false
		$Resources/cur_turn.text = "ENEMY'S TURN"
		cur_turn = "ENEMY"
		$Resources.set_energy(enemy_count)
		$attack_timer.start()
		
	
func return_cards_to_hand():
	for card in $Cards.get_children():
		card.selected = false
		card._on_Card_mouse_exited()
var cur_enemy = 0
func enemy_turns():
	
	var target_ally = round(rand_range(0,ally_count-1))
	var target_enemy = null
	if enemy_count == 0:
		new_round()
		return
	for enemy in $Interaction/Enemies.get_children():
		if enemy.get_hp() < enemy.get_max_hp()/rand_range(4.0,6.0):
			target_enemy = enemy;break
	$Tween.start()
	if $Interaction/Enemies.get_child_count() > cur_enemy:
		if $Interaction/Enemies.get_child(cur_enemy).get_hp() < $Interaction/Enemies.get_child(cur_enemy).get_max_hp()/rand_range(2.0,3.0) && rand_range(0.0,5.0) > 4.0:
			target_enemy = $Interaction/Enemies.get_child(cur_enemy)
	if enemy_count == 0:
		new_round()
		return
	if target_enemy != null:
		target_enemy.heal(round(rand_range(10.0,20.0)))
	elif $Interaction/Allies.get_child_count() > target_ally && $Interaction/Enemies.get_child_count() > cur_enemy:
		$Interaction/Allies.get_child(target_ally).hurt(-round(rand_range(10.0,20.0)))
		$Tween.interpolate_property($Interaction/Enemies.get_child(cur_enemy).get_child(0),"rect_position",$Interaction/Enemies.get_child(cur_enemy).get_child(0).rect_position,Vector2(16,0),0.25,Tween.TRANS_LINEAR)
		$Tween.start()
# warning-ignore:return_value_discarded
		$Tween.connect("tween_all_completed",self,"reverse_anim",[cur_enemy])
	var continued = $Resources.add_energy(-1)
	if !continued:
		$Resources/cur_turn.text = "YOUR TURN"
		cur_turn = "PLAYER"
		$Resources.set_energy(ally_count)
		redo_foil()
		new_turn()
	else:
		$attack_timer.start()
	cur_enemy += 1
func reverse_anim(enemy_id):
	$Tween.interpolate_property($Interaction/Enemies.get_child(enemy_id).get_child(0),"rect_position",$Interaction/Enemies.get_child(enemy_id).get_child(0).rect_position,Vector2(0,0),0.25,Tween.TRANS_LINEAR)
	$Tween.start()
	$Tween.disconnect("tween_all_completed",self,"reverse_anim")
func _on_attack_timer_timeout():
	enemy_turns()
func _input(_event):
	if $attack_timer.time_left != 0.0:return
	if Input.is_action_just_pressed("Lm") && selected_card != null:
		var modifiers = {"BUFFS":[],"STATS":[]}
		if active_ally == null:
			return_cards_to_hand()
			hide_cards(null)
			return
		else:
			modifiers = active_ally.get_modifiers()
		var succeeded = Card.add_action(selected_card.card_action,selected_card.card_delay,active_ally,selected_enemy,hovering_ally,active_card_type,selected_card.foiled,modifiers,selected_card)
		if succeeded&&active_ally!=null:
			active_ally.used = true
			ally_used()
			return_cards_to_hand()
			disable_cards()
			active_ally.reset_size()
			active_ally = null
			selected_card = null
			active_card_type = -1
func ally_used():
	if active_ally == null:return
	active_ally.used = true
	active_card_type = -1
	active_card = false
#func heal_ally():
#	var output_val = selected_card.get_output_value()
#	hovering_ally.heal(output_val)
#	active_ally.reset_size()
func redo_foil():
	for ally in $Interaction/Allies.get_children():
		ally.redo_foil()
func hide_cards(timer):
	if timer != null:timer.queue_free()
	
	$Cards.hide()
	if active_ally != null:
		if active_ally.used:
			active_ally.modulate = Color(0.5,0.5,0.5,1.0)
			active_ally.reset_size()
			active_ally = null
			hovering_ally = null
			selected_card = null
			active_card_type = -1
func new_round():
	$Resources/cur_turn.text = "YOUR TURN"
	$Resources.set_energy(ally_count)
	cur_round+=1
	$Resources/Round.text = str(min(cur_round,round_count)+1)+"/"+str(round_count+1)
	if cur_round <= round_count:
		load_enemies_for_round()
	else:
		$Resources/cur_turn.text = "VICTORY"
		var time = Timer.new()
		time.connect("timeout",self,'end_round',[time])
		Util.player_stats =[]
		for ally in $Interaction/Allies.get_children():
			Util.player_stats.append(ally.get_stats())
		get_parent().get_parent().get_node("Menu/Player_Menu").load_players(Util.player_stats)
		time.wait_time = 3
		add_child(time)
		time.start()
	redo_foil()
func update_card_foils(foiling):
	for card in $Cards.get_children():
		if foiling.size() > card.get_position_in_parent():
			card.redo_foil(foiling[card.get_position_in_parent()])
var card_count = 3
func new_turn():
	for ally in $Interaction/Allies.get_children():
		ally.shielded = false
		ally.action_chosen = false
		ally.used = false
		ally.buffed_stats = 1.0
		ally.shielded_amount = 1.0
		if ally.owned_cards.size() > 0:
			var possible_cards = []
# warning-ignore:unused_variable
			var count_cards = ally.owned_cards
			var ally_cards_this_turn = []
			var card_vals = ally.owned_cards.keys()
			var value_out = ally.owned_cards.values()
			for card in card_vals.size():
				for count in value_out[card]:
					possible_cards.append(card_vals[card])
			for point in card_count:
				var val = round(rand_range(0.0,possible_cards.size()-1))
				var card_type = possible_cards[val]
				possible_cards.remove(val)
				ally_cards_this_turn.append(card_type)
			ally.cards_this_turn = ally_cards_this_turn
	Card.turn_end()
func update_active_particles(type):
	if active_ally==null:return
	active_ally.get_node("Sprite/CPUParticles2D").process_material.color = Color(int(type==0),int(type==1),int(type==2),1.0)
	active_ally.get_node("Sprite/CPUParticles2D").emitting = true
func load_enemies_for_round():
	enemy_count = 3
	var enemies = Simpli.get_enemy_data(null,enemy_count)
	for enemy in enemies:
		var en = enemy_scene.instance()
		en.load_data(enemy)
		$Interaction/Enemies.add_child(en)
func check_enemies():
	enemy_count = min($Interaction/Enemies.get_child_count()-1,enemy_count)
	if enemy_count <= 0:
		new_turn()
# warning-ignore:standalone_expression
		$Interaction/Allies.mouse_filter = $Interaction/Allies.MOUSE_FILTER_STOP
		$Cards.hide()
		$win_screen.show()
		$Resources/cur_turn.text = "VICTORY"
		$attack_timer.start()
		$win_screen.set_deferred('visible',true)
		var time = Timer.new()
		time.wait_time = 3
		add_child(time)
		time.start()
		yield(time,"timeout")
		end_round(time)
func end_round(timer):
	$Interaction/Allies.hide()
	$Interaction/Enemies.hide()
	active_ally = null
	active_card = null
	hovering_ally = null
	selected_card = null
	active_card_type = -1
	if timer != null:timer.queue_free()
	hide()
	get_parent().get_parent().load_combat(false)


func load_new_round():
	var p_stats = Simpli.get_character_data()
	ally_count = 3
	for ally in $Interaction/Allies.get_children():
		ally.queue_free()
	$Interaction/Allies.show()
	$Interaction/Enemies.show()
	$win_screen.hide()
	$Resources/cur_turn.text = "YOUR TURN"
# warning-ignore:standalone_expression
	$Interaction/Allies.mouse_filter = $Interaction/Allies.MOUSE_FILTER_PASS
	enemy_count = 1
	var size = 3
	if Util.player_stats.size() != 0:
		size = Util.player_stats.size()
	for ally in size:
		var n_ally = ally_scene.instance()
		n_ally.set_stats(p_stats[ally])
		if Util.player_stats.size() != 0:
			n_ally.set_stats(Util.player_stats[ally])
		$Interaction/Allies.add_child(n_ally)
	ally_count = size
	$Resources.set_energy(ally_count)
	for enemy in $Interaction/Enemies.get_children():
		enemy.queue_free()
	load_enemies_for_round()
	redo_foil()
	call_deferred('new_turn')
func select_ally(selected_ally):
	for card in $Cards.get_children():
		card.queue_free()
# warning-ignore:unused_variable
	var possible_cards = selected_ally.owned_cards
# warning-ignore:unused_variable
	var ally_cards_this_turn = []
	for cards in 3:
		var card = card_scene.instance()
		card.card_type = selected_ally.cards_this_turn[cards]
		card.foiled = selected_ally.cards_foiled[cards]
		$Cards.call_deferred('add_child',card)
		
func killed_player():
	ally_count -= 1
	$Resources.set_energy(ally_count)
	if ally_count==0:
		lose_round()
func lose_round():
	pass
