extends Sprite


export var do_collision=true
export var area_offest=Vector2.ZERO
export var area_size=Vector2(8,8)
export var entity_offset = Vector2.ZERO
export var entity_size=Vector2(8,8)

export (Array,int)var talk_id_set=[0]
export var talk_file_id=0
export (Array,String)var conditional_talk_types
export (Array,int)var conditional_talk_value
export (Array,Array,int)var conditional_talk_id
export var do_action_after_talk = false
export var after_talk_action = "none"

var player_inside=false

var cur_text_pos = 0
var self_text = []
var is_talking = false

func _ready():
	$StaticBody2D/CollisionShape2D.disabled = !do_collision
	$area.position = area_offest
	$area/CollisionShape2D.shape.extents = area_size
	$StaticBody2D/CollisionShape2D.shape.extents = entity_size
	$StaticBody2D.position = entity_offset

func _on_area_body_entered(body):if body.name=="World_Player":player_inside=true
func _on_area_body_exited(body):if body.name=="World_Player":player_inside=false

func _input(_event):
	if !Input.is_action_just_pressed("interact")||!player_inside:return
	if !is_talking:
		var cur_file = talk_file_id
		is_talking=true
		cur_text_pos = 0
		var file = File.new()
		var talk_id = talk_id_set[round(rand_range(0.0,talk_id_set.size()-1))]
		for cond in conditional_talk_types.size():
			if Util.get_condition(conditional_talk_types[cond]) >= conditional_talk_value[cond]:
				talk_id = conditional_talk_id[cond][0]
				cur_file = conditional_talk_id[cond][1]
		file.open("res://Data/NPC_TALK/NPC_TALK_"+str(cur_file)+".dat",File.READ)
		self_text = file.get_as_text().split("(ID)")[talk_id+1].split("(NEWLINE)")
		file.close()
	else:
		cur_text_pos += 1
	
	if cur_text_pos >= self_text.size()-1:
		is_talking = false
		cur_text_pos = 0
		get_tree().get_nodes_in_group("text_area")[0].hide_text()
		if do_action_after_talk:
			call(after_talk_action)
	else:
		get_tree().get_nodes_in_group("text_area")[0].set_text(self_text[cur_text_pos])

func shop():get_parent().get_parent().get_parent().load_shop()
