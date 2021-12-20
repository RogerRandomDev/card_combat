extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var card_energy = 1
export var card_power = 5
export var card_effect = 0
export var card_type = 0
export var card_rarity = 0


var foiled = false

var selected = false

#data gained from the card_data file
var card_header = "NULL"
var card_body = "NULL"
var card_action = "NULL"
var card_stats = ["NULL"]
var card_delay = 0
var card_attribute = "Null"
func _ready():
	randomize()
#	foiled = rand_range(0.0,1.0)>0.75
	toggle_foil(foiled)
	$Card_Image.modulate = Color(int(card_type=="Punch"),int(card_type=="Heals"),int(card_type=="Shield"),1.0)
	process_priority = get_position_in_parent()
	var data = Card.get_card_data(card_type)
	$Card_Image/Text/Top.text = data[0]
	card_action = data[2]
	card_stats = data[3]
	card_attribute = data[4]
	var char_count = data[0].length()
	$Card_Image/Text/Top.rect_scale.x = 1-(0.5/max(char_count-4,1))
	if foiled:
		data[1] = data[1].replace("_____",str(data[3][2]))
	else:
		data[1] = data[1].replace("_____",str(data[3][1])+"-"+str(data[3][2]))
	$Card_Image/Text/Description.text = data[1]
	if char_count == 4:$Card_Image/Text/Top.rect_scale.x = 1
	else:
		$Card_Image/Text/Top.rect_size.x = 48/$Card_Image/Text/Top.rect_scale.x
		$Card_Image/Text/Top.rect_position.y = $Card_Image/Text/Top.rect_size.x/2-24
	$Card_Image/Text/Top.rect_scale.y = $Card_Image/Text/Top.rect_scale.x

func _on_Card_mouse_entered():
	if selected:return
	$Tween.interpolate_property($Card_Image,"rect_size",$Card_Image.rect_size,Vector2(72,96),0.25,Tween.TRANS_CUBIC)
	$Tween.interpolate_property($Card_Image,"rect_position",$Card_Image.rect_position,Vector2(-6,-48),0.25,Tween.TRANS_CUBIC)
	$Tween.interpolate_property($Card_Image/Text,"rect_scale",$Card_Image/Text.rect_scale,Vector2(1.5,1.5),0.25,Tween.TRANS_CUBIC)
	$Tween.start()
	self.show_on_top = true
func _on_Card_mouse_exited():
	if selected:return
	$Tween.interpolate_property($Card_Image,"rect_size",$Card_Image.rect_size,Vector2(48,64),0.25,Tween.TRANS_CUBIC)
	$Tween.interpolate_property($Card_Image,"rect_position",$Card_Image.rect_position,Vector2(0,0),0.25,Tween.TRANS_CUBIC)
	$Tween.interpolate_property($Card_Image/Text,"rect_scale",$Card_Image/Text.rect_scale,Vector2(1,1),0.25,Tween.TRANS_CUBIC)
	$Tween.start()
	self.show_on_top = false


# warning-ignore:unused_argument
func _on_Card_gui_input(event):
	if selected:return
	if Input.is_action_just_pressed("Lm"):
		get_parent().get_parent().active_card = true
		get_parent().get_parent().active_card_type = card_type
		get_parent().get_parent().selected_card = self
		get_parent().get_parent().update_active_particles(card_type)
		select_card()
	if Input.is_action_just_pressed("Rm"):
		show_details()

func select_card():
	for card in get_parent().get_children():
		card.selected = false
		get_parent().get_parent().update_cards(false,Color(int(card_type==0),int(card_type==1),int(card_type==2),1.0))
		card.call_deferred('_on_Card_mouse_exited')
	$Tween.interpolate_property($Card_Image,"rect_global_position",$Card_Image.rect_global_position,Vector2(512,300)-Vector2(24,32),0.5,Tween.TRANS_CUBIC)
	$Tween.interpolate_property($Card_Image,"rect_size",$Card_Image.rect_size,Vector2(96,128),0.5,Tween.TRANS_CUBIC)
	$Tween.interpolate_property($Card_Image/Text,"rect_scale",$Card_Image/Text.rect_scale,Vector2(2,2),0.5,Tween.TRANS_CUBIC)
	selected = true
	get_parent().get_parent().update_cards(true,Color(int(card_type==0),int(card_type==1),int(card_type==2),1.0))
	$Tween.start()
func show_details():
	pass

func toggle_foil(toggled):
	if toggled:
		$Card_Image.material = load("res://Assets/Cards/shiny_foil.tres")
	else:
		$Card_Image.material = null
func ATTACK_check():
	var mouse_pos = get_global_mouse_position()
	for node in get_tree().get_nodes_in_group("ATTACKABLE"):
		if Simpli.in_range_Vector2(mouse_pos,node.rect_global_position,node.rect_size):
			return true
	return false
func HEAL_check():
	var mouse_pos = get_global_mouse_position()
	for node in get_tree().get_nodes_in_group("HEALABLE"):
		if Simpli.in_range_Vector2(mouse_pos,node.rect_global_position,node.rect_size):
			return true
	return false


func get_output_value():
	var returned = 10
	if card_stats[0] == "random":
		returned = round(rand_range(card_stats[1],card_stats[2]))
		if foiled:returned = card_stats[2]
	if card_action == "HURT":returned = -returned
	return returned
	
func redo_foil(recieved_foil=null):
	foiled = rand_range(0.0,1.0)>0.75
	if recieved_foil != null:foiled = recieved_foil
	toggle_foil(foiled)
	var data = Card.get_card_data(card_type)
	if foiled:
		data[1] = data[1].replace("_____",str(data[3][2]))
	else:
		data[1] = data[1].replace("_____",str(data[3][1])+"-"+str(data[3][2]))
	$Card_Image/Text/Description.text = data[1]
