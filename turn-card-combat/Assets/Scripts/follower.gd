extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player:NodePath
var p_pos = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("Player")[0].get_path()
	randomize()
var direction = Vector2.ZERO
func load_icon(icon,n_name):
	$TextureRect.texture = load(icon)
	$TextureRect/Label.text = n_name
func _process(_delta):
	if position.distance_squared_to(p_pos) < 512:return
# warning-ignore:return_value_discarded
	move_and_slide(direction,Vector2.ZERO)



func _on_Timer_timeout():
	direction = (get_parent().get_parent().get_node("Map").get_simple_path(position,get_node(player).position,true)[1]-position).normalized()*128+Vector2(rand_range(-10.0,10.0),rand_range(-10.0,10.0))
	p_pos = get_node(player).position
