extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var data = []
func _ready():
	pass # Replace with function body.


func set_data(data_in):
	self.data = data_in
	$Base/Health.max_value = data_in[4]
	$Base/Health.value = data_in[3]
	$Base/Stats.text = "STATS:\nSTR:"+str(data_in[0])+"\nDEF:"+str(data_in[2])+"\nSUP:"+str(data_in[1])
	$Base/Name.text = data_in[5]
	$Base/Sprite.texture = load(data_in[6])
	