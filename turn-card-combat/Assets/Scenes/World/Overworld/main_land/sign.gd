extends Node2D


export var sign_id = 0
export var sign_file_id = 0

var sign_text = []
var cur_text = 0
export var text_size = 1.0
export var achievement_giver:bool=false
export var achievment_name:String=""
var player_in_range = false
var is_talking = false
func _ready():
	var file=File.new()
	file.open("res://Data/SIGN/sign_"+str(sign_file_id)+".dat",File.READ)
	sign_text = file.get_as_text().split("(ID)")[sign_id+1].split("(NEWLINE)")
	$sign_text/Panel/Label.rect_size = Vector2(88,32)/text_size
	$sign_text/Panel/Label.rect_scale = Vector2(1,1)*text_size





func _on_Area2D_body_entered(body):
	if body.name=="World_Player":player_in_range=true


func _on_Area2D_body_exited(body):
	if body.name=="World_Player":player_in_range=false
func _input(_event):
	if !player_in_range || !Input.is_action_just_pressed("interact"):return
	if achievement_giver:Util.give_achievement(achievment_name)
	if !is_talking:
		cur_text = 0
		is_talking = true
		$sign_text.show()
		$sign_text/Panel/Label.text = sign_text[cur_text].replace("PLAYER_NAME",Util.player_name)
		get_tree().get_nodes_in_group("Player")[0].can_move = false
	else:
		cur_text += 1
		if cur_text >= sign_text.size()-1:
			is_talking = false
			$sign_text.hide()
			get_tree().get_nodes_in_group("Player")[0].can_move = true
		else:
			$sign_text/Panel/Label.text = sign_text[cur_text].replace("PLAYER_NAME",Util.player_name)
