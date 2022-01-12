extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_check_body_entered(body):
	if body.name != "World_Player":return
	$Label.show()
	get_parent().z_index = 0

func _on_check_body_exited(body):
	if body.name != "World_Player":return
	$Label.hide()
	get_parent().z_index = 3


func _input(_event):
	if !$Label.visible:return
	if Input.is_action_just_pressed("interact"):get_parent().get_parent().get_parent().load_map()
	
