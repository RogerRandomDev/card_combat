tool
extends EditorPlugin

var object_editor
func _enter_tree():
	object_editor = load("res://addons/object_sys/object_system.tscn").instance()
	get_editor_interface().get_editor_viewport().add_child(object_editor)


func _exit_tree():
	pass
func has_main_screen():
	return true


# warning-ignore:unused_argument
func make_visible(visible):
	object_editor.visible = visible


func get_plugin_name():
	return "CCS"


func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("AssetLib", "EditorIcons")
