extends Control


const floaty_text = preload("res://Assets/Scenes/Combat/floaty_text.tscn")

var max_health = 100
var health = 100

var strength = 1
var defence = 1
var support = 1


var shielded = false
var shielded_amount = 0.0

var used = false

var action_chosen = false

var cards_foiled = [false,false,false]

func _ready():
	$Health.max_value = max_health
	$Health.value = max_health
	show_on_top = false

func hurt(val):
	val = round(val*get_shielded_rate())
	if cards_foiled[2] && shielded:val = 0.0
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
	$Tween.interpolate_property($Sprite,"rect_position",$Sprite.rect_position,Vector2(0,0),0.25,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(1.0,1.0,1.0,1.0),0.25,Tween.TRANS_LINEAR)
	$Tween.start()
	$Tween.disconnect("tween_all_completed",self,"hurt_finish")
	$Health.value = max(min(max_health,val),0)
	if val <= 0:
		get_parent().get_parent().get_parent().ally_count -= 1
		self.queue_free()
func heal(val):
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(0.5,1.0,0.5,1.0),0.25,Tween.TRANS_LINEAR)
	$Tween.start()
# warning-ignore:return_value_discarded
	$Tween.connect("tween_all_completed",self,"hurt_finish",[$Health.value+val])
	var floaty = floaty_text.instance()
	floaty.get_child(0).rect_global_position = self.rect_global_position+Vector2(16,16)
	get_parent().get_parent().add_child(floaty)
	floaty.get_child(0).start(1.75,str(val),true)


func _on_ALLY_mouse_entered():
	get_parent().get_parent().get_parent().hovering_ally = self
	if action_chosen || get_parent().get_parent().get_parent().get_node("Cards").visible:return
	show_on_top = true


func _on_ALLY_mouse_exited():
	if get_parent().get_parent().get_parent().hovering_ally == self:get_parent().get_parent().get_parent().hovering_ally = null
	if !show_on_top:return
	show_on_top = false
	


func _input(_event):
	if Input.is_action_pressed("Lm") && !get_parent().get_parent().get_parent().hovering_ally == self && get_local_mouse_position().length() < 256:
		get_parent().get_parent().get_parent().return_cards_to_hand()
		if !used:get_node("Sprite/CPUParticles2D").emitting = false
		reset_size()
		if get_parent().get_parent().get_parent().hovering_ally == null || get_parent().get_parent().get_parent().hovering_ally.used:
			get_parent().get_parent().get_parent().active_ally = null
			get_parent().get_parent().get_parent().return_cards_to_hand()
			var time = Timer.new()
			time.wait_time = 0.25*(int(get_parent().get_parent().get_parent().selected_card != null)+int(!get_parent().get_parent().get_parent().get_node("Cards").visible)+0.01)
			add_child(time)
			time.name = "a"
			time.connect("timeout",self,"hide_cards",[time])
			time.start()
			get_parent().get_parent().get_parent().active_ally = null
			get_parent().get_parent().get_parent().selected_card = null
		else:
			get_parent().get_parent().get_parent().return_cards_to_hand()
			get_parent().get_parent().get_parent().hovering_ally.show_on_top = true
			get_parent().get_parent().get_parent().active_ally = get_parent().get_parent().get_parent().hovering_ally
			get_parent().get_parent().get_parent().active_ally.select_self()
		get_parent().get_parent().get_parent().get_node("Card_Effect/Particles2D").emitting = false
		reset_size()
		
	
	if Input.is_action_just_pressed("Lm") && show_on_top && !used:
		
		get_parent().get_parent().get_parent().get_node("Cards").show()
		if get_parent().get_parent().get_parent().active_ally != self:
			get_parent().get_parent().get_parent().selected_card = null
		get_parent().get_parent().get_parent().active_ally = self
		$Tween.interpolate_property($Sprite,"rect_scale",$Sprite.rect_scale,Vector2(1.5,1.5),0.125,Tween.TRANS_LINEAR)
		$Tween.interpolate_property($Sprite,"rect_position",$Sprite.rect_position,Vector2(-16,-16),0.125,Tween.TRANS_LINEAR)
		$Tween.start()
		get_parent().get_parent().get_parent().update_card_foils(cards_foiled)
		
	if Input.is_action_just_pressed("Rm") && !used && get_parent().get_parent().get_parent().get_node("Cards").visible:
		pass


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
		return rand_range(0.0,0.5)*(shielded_amount)
	return 1.0
func select_self():
	get_parent().get_parent().get_parent().get_node("Cards").show()
	if get_parent().get_parent().get_parent().active_ally != self:
		get_parent().get_parent().get_parent().selected_card = null
	get_parent().get_parent().get_parent().active_ally = self
	$Tween.interpolate_property($Sprite,"rect_scale",$Sprite.rect_scale,Vector2(1.5,1.5),0.125,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Sprite,"rect_position",$Sprite.rect_position,Vector2(-16,-16),0.125,Tween.TRANS_LINEAR)
	$Tween.start()
	get_parent().get_parent().get_parent().update_card_foils(cards_foiled)
