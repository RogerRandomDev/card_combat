extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


export var give_achievement:bool
export var achievement_name:String
func _on_Area2D_body_entered(body):
	if !give_achievement:return
	if body.name == "Ball":Util.give_achievement(achievement_name)
