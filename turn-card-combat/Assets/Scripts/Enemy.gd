extends Control



var in_attack = false
const floaty_text = preload("res://Assets/Scenes/floaty_text.tscn")


func get_hp():
	return $Sprite/Node2D/Health.value
func get_max_hp():
	return $Sprite/Node2D/Health.max_value
func _input(_event):
	if Input.is_action_just_pressed("Lm") && show_on_top:
		
		get_parent().get_parent().get_parent().selected_enemy = self
		get_parent().get_parent().get_parent().update_enemy()
		get_parent().get_parent().get_parent().in_attack = true
		get_parent().get_parent().get_parent().ally_used()

func _on_Enemy_mouse_entered():
	if !get_parent().get_parent().get_parent().active_card || get_parent().get_parent().get_parent().active_card_type != 0:return
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(1,1,1,1),0.125,Tween.TRANS_CUBIC)
	$Tween.start()
	show_on_top = true


func _on_Enemy_mouse_exited():
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(0.75,0.75,0.75,1),0.125,Tween.TRANS_CUBIC)
	$Tween.start()
	show_on_top = false
func add_health(val):
	update_health(val+$Sprite/Node2D/Health.value)

func update_health(val):
	$Sprite/Node2D/Health.value = max(min(val,$Sprite/Node2D/Health.max_value),0)
	if $Sprite/Node2D/Health.value == 0:
		if get_parent().get_parent().get_parent().selected_enemy == self:
			get_parent().get_parent().get_parent().selected_enemy = null
			get_parent().get_parent().get_parent().enemy_count -= 1
		self.queue_free()
func hurt(damage):
	if in_attack:return false
	$Tween.interpolate_property($Sprite,"rect_position",$Sprite.rect_position,Vector2(-16,0),0.25,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(1.0,0.25,0.25,1.0),0.25,Tween.TRANS_CUBIC)
# warning-ignore:return_value_discarded
	$Tween.connect("tween_all_completed",self,"finished_modulate",[damage])
	$Tween.start()
	in_attack = true
	var floaty = floaty_text.instance()
	floaty.get_child(0).rect_global_position = self.rect_global_position+Vector2(16,16)
	get_parent().get_parent().add_child(floaty)
	floaty.get_child(0).start(1.75,str(damage))
	return true
func finished_modulate(damage,healing = false):
	$Tween.interpolate_property($Sprite,"rect_position",$Sprite.rect_position,Vector2(0,0),0.25,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(0.75,0.75,0.75,1.0),0.25,Tween.TRANS_CUBIC)
	$Tween.disconnect("tween_all_completed",self,"finished_modulate")
	$Tween.start()
	add_health(damage)
	if !healing:
		deselect_cards()
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
	$Tween.connect("tween_all_completed",self,"finished_modulate",[val,true])
	$Tween.start()
	var floaty = floaty_text.instance()
	floaty.get_child(0).rect_global_position = self.rect_global_position+Vector2(16,16)
	get_parent().get_parent().add_child(floaty)
	floaty.get_child(0).start(1.75,str(val),true)
