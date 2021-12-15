extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


export var achievement_scene:PackedScene
func _ready():
	for achievement in Util.achievment_list:
		var held = achievement_scene.instance()
		$achievement_list.add_child(held)
		var succeeded = false
		succeeded = Util.complete_achievments.has(achievement[0])
		held.load_achievement(achievement[0],achievement[1],succeeded)
