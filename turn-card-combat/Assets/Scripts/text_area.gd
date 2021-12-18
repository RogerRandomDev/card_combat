
extends CanvasLayer


var finished_load = true
func set_text(text):
	$area_base.show()
	$area_base/area_text.text = text
	get_parent().get_node("World_Player").can_move = false
	finished_load = false
	$area_base/area_text.visible_characters = 0
	$Timer.start()
	
func hide_text():
	$area_base.hide()
	get_parent().get_node("World_Player").can_move = true
func can_update():return finished_load


func _on_Timer_timeout():
	$area_base/area_text.visible_characters += 1
	if $area_base/area_text.visible_characters >= $area_base/area_text.text.length():
		finished_load = true
		$Timer.stop()
