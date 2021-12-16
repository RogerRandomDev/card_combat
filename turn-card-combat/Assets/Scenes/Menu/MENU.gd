extends Node2D

var cur_focused = 2
export var spinner_offset = Vector2(0,256)
var on_main = true
func _ready():
	for child in $title_body/holder/spinner.get_children():
		child.rect_position = spinner_offset.rotated(child.get_position_in_parent()*(PI*2/6/($title_body/holder/spinner.get_child_count()))-PI/6)
# warning-ignore:integer_division
		child.rect_rotation = child.get_position_in_parent()*(60/($title_body/holder/spinner.get_child_count()))-30
	$title_body/holder/spinner.get_child(cur_focused).enabled_focus_mode = Control.FOCUS_ALL
	$title_body/holder/spinner/Button3.grab_focus()
	$title_body/holder/spinner.rect_rotation = 6
# warning-ignore:unused_argument
func _process(delta):
	for child in $title_body/holder/spinner.get_children():
		child.modulate = Color(
		1,
		1,
		1,
		1-
		abs(
			$title_body/holder/spinner.rect_rotation+
# warning-ignore:integer_division
			(child.get_position_in_parent()*(60/$title_body/holder/spinner.get_child_count()))-30)/30)
# warning-ignore:unused_argument
func _input(event):
	if $Tween.is_active():return
	if Input.is_key_pressed(KEY_ESCAPE):
		$title_body/holder/spinner.get_child(cur_focused).pressed = false
		$title_body/holder/spinner.get_child(cur_focused).enabled_focus_mode = Control.FOCUS_ALL
		$title_body/holder/spinner.get_child(cur_focused).grab_focus()
#		if !cur_focused == 1 && !cur_focused == 3:
#			$title_body/holder/spinner.get_child(cur_focused).enabled_focus_mode = Control.FOCUS_NONE
	if !on_main:return
	if Input.is_action_just_pressed("enter"):
		$title_body/holder/spinner.get_child(cur_focused).enabled_focus_mode  =Control.FOCUS_ALL
		$title_body/holder/spinner.get_child(cur_focused).pressed = !$title_body/holder/spinner.get_child(cur_focused).pressed
		if cur_focused == 1 || cur_focused == 3:
			$title_body/holder/spinner.get_child(cur_focused).enabled_focus_mode = Control.FOCUS_NONE
	if Input.is_action_pressed("left"):
		$title_body/holder/spinner.get_child(cur_focused).disabled = false
		$title_body/holder/spinner.get_child(cur_focused).enabled_focus_mode  =Control.FOCUS_ALL
		$title_body/holder/spinner.get_child(cur_focused).pressed = false
		cur_focused += 1
# warning-ignore:integer_division
		var new_rot = $title_body/holder/spinner.rect_rotation-60/$title_body/holder/spinner.get_child_count()
		if new_rot < -25:
# warning-ignore:integer_division
			new_rot = (30)
		$Tween.interpolate_property($title_body/holder/spinner,"rect_rotation",$title_body/holder/spinner.rect_rotation,new_rot,0.125,Tween.TRANS_LINEAR)
		$Tween.start()
		new_focus()
	elif Input.is_action_pressed("right"):
		$title_body/holder/spinner.get_child(cur_focused).disabled = false
		$title_body/holder/spinner.get_child(cur_focused).enabled_focus_mode  =Control.FOCUS_ALL
		$title_body/holder/spinner.get_child(cur_focused).pressed = false
		
		cur_focused -= 1
# warning-ignore:integer_division
		var new_rot = $title_body/holder/spinner.rect_rotation+60/$title_body/holder/spinner.get_child_count()
		if new_rot > 30:
# warning-ignore:integer_division
			new_rot = -30+60/$title_body/holder/spinner.get_child_count()
		$Tween.interpolate_property($title_body/holder/spinner,"rect_rotation",$title_body/holder/spinner.rect_rotation,new_rot,0.125,Tween.TRANS_LINEAR)
		$Tween.start()
		new_focus()
	if Input.is_key_pressed(KEY_LEFT) || Input.is_key_pressed(KEY_RIGHT) || Input.is_key_pressed(KEY_UP) || Input.is_key_pressed(KEY_DOWN):
		new_focus(false)
func new_focus(do_noise=true):
	if cur_focused<0:
		cur_focused = 4
	if cur_focused > 4:
		cur_focused = 0
	if do_noise:GlobalData.do_menu_sfx("OPTION")
	$title_body/holder/spinner.get_child(cur_focused).enabled_focus_mode = Control.FOCUS_ALL
	$title_body/holder/spinner.get_child(cur_focused).grab_focus()


func _on_Button3_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Assets/Scenes/World/Overworld/World_Base.tscn")


func _on_Button_pressed():
	get_tree().quit()

func _on_Button2_toggled(button_pressed):
	$Tween.interpolate_property($title_body/holder,"rect_position",$title_body/holder.rect_position,Vector2(0,420)*int(button_pressed)+Vector2(384,300),0.25,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($title_body/settings,"rect_position",$title_body/settings.rect_position,Vector2(0,720)*int(!button_pressed),0.25,Tween.TRANS_LINEAR)
	$Tween.start()
	on_main = !button_pressed
	if button_pressed:
		$title_body/settings/Volume/Volume_Slider.grab_focus()
	else:
		$title_body/settings.grab_focus()


func _on_Button4_toggled(button_pressed):
	$Tween.interpolate_property($title_body/holder,"rect_position",$title_body/holder.rect_position,Vector2(0,420)*int(button_pressed)+Vector2(384,300),0.25,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($title_body/achievements,"rect_position",$title_body/achievements.rect_position,Vector2(0,720)*int(!button_pressed),0.25,Tween.TRANS_LINEAR)
	$Tween.start()
	on_main = !button_pressed
