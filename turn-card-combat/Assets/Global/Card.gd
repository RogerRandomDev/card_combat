extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


const card_type = ["Attack","Heal","Defend"]
const team_cards = [1]
const self_cards = [2]

var turns_till_actions = []


func get_card_data(card_id):
	var file = File.new()
	file.open("res://Data/card_data.dat",File.READ)
	var card_data = str2var(file.get_as_text())
	return card_data[card_id]

func add_action(action,turn_count,active_ally=null,active_enemy=null,selected_ally=null,active_card=0,foiled = false):
	if active_ally == null:
		return false
	if turn_count!=0:
		if !call(action+"_can_do",active_ally,active_enemy,selected_ally,active_card,foiled):return false
		turns_till_actions.append([action,turn_count,active_ally,active_enemy,selected_ally,active_card,foiled])
		return true
	else:
		return call(action,active_ally,active_enemy,selected_ally,active_card,foiled)

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
			call(turns_till_actions[action][0],turns_till_actions[action][2],turns_till_actions[action][3],turns_till_actions[action][4],turns_till_actions[action][5],turns_till_actions[action][6],true)
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
func HURT(ally,enemy,_selected,_active_card,foiled,delayed = false):
	if enemy == null:
		return false
	if foiled:
		enemy.hurt(-20)
	else:
		enemy.hurt(-round(rand_range(10,20)))
	if !delayed:ally_used(ally)
	return true
func HEAL(ally,enemy,selected,_active_card,foiled,delayed=false):
	if enemy!=null || selected == null:return false
	if foiled:
		selected.heal(40)
	else:
		selected.heal(round(rand_range(20,40)))
	if !delayed:ally_used(ally)
	return true
func DEFEND(ally,_enemy,selected,_active_card,foiled,delayed = false):
	if ally != selected:
		return false
	ally.shield(foiled)
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
