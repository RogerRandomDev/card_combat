
extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_text(text):
	$area_base.show()
	$area_base/area_text.text = text
	get_parent().get_node("World_Player").can_move = false
func hide_text():
	$area_base.hide()
	get_parent().get_node("World_Player").can_move = true
