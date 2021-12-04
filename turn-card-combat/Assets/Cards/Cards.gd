extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var card_energy = 1
export var card_power = 5
export var card_effect = 0
export var card_type = 0
export var card_rarity = 0

var selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Card_Image.modulate = Color(int(card_type==0),int(card_type==1),int(card_type==2),1.0)

func _on_Card_mouse_entered():
	if selected:return
	$Tween.interpolate_property($Card_Image,"rect_size",$Card_Image.rect_size,Vector2(72,96),0.25,Tween.TRANS_CUBIC)
	$Tween.interpolate_property($Card_Image,"rect_position",$Card_Image.rect_position,Vector2(-6,-48),0.25,Tween.TRANS_CUBIC)
	$Tween.interpolate_property($Card_Image/Label,"rect_scale",$Card_Image/Label.rect_scale,Vector2(1.5,1.5),0.25,Tween.TRANS_CUBIC)
	$Tween.start()
	self.show_on_top = true
func _on_Card_mouse_exited():
	if selected:return
	$Tween.interpolate_property($Card_Image,"rect_size",$Card_Image.rect_size,Vector2(48,64),0.25,Tween.TRANS_CUBIC)
	$Tween.interpolate_property($Card_Image,"rect_position",$Card_Image.rect_position,Vector2(0,0),0.25,Tween.TRANS_CUBIC)
	$Tween.interpolate_property($Card_Image/Label,"rect_scale",$Card_Image/Label.rect_scale,Vector2(1,1),0.25,Tween.TRANS_CUBIC)
	$Tween.start()
	self.show_on_top = false


func _on_Card_gui_input(event):
	if selected:return
	if Input.is_action_just_pressed("Lm"):
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
	$Tween.interpolate_property($Card_Image/Label,"rect_scale",$Card_Image/Label.rect_scale,Vector2(2,2),0.5,Tween.TRANS_CUBIC)
	selected = true
	get_parent().get_parent().update_cards(true,Color(int(card_type==0),int(card_type==1),int(card_type==2),1.0))
	$Tween.start()
func show_details():
	pass
