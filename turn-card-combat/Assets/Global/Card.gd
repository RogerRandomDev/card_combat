extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


const card_type = ["Attack","Heal","Defend"]
const team_cards = [1]
const self_cards = [2]

var turns_till_actions = []

var card_data = []

func _ready():
	var file = File.new()
	file.open("res://Data/card_data.dat",File.READ)
	card_data = str2var(file.get_as_text())
	file.close()

func get_card_data(card_id):return card_data[card_id]

func add_action(action,turn_count,active_ally=null,active_enemy=null,selected_ally=null,active_card=0,foiled = false,modifiers={},selected_card=null):
	if active_ally == null || selected_card == null:return false
	if !modifiers.has("Card_Stats"):
		modifiers["Card_Stats"] = selected_card.card_stats
	if turn_count!=0:
		if !call(action+"_can_do",active_ally,active_enemy,selected_ally,active_card,foiled,modifiers):return false
		turns_till_actions.append([action,turn_count,active_ally,active_enemy,selected_ally,active_card,foiled,modifiers])
		return true
	else:
		return call(action,active_ally,active_enemy,selected_ally,active_card,foiled,false,modifiers)

func turn_end():
	get_tree().get_nodes_in_group("combat_win")[0].show()
	var timr = Timer.new()
	timr.wait_time = 0.75
	get_tree().current_scene.add_child(timr)
	timr.start()
	yield(timr,"timeout")
	timr.queue_free()
	for action in turns_till_actions.size():
		var new_time = turns_till_actions[action][1]-1
		if new_time <= 0:
			call(turns_till_actions[action][0],turns_till_actions[action][2],turns_till_actions[action][3],turns_till_actions[action][4],turns_till_actions[action][5],turns_till_actions[action][6],true,turns_till_actions[action][7])
			turns_till_actions.remove(turns_till_actions.find(action))
			var time = Timer.new()
			time.wait_time = 0.25
			get_tree().current_scene.add_child(time)
			time.start()
			yield(time,"timeout")
			time.queue_free()
		else:
			turns_till_actions[action][1] = new_time
	get_tree().get_nodes_in_group("combat_win")[0].hide()
# warning-ignore:unused_argument
func HURT(ally,enemy,_selected,_active_card,foiled,delayed = false,modifiers={}):
	if enemy == null:return false
	var output = -20
	if !foiled:output = default_output(modifiers["Card_Stats"])
	if modifiers.has("BUFFS"):output *= modifiers["BUFFS"]
	
	enemy.hurt(output,ally)
	if !delayed:ally_used(ally)
	return true
# warning-ignore:unused_argument
func HEAL(ally,enemy,selected,_active_card,foiled,delayed=false,modifiers={}):
	if enemy!=null || selected == null:return false
	var output = 40
	
	if !foiled:output = default_output(modifiers["Card_Stats"])
	if modifiers.has("BUFFS"):output *= modifiers["BUFFS"]
	
	selected.heal(output)
	if !delayed:ally_used(ally)
	return true
# warning-ignore:unused_argument
func DEFEND(ally,_enemy,selected,_active_card,foiled,delayed = false,modifiers={}):
	if ally != selected:return false
	
	ally.shield(foiled)
	if !delayed:ally.reset_size()
	if !delayed:ally_used(ally)
	return true
# warning-ignore:unused_argument
func BUFF(ally,_enemy,selected,_active_card,foiled,delayed=false,modifiers={}):
	if selected == null || selected == self:
		return false
	selected.buffed_stats = (int(foiled)*0.75)+1
	if !delayed:ally.reset_size()
	if !delayed:ally_used(ally)
	return true





func ally_used(active_ally):
	active_ally.used = true
	if active_ally != null:
		active_ally.modulate = Color(0.5,0.5,0.5,1.0)
		active_ally.reset_size()
func DEFEND_can_do(ally,_enemy,selected,_active_card):
	return ally == selected
func HEAL_can_do(_ally,enemy,selected,_active_card):
	return enemy==null && selected != null
func HURT_can_do(_ally,enemy,_selected,_active_card):
	return enemy!=null
# warning-ignore:unused_argument
func BUFF_can_do(ally,_enemy,selected,_active_card,_foiled,_delayed=false,modifiers={}):
	return selected != null && ally!=selected


func default_output(card_stats):
	var output = card_stats[2]
	if card_stats[0] == "random":output = round(rand_range(card_stats[1],card_stats[2]))
	return output
