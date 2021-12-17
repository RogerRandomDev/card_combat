extends CanvasLayer


var next_achievements = []
func load_achievement(Name,Tex):
	if !get_child_count() == 2 || $Tween.is_active():next_achievements.append([Name,Tex])
	$achievment_shown/Name.text = Name
	$achievment_shown/icon.texture = load(Tex)
	$Tween.interpolate_property($achievment_shown,"rect_position",$achievment_shown.rect_position,Vector2(928,568),0.25,Tween.TRANS_LINEAR)
	$Tween.start()
	var time = Timer.new()
	add_child(time)
	time.wait_time = 3.75
	time.connect("timeout",self,"drop_achievement",[time])
	time.start()

func drop_achievement(timer):
	timer.queue_free()
	$Tween.interpolate_property($achievment_shown,"rect_position",$achievment_shown.rect_position,Vector2(928,600),0.25,Tween.TRANS_LINEAR)
	$Tween.start()
# warning-ignore:return_value_discarded
	$Tween.connect("tween_all_completed",self,"load_next")
func load_next():
	$Tween.disconnect("tween_all_completed",self,"load_next")
	if next_achievements.size() != 0:
		load_achievement(next_achievements[next_achievements.size()-1][0],next_achievements[next_achievements.size()-1][1])
		next_achievements.remove(next_achievements.size()-1)
