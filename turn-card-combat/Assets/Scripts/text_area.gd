
extends CanvasLayer


var finished_load = true
var cur_text_scene = null
var cur_entity = null
func set_text(text_name,ent_name,cur_ent):
	get_parent().get_node("World_Player").can_move = false
	finished_load = false
	cur_entity = cur_ent
	var dialog = Dialogic.start(text_name)
	add_child(dialog)
	if ent_name=="":pass
	
	
func only_say_once():
	var cur_talk = cur_entity.cur_talk
	if !Util.dont_speak_again.has(cur_talk):
		Util.dont_speak_again.append(cur_talk)
func hide_text():
	get_parent().get_node("World_Player").can_move = true
	finished_load = true
	if cur_entity != null:cur_entity.is_talking = false
	cur_entity = null
func can_update():return finished_load || cur_entity == null

func update_condition(condition,updated_val):Util.set_condition(condition,updated_val)
