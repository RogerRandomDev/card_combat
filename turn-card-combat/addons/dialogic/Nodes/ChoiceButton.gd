extends Button

var self_focused = false
func _ready():
	if get_position_in_parent() == 0:self_focused = true
func _process(delta):
	if self_focused && !has_focus():
		call_deferred('grab_focus')
	if has_focus():
		if Input.is_action_just_pressed("down"):
			var next_focus = find_next_valid_focus()
			self_focused = false
			while next_focus.get_class() != 'Button':
				next_focus = next_focus.find_next_valid_focus()
			next_focus.self_focused = true
			release_focus()
			next_focus.call_deferred('grab_focus')
		if Input.is_action_just_pressed("up"):
			var next_focus = find_prev_valid_focus()
			self_focused = false
			while next_focus.get_class() != 'Button':
				next_focus = next_focus.find_prev_valid_focus()
			next_focus.self_focused = true
			release_focus()
			next_focus.call_deferred('grab_focus')
		if Input.is_action_pressed('enter'):
			emit_signal("button_down")
		if Input.is_action_just_released('enter'):
			emit_signal("button_up")
			emit_signal("pressed")
