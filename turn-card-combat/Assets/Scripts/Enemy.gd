extends Control



var in_attack = false
const floaty_text = preload("res://Assets/Scenes/Combat/floaty_text.tscn")

var stats = [1,1,1,40]
var level = 5
var owned_cards = {}
var strength = 1
var defence = 1
var support = 1
var enemy_id = 0
var used=false
var action_chosen=false
func reset_size():return false
func get_hp():
	return $Sprite/Node2D/Health.value
func get_max_hp():
	return $Sprite/Node2D/Health.max_value
func _input(_event):
	if Input.is_action_just_pressed("Lm") && show_on_top:
		get_parent().get_parent().get_parent().selected_enemy = self
		get_parent().get_parent().get_parent().in_attack = true
# warning-ignore:unused_variable
		var origin = get_parent().get_parent().get_parent()

func _on_Enemy_mouse_entered():
	if !get_parent().get_parent().get_parent().active_card || get_parent().get_parent().get_parent().active_card_type != 0:return
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(1,1,1,1),0.125,Tween.TRANS_CUBIC)
	$Tween.start()
	get_parent().get_parent().get_parent().selected_enemy = self
	show_on_top = true


func _on_Enemy_mouse_exited():
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(0.75,0.75,0.75,1),0.125,Tween.TRANS_CUBIC)
	$Tween.start()
	show_on_top = false
	if get_parent().get_parent().get_parent().selected_enemy == self:
		get_parent().get_parent().get_parent().selected_enemy = null
func add_health(val,ally=null):
	update_health(val+$Sprite/Node2D/Health.value,ally)

func update_health(val,ally=null):
	$Sprite/Node2D/Health.value = max(min(val,$Sprite/Node2D/Health.max_value),0)
	if $Sprite/Node2D/Health.value == 0:
		if get_parent().get_parent().get_parent().selected_enemy == self:
			get_parent().get_parent().get_parent().selected_enemy = null
		get_parent().get_parent().get_parent().enemy_count -= 1
		if ally != null:
			get_parent().get_parent().get_parent().add_exp_to_allies(round(pow(level,2)))
		Util.update_achievement_progress("Kill","count",1)
		$AnimationPlayer.play("return_to_card")
		get_parent().get_parent().get_parent().check_enemies()
	update_hp_bar()
func hurt(damage,ally = null):
	if in_attack:return false
	$Tween.interpolate_property($Sprite,"rect_position",$Sprite.rect_position,Vector2(-16,0),0.25,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(1.0,0.25,0.25,1.0),0.25,Tween.TRANS_CUBIC)
# warning-ignore:return_value_discarded
	$Tween.connect("tween_all_completed",self,"finished_modulate",[damage,false,ally])
	$Tween.start()
	in_attack = true
	
	var floaty = floaty_text.instance()
	floaty.get_child(0).rect_global_position = self.rect_global_position+Vector2(16,16)
	get_parent().get_parent().add_child(floaty)
	if abs(damage) >= $Sprite/Node2D/Health.value:
		damage = -$Sprite/Node2D/Health.value
	floaty.get_child(0).start(1.75,str(damage))
	return true
func finished_modulate(damage,_healing = false,ally=null):
	$Tween.interpolate_property($Sprite,"rect_position",$Sprite.rect_position,Vector2(0,0),0.25,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(0.75,0.75,0.75,1.0),0.25,Tween.TRANS_CUBIC)
	$Tween.disconnect("tween_all_completed",self,"finished_modulate")
	$Tween.start()
	add_health(damage,ally)
	in_attack = false
	get_parent().get_parent().get_parent().in_attack = false
	
func deselect_cards():
	get_parent().get_parent().get_parent().disable_cards()
	for card in get_parent().get_parent().get_parent().get_node("Cards").get_children():
		card.selected = false
		card._on_Card_mouse_exited()
func heal(val):
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(0.25,1.0,0.25,1.0),0.25,Tween.TRANS_CUBIC)
# warning-ignore:return_value_discarded
	if !$Tween.is_connected("tween_all_completed",self,"finish_modulate"):
		$Tween.connect("tween_all_completed",self,"finished_modulate",[val,true])
	$Tween.start()
	var floaty = floaty_text.instance()
	floaty.get_child(0).rect_global_position = self.rect_global_position+Vector2(16,16)
	get_parent().get_parent().add_child(floaty)
	if val >= $Sprite/Node2D/Health.max_value-$Sprite/Node2D/Health.value:
		val = $Sprite/Node2D/Health.max_value-$Sprite/Node2D/Health.value
	floaty.get_child(0).start(1.75,str(val),true)
func load_data(data):
	$Sprite.texture = load(data["Icon"])
	$Sprite/Node2D/Health.max_value = data["Stats"][3]
	$Sprite/Node2D/Health.value = data["Stats"][3]
	owned_cards = data["Cards"]
	stats = data['Stats']
	strength = stats[2]
	defence=stats[0]
	support = stats[1]
	var Name = data["Name"]
	if typeof(Name) == typeof([]):
		$Sprite/Node2D/Name.text = data["Name"][round(rand_range(0.0,data["Name"].size()-1))]
	else:$Sprite/Node2D/Name.text = data["Name"]
	$TextureRect/Label.text = $Sprite/Node2D/Name.text
	update_hp_bar()
func update_hp_bar():
	$Sprite/Node2D/Health/HP_VAL.text = str(get_hp())+"/"+str(get_max_hp())
func can_heal():
	return owned_cards.keys().has("heal")
func can_attack():
	return owned_cards.keys().has('attack')
func can_interact():
	return !$AnimationPlayer.is_playing()
