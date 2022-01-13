extends CanvasLayer
export var vag_val = 0.0
export var update_self=false
func start_sleep():$AnimationPlayer.play("sleep")
func _process(_delta):
	if !update_self:return
	$TextureRect.material.set_shader_param("vig_val",vag_val)
func sleep_complete():Save.save_game()
