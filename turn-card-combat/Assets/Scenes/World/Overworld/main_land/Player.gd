extends KinematicBody2D


export var accel_rate = 1.0
export var decel_rate = 1.0

var can_move = true
export var velocity = Vector2.ZERO
export var Direction = Vector2.ZERO
export var move_speed = 128

var last_pos = Vector2.ZERO
func _ready():
	pass
var bob_amount = 0.0
func _process(delta):
	if !can_move:return
	Direction = move_direction()
	bob_amount += delta*int(Direction != Vector2.ZERO)
	if bob_amount>=4:bob_amount = 0.0
	$Sprite.position.y = sin(bob_amount*PI*5)*1
	$Sprite.rotation = sin(bob_amount*PI*2.5)*PI/32
	if Direction.length() == 0:
		velocity = lerp(velocity,Direction,delta*decel_rate)
	else:
		velocity = lerp(velocity,Direction,delta*accel_rate)
# warning-ignore:return_value_discarded
	move_and_slide(velocity,Vector2.ZERO)
func move_direction():
	return Vector2(int(Input.is_action_pressed("right"))-int(Input.is_action_pressed("left")),int(Input.is_action_pressed("down"))-int(Input.is_action_pressed("up")))*move_speed
# warning-ignore:unused_argument
func _unhandled_key_input(event):
	if !can_move:return
	if Input.is_action_pressed("right") || Input.is_action_pressed("left"):
		if !Input.is_action_pressed("left") || !Input.is_action_pressed("right"):
			$Tween.interpolate_property($Sprite,"scale",$Sprite.scale,Vector2(int(Input.is_action_pressed("right"))-int(Input.is_action_pressed("left")),1),0.125,Tween.TRANS_LINEAR)
			$Tween.start()
func set_camera_limits(limits_min,limits_max):
	$Camera2D.limit_left = limits_min.x
	$Camera2D.limit_top = limits_min.y
	$Camera2D.limit_right = limits_max.x
	$Camera2D.limit_bottom = limits_max.y
	velocity = Vector2.ZERO
