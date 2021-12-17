extends KinematicBody2D


export var accel_rate = 1.0
export var decel_rate = 1.0


export var velocity = Vector2.ZERO
export var Direction = Vector2.ZERO
export var move_speed = 128


export var max_hp = 100
export var hp = 100


export var follower_scene:PackedScene
var last_pos = Vector2.ZERO
func _ready():
	randomize()
	var can_do = get_parent().get_parent().get_node("Map/Map").get_used_cells_by_id(0)
		
	var no = true
	while no:
		var pos = can_do[round(rand_range(0.0,can_do.size()-1))]
		var failed = false
		for x in 3:for y in 3:
			if !can_do.has(Vector2(pos.x+x-1,pos.y+y-1)):
				failed = true;break
		if !failed:
			position = pos*16;no=false
	hp = max_hp
	last_pos = position
	call_deferred('load_followers')
func load_followers():
	for follower in get_tree().get_nodes_in_group("follower"):
		follower.queue_free()
	for follower in Util.player_stats.size()-1:
		var followere = follower_scene.instance()
		get_parent().add_child(followere)
		followere.position = position
		followere.load_icon(Util.player_stats[follower+1][6],Util.player_stats[follower+1][5])
var bob_amount = 0.0
func _process(delta):
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
	if Input.is_action_pressed("right") || Input.is_action_pressed("left"):
		if !Input.is_action_pressed("left") || !Input.is_action_pressed("right"):
			$Tween.interpolate_property($Sprite,"scale",$Sprite.scale,Vector2(int(Input.is_action_pressed("right"))-int(Input.is_action_pressed("left")),1),0.125,Tween.TRANS_LINEAR)
			$Tween.start()

var travelled = 0.0
var need_to_travel = rand_range(512.0,1024.0)
var do_combat = false
func _on_new_check_timeout():
	if !do_combat:return
	var travel = last_pos.length_squared()-position.length_squared()
	last_pos = position
	travel = sqrt(travel)
	travel = max(abs(travel),0.01)
	travelled += travel
	if travelled >= need_to_travel:
		need_to_travel = rand_range(4096.0,8192.0*2.0)
		enter_combat()
		travelled = 0.0
func enter_combat():
	Util.player_position = position
	get_parent().get_parent().load_combat()
