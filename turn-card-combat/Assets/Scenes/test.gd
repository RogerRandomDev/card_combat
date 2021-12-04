extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var max_cards = 3
export var card_scene:PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	var card_count = 0
	for card in max_cards:
		var n_card = card_scene.instance()
		n_card.card_type = card_count
		$Cards.add_child(n_card)
		card_count += 1
func _process(delta):
	$Card_Effect.position = get_global_mouse_position()
func update_cards(active=false,color=Color(0,0,0,1.0)):
	$Card_Effect/Particles2D.color = color
	$Card_Effect/Particles2D.emitting = active


func _on_check_cards_timeout():
	var al_select = false
	for card in $Cards.get_children():
		if card.get_child(0).rect_size.x > 95.9:
			if al_select:card.call_deferred('_on_Card_mouse_exited')
			al_select = true
	if $Cards.get_child(0) && $Cards.get_child(0).get_child(0).rect_size.x > 95 && al_select:
		$Cards.get_child(0).call_deferred('_on_Card_mouse_exited')
