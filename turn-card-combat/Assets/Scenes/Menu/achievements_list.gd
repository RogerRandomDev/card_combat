extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


export var achievement_scene:PackedScene
var focused = 0
func load_achievements():
	var cur_achievement = 0
	for achievement in Util.achievment_list:
		var held = achievement_scene.instance()
		$ScrollContainer/achievement_list.add_child(held)
		var succeeded = false
		succeeded = Util.complete_achievments.has(achievement[0])
		held.load_achievement(achievement[0],achievement[1],succeeded)
		held.connect("mouse_entered",self,"update_hovered_achievement",[cur_achievement,achievement[3],achievement[2]])
		cur_achievement += 1
	if GlobalData.using_controller:
		focused = 0
		call_deferred('update_focus')
func update_hovered_achievement(id,description,achievement_type):
	$Description/ACHIEVEMENT_DESCRIPTION.show()
	$Description/ACHIEVEMENT_NAME.text = $ScrollContainer/achievement_list.get_child(id).Name
	var max_value = achievement_type.values()[0]
	
	$Description/ACHIEVEMENT_DESCRIPTION.text = description
	$Description/ACHIEVEMENT_NAME.show()
	if achievement_type.keys()[0] != "special":
		$Description/ACHIEVEMENT_DESCRIPTION.text +=" "+str(min(Util.get_achievment_progress(achievement_type.keys()[0]),max_value))+"/"+str(max_value)
	if description == "dont_show":$Description/ACHIEVEMENT_DESCRIPTION.hide()
func _input(_event):
	if !GlobalData.using_controller:return
	var achievement_count = $ScrollContainer/achievement_list.get_child_count()
	if Input.is_action_just_pressed("left"):focused-=1
	if Input.is_action_just_pressed("right"):focused+=1
	if Input.is_action_just_pressed("up"):focused-=9
	if Input.is_action_just_pressed("down"):focused+=9
	if focused >= achievement_count:focused -= achievement_count
	if focused < 0:focused+=achievement_count
	if achievement_count != 0:call_deferred('update_focus')

func update_focus():
	$ScrollContainer/achievement_list.get_child(focused).emit_signal("mouse_entered")
