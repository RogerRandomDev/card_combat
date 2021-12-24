extends Node


const custom_cursors = {
	"Default":preload("res://Assets/Textures/Icons/Mouse.png"),
	"HURT":preload("res://Assets/Textures/Icons/MouseHurt.png"),
	"HEAL":preload("res://Assets/Textures/Icons/MouseHeal.png"),
	"SHIELD":preload("res://Assets/Textures/Icons/MouseShield.png")
	}

var control = Control.new()
func _ready():
	pause_mode=PAUSE_MODE_PROCESS
	get_tree().current_scene.add_child(control)
	get_viewport().warp_mouse(Vector2(1024,0))
func _input(_event):
	if _event is InputEventMouseMotion:return
	if GlobalData.using_controller:do_inputs()
	
func do_inputs():
	var focused = control.get_focus_owner()
	
	if focused == null:return
	var target = focused.get_path()
	if Input.is_action_just_pressed("interact"):
		Input.action_press("Lm")
		get_viewport().warp_mouse(Vector2(0,0))
		if focused.has_method("check_input"):
			focused.check_input()
	if Input.is_action_just_pressed("exit"):
		Input.action_press("Lm")
		get_viewport().warp_mouse(Vector2(1020,300))
		if focused.get('selected') != null:
			focused.selected = false
			focused._on_Card_mouse_exited()
			if focused.focus_neighbour_left != '':
				
				get_node(focused.focus_neighbour_left).grab_focus()
			focused.release_focus()
				
			
		return
	if Input.is_action_pressed("up"):
		target = focused.focus_neighbour_top
	if Input.is_action_pressed("down"):
		target = focused.focus_neighbour_bottom
	if Input.is_action_just_pressed("left"):
		target = focused.focus_previous
	if Input.is_action_just_pressed("right"):
		target = focused.focus_next
	
	if target == focused.get_path():return
	if target == '':return
	if get_node(target).has_method("expand"):get_node(target).expand()
	if focused.has_method("reset_size"):focused.reset_size()
	if get_node(target).has_method("_on_ALLY_mouse_entered"):
		get_node(target).get_parent().get_parent().get_parent().reset_ally()
		get_node(target)._on_ALLY_mouse_entered()
		Input.action_press("Lm")
	if get_node(target).has_method("_on_Card_mouse_entered"):
		get_node(target)._on_Card_mouse_entered()
	if focused.has_method("_on_Card_mouse_exited"):
		focused.selected = false
		focused._on_Card_mouse_exited()
	get_node(target).grab_focus()
