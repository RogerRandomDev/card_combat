extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


export var achievement_scene:PackedScene
func load_achievements():
	var cur_achievement = 0
	for achievement in Util.achievment_list:
		var held = achievement_scene.instance()
		$achievement_list.add_child(held)
		var succeeded = false
		succeeded = Util.complete_achievments.has(achievement[0])
		held.load_achievement(achievement[0],achievement[1],succeeded)
		held.connect("mouse_entered",self,"update_hovered_achievement",[cur_achievement,achievement[3],achievement[2]])
		cur_achievement += 1
func update_hovered_achievement(id,description,achievement_type):
	$Description/ACHIEVEMENT_DESCRIPTION.show()
	$Description/ACHIEVEMENT_NAME.text = $achievement_list.get_child(id).Name
	var max_value = achievement_type.values()[0]
	$Description/ACHIEVEMENT_DESCRIPTION.text = description+" "+str(min(Util.get_achievment_progress(achievement_type.keys()[0]),max_value))+"/"+str(max_value)
	if description == "dont_show":$Description/ACHIEVEMENT_DESCRIPTION.hide()
