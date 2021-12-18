extends Sprite


export var do_collision=true
export var area_offest=Vector2.ZERO
export var area_size=Vector2(8,8)
export var entity_offset = Vector2.ZERO
export var entity_size=Vector2(8,8)
export (String)var talk_id_name
export (Array,String)var conditional_talk_types
export (Array,int)var conditional_talk_value
export (Array,String)var conditional_talk_id
export var do_action_after_talk = false
export var after_talk_action = "none"
export var entity_name = "PLACEHOLDER"
var player_inside=false

var cur_text_pos = 0
var self_text = []
var is_talking = false
var cur_talk = ""
func _ready():
	randomize()
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
		is_talking=true
		var talk_id = talk_id_name
		cur_talk = str(talk_id)
		for cond in conditional_talk_types.size():
			if Util.get_condition(conditional_talk_types[cond]) >= conditional_talk_value[cond]:
				if Util.dont_speak_again.has(conditional_talk_id[cond]):continue
				var place_talk_id = conditional_talk_id[cond]
				talk_id = place_talk_id
				cur_talk = conditional_talk_id[cond]
	if get_tree().get_nodes_in_group("text_area")[0].can_update() && !Util.dont_speak_again.has(cur_talk):
		get_tree().get_nodes_in_group("text_area")[0].set_text(cur_talk,entity_name,self)

func shop():get_parent().get_parent().get_parent().load_shop()
