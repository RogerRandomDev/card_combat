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
# Called when the node enters the scene tree for the first time.
func _ready():
	$Resources/Energy.max_value = ally_count
	$Resources/Energy.value = ally_count
	randomize()
	var card_count = 0
	for card in max_cards:
		var n_card = card_scene.instance()
		n_card.card_type = card_count
		$Cards.add_child(n_card)
		card_count += 1
	for enemy in enemy_count:
		var en = enemy_scene.instance()
		$Interaction/Enemies.add_child(en)
	for ally in ally_count:
		var n_ally = ally_scene.instance()
		$Interaction/Allies.add_child(n_ally)
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
		$Resources/cur_turn.text = "ENEMY'S TURN"
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
	for enemy in $Interaction/Enemies.get_children():
		if enemy.get_hp() < enemy.get_max_hp()/rand_range(2.5,5.0):
			target_enemy = enemy;break
	$Tween.start()
	if enemy_count == 0:
		new_round()
		return
	if $Interaction/Enemies.get_child(cur_enemy).get_hp() < $Interaction/Enemies.get_child(cur_enemy).get_max_hp()/rand_range(1.0,2.0) && rand_range(0.0,5.0) > 4.0:
		target_enemy = $Interaction/Enemies.get_child(cur_enemy)
	
	if target_enemy != null:
		target_enemy.heal(round(rand_range(10.0,20.0)))
	else:
		$Interaction/Allies.get_child(target_ally).hurt(-round(rand_range(10.0,20.0)))
		$Tween.interpolate_property($Interaction/Enemies.get_child(cur_enemy).get_child(0),"rect_position",$Interaction/Enemies.get_child(cur_enemy).get_child(0).rect_position,Vector2(16,0),0.25,Tween.TRANS_LINEAR)
		$Tween.start()
# warning-ignore:return_value_discarded
		$Tween.connect("tween_all_completed",self,"reverse_anim",[cur_enemy])
	var continued = $Resources.add_energy(-1)
	if !continued:
		$Resources/cur_turn.text = "YOUR TURN"
		$Resources.set_energy(ally_count)
		redo_foil()
		call_deferred('new_turn')
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
	if selected_card == null || !Input.is_action_just_pressed("Lm"):return
	if selected_card.card_type == 1 && hovering_ally != null:
		heal_ally()
		ally_used()
		disable_cards()
		return_cards_to_hand()
		return
	if selected_card.card_type == 2 && hovering_ally == active_ally && active_ally != null:
		active_ally.shield(selected_card.material != null)
		ally_used()
		disable_cards()
		return_cards_to_hand()
		return

func ally_used():
	for ally in $Interaction/Allies.get_children():
		if ally.show_on_top:
			ally.action_chosen = true;break
func heal_ally():
	var output_val = selected_card.get_output_value()
	hovering_ally.heal(output_val)
func redo_foil():
	for ally in $Interaction/Allies.get_children():
		ally.redo_foil()
func hide_cards(timer):
	if timer != null:timer.queue_free()
	
	$Cards.hide()
	if active_ally != null:
		active_ally.modulate = Color(0.5,0.5,0.5,1.0)
		active_ally.used = true
		active_ally.reset_size()
		active_ally = null
func new_round():
	$Resources/cur_turn.text = "YOUR TURN"
	$Resources.set_energy(ally_count)
	redo_foil()
func update_card_foils(foiling):
	for card in $Cards.get_children():
		card.redo_foil(foiling[card.get_position_in_parent()])
func new_turn():
	for ally in $Interaction/Allies.get_children():
		ally.shielded = false
		ally.shielded_amount = 1.0
