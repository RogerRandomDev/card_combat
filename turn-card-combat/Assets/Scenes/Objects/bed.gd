extends StaticBody2D

func _on_check_body_entered(body):
	if !body.name == "World_Player":return
	$Label.show()


func _on_check_body_exited(body):
	if !body.name == "World_Player":return
	$Label.hide()


func _input(_event):
	if !$Label.visible:return
	if Input.is_action_just_pressed("interact"):
		get_parent().get_parent().get_node("bed_menu").get_child(0).show()
		GlobalData.set_mouse(true)
		get_parent().get_parent().get_node("World_Player").can_move = false
