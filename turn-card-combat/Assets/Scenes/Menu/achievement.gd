extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var Name = ""
func load_achievement(achievement_name,tex,requires):
	$TextureRect.texture = load(tex)
	$Label.text = achievement_name
	Name = achievement_name
	if !requires:modulate = Color(0.5,0.5,0.5,1)
