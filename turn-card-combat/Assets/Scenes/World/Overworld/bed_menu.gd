extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	Save.save_game()
	get_tree().paused = false
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Assets/Scenes/Menu/MENU.tscn")

func _on_Button2_pressed():
	get_parent().get_node("effects").start_sleep()
	get_child(0).hide()
	get_parent().get_node("World_Player").can_move = true
	GlobalData.set_mouse(false)
