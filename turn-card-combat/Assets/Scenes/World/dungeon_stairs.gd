extends Control




func _ready():
	$Label.text = "Current Floor: "+str(Util.cur_layer)
	if Util.cur_layer == 10:
		$HBoxContainer/next.hide()

func _on_next_pressed():
	get_parent().get_parent().next_floor()


func _on_return_pressed():
	get_parent().get_parent().return_to_home()
