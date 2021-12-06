extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var in_attack = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
# warning-ignore:unused_argument
func _input(event):
	if Input.is_action_just_pressed("Lm") && show_on_top:
		get_parent().get_parent().get_parent().selected_enemy = self
		get_parent().get_parent().get_parent().update_enemy()

func _on_Enemy_mouse_entered():
	if !get_parent().get_parent().get_parent().active_card || get_parent().get_parent().get_parent().active_card_type != 0:return
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(1,1,1,1),0.125,Tween.TRANS_CUBIC)
	$Tween.start()
	$Sprite/Node2D.show()
	show_on_top = true


func _on_Enemy_mouse_exited():
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(0.75,0.75,0.75,1),0.125,Tween.TRANS_CUBIC)
	$Tween.start()
	$Sprite/Node2D.hide()
	show_on_top = false
func add_health(val):
	update_health(val+$Sprite/Node2D/Health.value)

func update_health(val):
	$Sprite/Node2D/Health.value = max(min(val,$Sprite/Node2D/Health.max_value),0)
	if $Sprite/Node2D/Health.value == 0:
		if get_parent().get_parent().get_parent().selected_enemy == self:
			get_parent().get_parent().get_parent().selected_enemy = null
		self.queue_free()
func hurt(damage):
	if in_attack:return false
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(1.0,0.25,0.25,1.0),0.25,Tween.TRANS_CUBIC)
# warning-ignore:return_value_discarded
	$Tween.connect("tween_all_completed",self,"finished_modulate",[damage])
	$Tween.start()
	in_attack = true
	return true
func finished_modulate(damage):
	$Tween.interpolate_property($Sprite,"modulate",$Sprite.modulate,Color(0.75,0.75,0.75,1.0),0.25,Tween.TRANS_CUBIC)
	$Tween.disconnect("tween_all_completed",self,"finished_modulate")
	$Tween.start()
	add_health(damage)
	in_attack = false
	
