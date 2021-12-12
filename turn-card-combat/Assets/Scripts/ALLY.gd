extends Control


const floaty_text = preload("res://Assets/Scenes/Combat/floaty_text.tscn")

var max_health = 100
var health = 100

var strength = 1
var defence = 1
var support = 1

var owned_cards = {}
var cards_this_turn = []

var shielded = false
var shielded_amount = 0.0
var buffed_stats = 1.0


var used = false

var action_chosen = false

var cards_foiled = [false,false,false]

var level = 1
var experience = 0

var Name = "Dave"
func _ready():
	process_priority = 0
	$Health.max_value = max_health
	$Health.value = max_health
	update_health_bar()
	show_on_top = false
	$Sprite/CPUParticles2D.process_material = $Sprite/CPUParticles2D.process_material.duplicate()

func hurt(val):
	val = round(val*get_shielded_rate())
	$Tween.interpolate_property($Sprite,"rect_position",$Sprite.rect_position,Vector2(16,0),0.25,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(1.0,0.5,0.5,1.0),0.25,Tween.TRANS_LINEAR)
	$Tween.start()
# warning-ignore:return_value_discarded
	$Tween.connect("tween_all_completed",self,"hurt_finish",[$Health.value+val])
	var floaty = floaty_text.instance()
	floaty.get_child(0).rect_global_position = self.rect_global_position+Vector2(16,16)
	get_parent().get_parent().add_child(floaty)
	floaty.get_child(0).start(1.75,str(val))
func hurt_finish(val):
	if !get_parent().get_parent().get_parent().active_ally == self || !get_parent().get_parent().get_parent().hovering_ally != self || get_parent().get_parent().get_parent().cur_turn != "Player":
		$Tween.interpolate_property($Sprite,"rect_position",$Sprite.rect_position,Vector2(0,0),0.25,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(1.0,1.0,1.0,1.0),0.25,Tween.TRANS_LINEAR)
	$Tween.start()
	$Tween.disconnect("tween_all_completed",self,"hurt_finish")
	$Health.value = max(min(max_health,val),0)
	health = max(min(val,max_health),0)
	update_health_bar()
	if val <= 0:
		get_parent().get_parent().get_parent().killed_player()
		Util.unconsious_players.append(Util.player_stats[self.get_position_in_parent()-1])
		Util.player_stats.remove(self.get_position_in_parent()-1)
		self.queue_free()
func heal(val):
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(0.5,1.0,0.5,1.0),0.25,Tween.TRANS_LINEAR)
	$Tween.start()
# warning-ignore:return_value_discarded
	if !$Tween.is_connected("tween_all_completed",self,"hurt_finish"):
		$Tween.connect("tween_all_completed",self,"hurt_finish",[$Health.value+val])
	var floaty = floaty_text.instance()
	floaty.get_child(0).rect_global_position = self.rect_global_position+Vector2(16,16)
	get_parent().get_parent().add_child(floaty)
	floaty.get_child(0).start(1.75,str(val),true)


func _on_ALLY_mouse_entered():
	get_parent().get_parent().get_parent().hovering_ally = self
	if action_chosen:return
	show_on_top = true


func _on_ALLY_mouse_exited():
	if get_parent().get_parent().get_parent().hovering_ally == self:get_parent().get_parent().get_parent().hovering_ally = null
	show_on_top = false
	


func _input(_event):
	if used || get_global_mouse_position().x < 728:return
	var origin_point = get_parent().get_parent().get_parent()
	if Input.is_action_pressed("Lm") && !get_parent().get_parent().get_parent().hovering_ally == self:
		reset_size()
		get_parent().get_parent().get_parent().return_cards_to_hand()
		if !used:get_node("Sprite/CPUParticles2D").emitting = false
		if !Card.team_cards.has(get_parent().get_parent().get_parent().active_card_type) || Card.self_cards.has(get_parent().get_parent().get_parent().active_card_type) && get_parent().get_parent().get_parent().active_ally == get_parent().get_parent().get_parent().hovering_ally:
			if get_parent().get_parent().get_parent().hovering_ally == null || get_parent().get_parent().get_parent().hovering_ally.used:
				get_parent().get_parent().get_parent().active_ally = null
				origin_point.selected_card = null
				origin_point.active_card = false
				origin_point.active_card_type = -1
				get_parent().get_parent().get_parent().return_cards_to_hand()
				var time = Timer.new()
				time.wait_time = 0.25*(int(get_parent().get_parent().get_parent().selected_card != null)+int(!get_parent().get_parent().get_parent().get_node("Cards").visible)+0.01)
				add_child(time)
				time.name = "a"
				time.connect("timeout",self,"hide_cards",[time])
				time.start()
				origin_point.active_card_type = -1
				origin_point.selected_card = null
				origin_point.active_card = false
			else:
				swap()
		else:
			call_deferred('reset_size')
		get_parent().get_parent().get_parent().get_node("Card_Effect/Particles2D").emitting = false
	if Input.is_action_just_pressed("Lm") && show_on_top && !used && !Card.team_cards.has(get_parent().get_parent().get_parent().active_card_type) && origin_point.active_ally != self:
		get_parent().get_parent().get_parent().get_node("Cards").show()
		get_parent().get_parent().get_parent().active_ally = self
		get_parent().get_parent().get_parent().call_deferred('select_ally',self)
		origin_point.selected_card = null
		origin_point.active_card_type = -1
		$Tween.interpolate_property($Sprite,"rect_scale",$Sprite.rect_scale,Vector2(1.5,1.5),0.125,Tween.TRANS_LINEAR)
		$Tween.interpolate_property($Sprite,"rect_position",$Sprite.rect_position,Vector2(-16,-16),0.125,Tween.TRANS_LINEAR)
		$Tween.start()
		get_parent().get_parent().get_parent().update_card_foils(cards_foiled)
			
	if Input.is_action_just_pressed("Rm") && !used && get_parent().get_parent().get_parent().get_node("Cards").visible:
		pass
func swap():
		reset_size()
		get_parent().get_parent().get_parent().return_cards_to_hand()
		if get_parent().get_parent().get_parent().hovering_ally != null:get_parent().get_parent().get_parent().hovering_ally.show_on_top = true
		if Card.team_cards.has(get_parent().get_parent().get_parent().active_card_type):
			
			get_parent().get_parent().get_parent().selected_card = null
			get_parent().get_parent().get_parent().active_ally = get_parent().get_parent().get_parent().hovering_ally
			if get_parent().get_parent().get_parent().active_ally != null:
				get_parent().get_parent().get_parent().active_ally.select_self()



func redo_foil():
	used = false
	modulate = Color(1.0,1.0,1.0,1.0)
	for card in cards_foiled.size():
		cards_foiled[card] = rand_range(0.0,1.0) > 0.75


func reset_size(do_timer = false):
	$Tween.interpolate_property($Sprite,"rect_scale",$Sprite.rect_scale,Vector2(1,1),0.125,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Sprite,"rect_position",$Sprite.rect_position,Vector2(0,0),0.125,Tween.TRANS_LINEAR)
	$Tween.start()
	if do_timer:
		var time = Timer.new()
		time.wait_time = 0.25*(int(get_parent().get_parent().get_parent().selected_card != null)+int(!get_parent().get_parent().get_parent().get_node("Cards").visible)+0.01)
		add_child(time)
		time.name = "a"
		time.connect("timeout",self,"hide_cards",[time])
		time.start()
func hide_cards(timer):
	timer.queue_free()
	if get_parent().get_parent().get_parent().active_ally != null && get_parent().get_parent().get_parent().hovering_ally != null:return
	get_parent().get_parent().get_parent().get_node("Cards").hide()
	get_parent().get_parent().get_parent().selected_card = null
func shield(immune):
	shielded = true
	shielded_amount = int(!immune)
func get_shielded_rate():
	if shielded:
		return rand_range(0.05,0.6)*(shielded_amount*buffed_stats)
	return buffed_stats
func select_self():
	get_parent().get_parent().get_parent().get_node("Cards").show()
	if get_parent().get_parent().get_parent().active_ally != self:
		get_parent().get_parent().get_parent().selected_card = null
	get_parent().get_parent().get_parent().active_ally = self
	get_parent().get_parent().get_parent().select_ally(self)
	$Tween.interpolate_property($Sprite,"rect_scale",$Sprite.rect_scale,Vector2(1.5,1.5),0.125,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Sprite,"rect_position",$Sprite.rect_position,Vector2(-16,-16),0.125,Tween.TRANS_LINEAR)
	$Tween.start()
	get_parent().get_parent().get_parent().update_card_foils(cards_foiled)
var sprite_tex = ""
func set_stats(stats):
	if typeof(stats) == typeof([]):
		sprite_tex = stats[6]
		Name = stats[5]
		max_health = stats[4]
		health = stats[3]
		defence = stats[2]
		support = stats[1]
		strength = stats[0]
		$Health.max_value = stats[4]
		$Health.value = stats[3]
		level = stats[8]
		experience = stats[7]
	else:
		owned_cards = stats["Cards"]
		max_health = stats["Health"]
		health = stats["Health"]
		defence = stats["Defense"]
		Name = stats["Name"]
		sprite_tex = stats["Icon"]
		$Health.max_value = max_health
	$Health.set_deferred('value',health)
	$Sprite/Name.text = Name
	update_health_bar()
	$Sprite.texture = load(sprite_tex)
	if experience < pow(level+2,3):
		experience = pow(level+2,3)
	update_experience()
func get_cards():
	return [owned_cards.keys(),owned_cards.values()]
func get_stats():
	return [strength,support,defence,health,max_health,Name,sprite_tex,experience,level,[buffed_stats]]
func update_health_bar():
	$Health/HP_VAL.text = str(health)+"/"+str(max_health)
func update_experience():
	$Experience.max_value = pow(level+3,3)
	$Experience.min_value = pow(level+2,3)
	$Experience.value = experience
	$Experience/EXP_VAL.text = "Level:"+str(level)
func get_modifiers():
	return {"BUFFS":buffed_stats,"STATS":[strength,defence,support]}
func add_exp(val):
	var timer = Timer.new()
	timer.wait_time = 1/val
	timer.one_shot = true
	add_child(timer)
	for i in val:
		timer.start()
		yield(timer,"timeout")
		experience+=1
		$Experience.value = experience
		$Experience/EXP_VAL.text = "Level:"+str(level)
		if experience >= $Experience.max_value:
			timer.wait_time = 1.0
			timer.start()
			yield(timer,"timeout")
			timer.wait_time = 1/val
			level+=1
			update_experience()
	timer.queue_free()
