extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var gravity = 98
var direction = Vector2(0,-98)
func start(lifetime,txt,healing = false,image=""):
	randomize()
	modulate = Color(int(!healing),int(healing),0.0,1.0)
	text = txt
	if image!="":$Image.texture = load(image)
	var time = Timer.new()
	direction.x += rand_range(-49,49)
	time.wait_time = lifetime
	add_child(time)
	time.start()
	time.connect("timeout",self,"free_self")
func free_self():
	queue_free()
func _process(delta):
	rect_position += direction*delta
	direction.y += gravity*delta
