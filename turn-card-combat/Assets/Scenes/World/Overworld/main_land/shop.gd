extends CanvasLayer



func toggle_shop():
	get_tree().paused = !get_tree().paused
	$shop_base.visible = !$shop_base.visible
func _input(_event):
	if !$shop_base.visible:return
	if Input.is_action_just_pressed("exit"):toggle_shop()
