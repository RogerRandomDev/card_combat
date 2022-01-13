extends Control
tool

export (String)var data_path="res://Data/"

var file = File.new()
var all_data = {}
var cur_data_type = "achievements"
var readied = false
func _ready():
	readied = true
	load_game()
func _enter_tree():
	load_game()
func _init():
	if readied:call_deferred('load_game')
func load_game():
	if !Engine.editor_hint:
		$TabContainer.rect_scale = Vector2.ONE
		$holder/save_all_data.rect_position /= Vector2(1.45,1.45)
	for item in $TabContainer/Achievements/list.get_item_count():
		$TabContainer/Achievements/list.remove_item(0)
	for item in $TabContainer/Cards/card_list.get_item_count():
		$TabContainer/Cards/card_list.remove_item(0)
	for item in $TabContainer/Characters/char_list.get_item_count():
		$TabContainer/Characters/char_list.remove_item(0)
	for item in $TabContainer/Enemies/enemy_list.get_item_count():
		$TabContainer/Enemies/enemy_list.remove_item(0)
	for item in $TabContainer/Levels/Level_List.get_item_count():
		$TabContainer/Levels/Level_List.remove_item(0)
	file.open(data_path+"achievements.dat",File.READ)
	all_data["achievements"] = str2var(file.get_as_text())
	file.close()
	file.open(data_path+"enemy_data.dat",File.READ)
	all_data["enemies"] = str2var(file.get_as_text())
	file.close()
	file.open(data_path+"character_data.dat",File.READ)
	all_data["characters"] = str2var(file.get_as_text())
	file.close()
	file.open(data_path+"card_data.dat",File.READ)
	all_data["cards"] = str2var(file.get_as_text())
	file.close()
	file.open(data_path+"level_dat.dat",File.READ)
	all_data["levels"] = str2var(file.get_as_text())
	file.close()
	for achievement in all_data["achievements"]:
		$TabContainer/Achievements/list.add_item(achievement[0],load(achievement[1]))
	var card_image = preload("res://Assets/Textures/card_base.png")
	for card in all_data["cards"].keys():
		$TabContainer/Cards/card_list.add_item(card,card_image)
	for char_ in all_data["characters"]:
		$TabContainer/Characters/char_list.add_item(char_["Name"],load(char_["Icon"]))
	for enem in all_data["enemies"]:
		$TabContainer/Enemies/enemy_list.add_item(str(enem["ID"]),load(enem["Icon"]))
	for level in all_data["levels"]:
		$TabContainer/Levels/Level_List.add_item(str(level["Name"]))
	load_card_list()
var active_achievement_data = []
var last_achievement = -1

var cur_data_name = ""
func _on_list_item_selected(index):
	$TabContainer/Achievements/data/TextureRect/Button.show()
	$TabContainer/Achievements/data/add_requirement.show()
	$TabContainer/Achievements/data/remove_requirement.show()
	$TabContainer/Achievements/data/edit_requirement.show()
	if active_achievement_data != []:
		all_data["achievements"][last_achievement] = active_achievement_data
	active_achievement_data = all_data["achievements"][index]
	update_achievement_data()
	last_achievement = index
func update_achievement_list():
	for item in $TabContainer/Achievements/list.get_item_count():
		$TabContainer/Achievements/list.remove_item(0)
	for achievement in all_data["achievements"]:
		$TabContainer/Achievements/list.add_item(achievement[0],load(achievement[1]))
func update_achievement_data():
	$TabContainer/Achievements/data/name_of.text = active_achievement_data[0]
	$TabContainer/Achievements/data/description.text = active_achievement_data[3]
	$TabContainer/Achievements/data/TextureRect.texture = load(active_achievement_data[1])
	$TabContainer/Achievements/data/description.show()
	if active_achievement_data[3] == "dont_show":
		$TabContainer/Achievements/data/description.text = "No Description"
	for item in $TabContainer/Achievements/data/requirements.get_item_count():
		$TabContainer/Achievements/data/requirements.remove_item(0)
	for required in active_achievement_data[2].keys():
		var showed = required
		if required != "special":
			showed += ": "+str(active_achievement_data[2][required])
		$TabContainer/Achievements/data/requirements.add_item(showed)
func _on_Button_pressed():
	$TabContainer/Achievements/select_texture.current_path = "res://Assets/Textures/"
	$TabContainer/Achievements/select_texture.get_child(7).get_child(0).emit_signal('pressed')
	$TabContainer/Achievements/select_texture.show()
	call_deferred('delayed_button')
func delayed_button():
	$TabContainer/Achievements/select_texture.get_child(3).get_child(0).get_child(5).emit_signal("button_down")
	$TabContainer/Achievements/select_texture.get_child(3).get_child(0).get_child(5).emit_signal("button_up")
	$TabContainer/Achievements/select_texture.get_child(3).get_child(0).get_child(5).emit_signal("pressed")
	
	
func _on_select_texture_file_selected(path):
	active_achievement_data[1] = path
	update_achievement_data()
	update_achievement_list()


func _on_data_cancel_pressed():
	$TabContainer/Achievements/data/PopupPanel.hide()

var changing_requirements = false
func _on_data_confirm_pressed():
	if typeof(str2var($TabContainer/Achievements/data/PopupPanel/data_value.text)) != typeof(0):return
	if cur_data_name != $TabContainer/Achievements/data/PopupPanel/data_name.text && changing_requirements:
		active_achievement_data[2].erase(cur_data_name)
	cur_data_name = $TabContainer/Achievements/data/PopupPanel/data_name.text
	if cur_data_name != '':
		active_achievement_data[2][cur_data_name] = str2var($TabContainer/Achievements/data/PopupPanel/data_value.text)
	$TabContainer/Achievements/data/PopupPanel.hide()
	update_achievement_data()


func _on_requirements_item_selected(index):
	cur_data_name = $TabContainer/Achievements/data/requirements.get_item_text(index).split(": ")[0]


func _on_add_requirement_pressed():
	changing_requirements = false
	$TabContainer/Achievements/data/PopupPanel/data_name.text = ''
	$TabContainer/Achievements/data/PopupPanel/data_value.text = ''
	$TabContainer/Achievements/data/PopupPanel.show()


func _on_remove_requirement_pressed():
	if cur_data_name != '':
		active_achievement_data[2].erase(cur_data_name)
		update_achievement_data()


func _on_edit_requirement_pressed():
	if $TabContainer/Achievements/data/requirements.get_selected_items().size() == 0:return
	changing_requirements = true
	var item = $TabContainer/Achievements/data/requirements.get_selected_items()[0]
	$TabContainer/Achievements/data/PopupPanel/data_name.text = $TabContainer/Achievements/data/requirements.get_item_text(item).split(": ")[0]
	if $TabContainer/Achievements/data/requirements.get_item_text(item).split(": ").size() > 1:
		$TabContainer/Achievements/data/PopupPanel/data_value.text = $TabContainer/Achievements/data/requirements.get_item_text(item).split(": ")[1]
	else:
		$TabContainer/Achievements/data/PopupPanel/data_value.text = '-1'
	$TabContainer/Achievements/data/PopupPanel.show()


func _on_add_achievement_pressed():
	$TabContainer/Achievements/add_achievement_panel.show()


func _on_remove_achievement_pressed():
	if !$TabContainer/Achievements/list.is_anything_selected():return
	all_data["achievements"].remove($TabContainer/Achievements/list.get_selected_items()[0])
	$TabContainer/Achievements/data/name_of.text = ''
	$TabContainer/Achievements/data/description.text = ''
	for item in $TabContainer/Achievements/data/requirements.get_item_count():
		$TabContainer/Achievements/data/requirements.remove_item(0)
	$TabContainer/Achievements/data/TextureRect.texture = null
	$TabContainer/Achievements/list.remove_item($TabContainer/Achievements/list.get_selected_items()[0])


func _on_confirm_achievement_pressed():
	var new_achievement_name = $TabContainer/Achievements/add_achievement_panel/new_name_a.text
	if all_data["achievements"].has(new_achievement_name):return
	all_data["achievements"].append(
		[
		new_achievement_name,
		"res://Assets/Textures/Entities/Characters/Char0.png",
		{},
		$TabContainer/Achievements/add_achievement_panel/new_desc_a.text
		])
	$TabContainer/Achievements/add_achievement_panel.hide()
	update_achievement_list()


func _on_cancel_achievment_pressed():
	$TabContainer/Achievements/add_achievement_panel.hide()

func _on_save_all_data_pressed():
	file.close()
	call_deferred('save_achievements')
func save_achievements():
	file.open(data_path+"achievements.dat",File.WRITE)
	file.store_line(var2str(all_data["achievements"]))
	file.close()
	call_deferred('enemy_save')
func enemy_save():
	file.open(data_path+"enemy_data.dat",File.WRITE)
	file.store_line(var2str(all_data["enemies"]))
	file.close()
	call_deferred('character_save')
func character_save():
	file.open(data_path+"character_data.dat",File.WRITE)
	file.store_line(var2str(all_data["characters"]))
	file.close()
	call_deferred('card_save')
func card_save():
	file.open(data_path+"card_data.dat",File.WRITE)
	file.store_line(var2str(all_data["cards"]))
	file.close()
	call_deferred('level_save')
func level_save():
	file.open(data_path+"level_dat.dat",File.WRITE)
	file.store_line(var2str(all_data["levels"]))
	file.close()


var cur_card = -1
var active_card_data = []
func _on_card_list_item_selected(index):
	$TabContainer/Cards/data/name_of.text = $TabContainer/Cards/card_list.get_item_text(index)
# warning-ignore:shadowed_variable
	var cur_card = all_data["cards"].values()[index]
	$TabContainer/Cards/data/description.text = str(cur_card[1])
	$TabContainer/Cards/data/show_text.text = str(cur_card[1])
	$TabContainer/Cards/data/attribute.text = str(cur_card[4])
	$TabContainer/Cards/data/min_val.text = str(cur_card[3][1])
	$TabContainer/Cards/data/max_val.text = str(cur_card[3][2])
	$TabContainer/Cards/data/TextureRect.self_modulate = cur_card[5]
	$TabContainer/Cards/data/ColorPickerButton.color = cur_card[5]
	active_card_data = cur_card
	$TabContainer/Cards/data/card_type.select(-1)
	for card_type in $TabContainer/Cards/data/card_type.get_item_count():
		if $TabContainer/Cards/data/card_type.get_item_text(card_type) == cur_card[0]:
			$TabContainer/Cards/data/card_type.select(card_type)
			break
			

func update_card_data():
	var card_image = preload("res://Assets/Textures/card_base.png")
	for item in $TabContainer/Cards/card_list.get_item_count():
		$TabContainer/Cards/card_list.remove_item(0)
	for card in all_data["cards"].keys():
		$TabContainer/Cards/card_list.add_item(card,card_image)
func _on_Save_card_pressed():
	if !$TabContainer/Cards/card_list.is_anything_selected():return
	var selected_card = $TabContainer/Cards/card_list.get_item_text($TabContainer/Cards/card_list.get_selected_items()[0])
	all_data["cards"][selected_card] = active_card_data
	load_card_list()


func _on_max_val_text_changed(new_text):
	active_card_data[3][2] = int(new_text)
	if str(int(new_text)) != new_text:
		$TabContainer/Cards/data/max_val.text = str(int(new_text))


func _on_min_val_text_changed(new_text):
	active_card_data[3][1] = int(new_text)
	if str(int(new_text)) != new_text:
		$TabContainer/Cards/data/min_val.text = str(int(new_text))


func _on_show_text_text_changed():
	active_card_data[1] = $TabContainer/Cards/data/show_text.text.replace("\n",'')
	$TabContainer/Cards/data/description.text = $TabContainer/Cards/data/show_text.text.replace("\n",'')


func _on_attribute_text_changed(new_text):
	active_card_data[4] = new_text
const card_converter = {"ATTACK":"HURT","HEAL":"HEAL","DEFEND":"DEFEND"}

func _on_card_type_item_selected(index):
	active_card_data[0] = $TabContainer/Cards/data/card_type.get_item_text(index)
	active_card_data[2] = card_converter[$TabContainer/Cards/data/card_type.get_item_text(index)]


func _on_remove_card_pressed():
	if !$TabContainer/Cards/card_list.is_anything_selected():return
	var card_name = $TabContainer/Cards/card_list.get_item_text($TabContainer/Cards/card_list.get_selected_items()[0])
	all_data["cards"].erase(card_name)
	update_card_data()


func _on_confirm_make_card_pressed():
	if !all_data["cards"].has($TabContainer/Cards/new_card_panel/new_card_name.text):
		all_data["cards"][$TabContainer/Cards/new_card_panel/new_card_name.text]=[
			"ATTACK",
			$TabContainer/Cards/new_card_panel/new_card_desc.text,
			"HURT",
			[ "random", -5, -10 ],
			"PHYSICAL",
			Color(1.0,1.0,1.0,1.0) ]
	$TabContainer/Cards/new_card_panel.hide()
	update_card_data()


func _on_cancel_make_card_pressed():
	$TabContainer/Cards/new_card_panel.hide()


func _on_new_card_pressed():
	$TabContainer/Cards/new_card_panel/new_card_name.text = ""
	$TabContainer/Cards/new_card_panel/new_card_desc.text = ""
	$TabContainer/Cards/new_card_panel.show()

var char_selected = {}
func _on_char_list_item_selected(index):
	char_selected = all_data["characters"][index]
	$TabContainer/Characters/data/strength_c.text = str(char_selected["STRENGTHS"][0]).replace("[",'').replace(']','').replace(' ','')
	$TabContainer/Characters/data/weakness_c.text = str(char_selected["STRENGTHS"][1]).replace("[",'').replace(']','').replace(' ','')
	$TabContainer/Characters/data/name_of.text = str(char_selected["Name"])
	$TabContainer/Characters/data/char_name.text = str(char_selected["Name"])
	$TabContainer/Characters/data/char_health.text = str(char_selected["Default_Stats"][3])
	$TabContainer/Characters/data/char_def.text = str(char_selected["Default_Stats"][0])
	$TabContainer/Characters/data/char_sup.text = str(char_selected["Default_Stats"][1])
	$TabContainer/Characters/data/char_str.text = str(char_selected["Default_Stats"][2])
	$TabContainer/Characters/data/TextureRect.texture = load(char_selected["Icon"])
	$TabContainer/Characters/data/TextureRect/change_char_tex.show()
	for item in $TabContainer/Characters/data/owned_cards.get_item_count():
		$TabContainer/Characters/data/owned_cards.remove_item(0)
	for card in char_selected["Cards"].keys():
		$TabContainer/Characters/data/owned_cards.add_item(card+": "+str(char_selected["Cards"][card]))
	


func _on_c_amount_text_changed(new_text):
	if str(int(new_text)) != new_text:
		$TabContainer/Characters/add_chard_char_panel/c_amount.text = str(int(new_text))


func _on_char_add_card_pressed():
	if !$TabContainer/Characters/char_list.is_anything_selected():return
	$TabContainer/Characters/add_chard_char_panel.show()


func _on_char_remove_card_pressed():
	if !$TabContainer/Characters/data/owned_cards.is_anything_selected():return
	char_selected["Cards"].erase($TabContainer/Characters/data/owned_cards.get_item_text($TabContainer/Characters/data/owned_cards.get_selected_items()[0]).split(": ")[0])
	$TabContainer/Characters/data/owned_cards.remove_item($TabContainer/Characters/data/owned_cards.get_selected_items()[0])


func _on_cancel_add_card_char2_pressed():
	$TabContainer/Characters/add_chard_char_panel.hide()


func _on_select_texture_char_file_selected(path):
	if !$TabContainer/Characters/char_list.is_anything_selected():return
	char_selected["Icon"] = path
	$TabContainer/Characters/data/TextureRect.texture = load(path)
	$TabContainer/Characters/char_list.set_item_icon($TabContainer/Characters/char_list.get_selected_items()[0],load(path))


func _on_change_char_tex_pressed():
	$TabContainer/Characters/select_texture_char.current_path = "res://Assets/Textures/"
	$TabContainer/Characters/select_texture_char.get_child(7).get_child(0).emit_signal('pressed')
	$TabContainer/Characters/select_texture_char.show()
	call_deferred('delayed_button_char')
func delayed_button_char():
	$TabContainer/Characters/select_texture_char.get_child(3).get_child(0).get_child(5).emit_signal("button_down")
	$TabContainer/Characters/select_texture_char.get_child(3).get_child(0).get_child(5).emit_signal("button_up")
	$TabContainer/Characters/select_texture_char.get_child(3).get_child(0).get_child(5).emit_signal("pressed")


func _on_confirm_add_card_char_pressed():
	if $TabContainer/Characters/add_chard_char_panel/c_name.text == "ADD CARD":return
	var can_do = true
	var card_name = $TabContainer/Characters/add_chard_char_panel/c_name.text
	for item in $TabContainer/Characters/data/owned_cards.get_item_count():
		if $TabContainer/Characters/data/owned_cards.get_item_text(item).split(": ")[0] == $TabContainer/Characters/add_chard_char_panel/c_name.text:
			can_do = false
			break
	if !all_data["cards"].has(card_name):can_do = false
	if can_do:
		char_selected["Cards"][card_name] = int($TabContainer/Characters/add_chard_char_panel/c_amount.text)
	$TabContainer/Characters/add_chard_char_panel.hide()
	$TabContainer/Characters/data/owned_cards.add_item(card_name+": "+$TabContainer/Characters/add_chard_char_panel/c_amount.text)


func _on_char_sup_text_changed(new_text):
	if str(int(new_text)) != new_text:
		new_text = str(int(new_text))
	char_selected["Support"] = int(new_text)
	char_selected["Default_Stats"][1] = int(new_text)

func _on_char_def_text_changed(new_text):
	if str(int(new_text)) != new_text:
		new_text = str(int(new_text))
	char_selected["Defense"] = int(new_text)
	char_selected["Default_Stats"][0] = int(new_text)

func _on_char_str_text_changed(new_text):
	if str(int(new_text)) != new_text:
		new_text = str(int(new_text))
	char_selected["Strength"] = int(new_text)
	char_selected["Default_Stats"][2] = int(new_text)


func _on_char_health_text_changed(new_text):
	if str(int(new_text)) != new_text:
		new_text = str(int(new_text))
	char_selected["Health"] = int(new_text)
	char_selected["Default_Stats"][3] = int(new_text)


func _on_char_name_text_changed(new_text):
	$TabContainer/Characters/data/name_of.text = new_text
	char_selected["Name"] = new_text


func _on_Save_char_pressed():
	if !$TabContainer/Characters/char_list.is_anything_selected():return
	var selected_card = $TabContainer/Characters/char_list.get_selected_items()[0]
	for val in char_selected["Level_Rate"].size():
		char_selected["Level_Rate"][val] = round(char_selected["Default_Stats"][val]/10+0.5)
	all_data["characters"][selected_card] = char_selected
	$TabContainer/Characters/char_list.set_item_text(selected_card,$TabContainer/Characters/data/char_name.text)
	$TabContainer/Characters/char_list.set_item_icon(selected_card,$TabContainer/Characters/data/TextureRect.texture)

var enem_selected = {}
func _on_select_texture_enemy_file_selected(path):
	if !$TabContainer/Enemies/enemy_list.is_anything_selected():return
	enem_selected["Icon"] = path
	$TabContainer/Enemies/data/TextureRect.texture = load(path)
	$TabContainer/Enemies/enemy_list.set_item_icon($TabContainer/Enemies/enemy_list.get_selected_items()[0],load(path))



func _on_cancel_add_card_enemy_pressed():
	$TabContainer/Enemies/add_chard_enemy_panel.hide()


func _on_confirm_add_card_enemy_pressed():
	var can_do = true
	var card_name = $TabContainer/Enemies/add_chard_enemy_panel/e_name.text
	for item in $TabContainer/Enemies/data/owned_cards.get_item_count():
		if $TabContainer/Enemies/data/owned_cards.get_item_text(item).split(": ")[0] == card_name:
			can_do = false
			break
	if !all_data["cards"].has(card_name):can_do = false
	if can_do:
		enem_selected["Cards"].append($TabContainer/Enemies/add_chard_enemy_panel/e_name.text)
	update_card_list_enemy()
	$TabContainer/Enemies/add_chard_enemy_panel.hide()

func update_card_list_enemy():
	for item in $TabContainer/Enemies/data/owned_cards.get_item_count():
		$TabContainer/Enemies/data/owned_cards.remove_item(0)
	for card in enem_selected["Cards"]:
		$TabContainer/Enemies/data/owned_cards.add_item(card)


func _on_Save_enemy_pressed():
	if !$TabContainer/Enemies/enemy_list.is_anything_selected():return
	var selected_card = $TabContainer/Enemies/enemy_list.get_selected_items()[0]
	all_data["enemies"][selected_card] = enem_selected
	update_enemy_list()


func _on_enemy_remove_card_pressed():
	if !$TabContainer/Enemies/data/owned_cards.is_anything_selected():return
	enem_selected["Cards"].erase($TabContainer/Enemies/data/owned_cards.get_item_text($TabContainer/Enemies/data/owned_cards.get_selected_items()[0]).split(": ")[0])
	$TabContainer/Enemies/data/owned_cards.remove_item($TabContainer/Enemies/data/owned_cards.get_selected_items()[0])



func _on_enemy_add_card_pressed():
	if !$TabContainer/Enemies/enemy_list.is_anything_selected():return
	$TabContainer/Enemies/add_chard_enemy_panel.show()



func _on_enemy_sup_text_changed(new_text):
	if str(int(new_text)) != new_text:
		new_text = str(int(new_text))
	enem_selected["Stats"][1] = int(new_text)
	enem_selected["Support"] = int(new_text)


func _on_enemy_def_text_changed(new_text):
	if str(int(new_text)) != new_text:
		new_text = str(int(new_text))
	enem_selected["Stats"][0] = int(new_text)
	enem_selected["Defense"] = int(new_text)


func _on_enemy_str_text_changed(new_text):
	if str(int(new_text)) != new_text:
		new_text = str(int(new_text))
	enem_selected["Stats"][2] = int(new_text)
	enem_selected["Strength"] = int(new_text)

func _on_enemy_health_text_changed(new_text):
	if str(int(new_text)) != new_text:
		new_text = str(int(new_text))
	enem_selected["Stats"][3] = int(new_text)


func _on_enemy_name_text_changed(new_text):
	$TabContainer/Enemies/data/name_of.text = new_text
	enem_selected["Name"] = new_text


func _on_change_enemy_tex_pressed():
	$TabContainer/Enemies/select_texture_enemy.current_path = "res://Assets/Textures/"
	$TabContainer/Enemies/select_texture_enemy.get_child(7).get_child(0).emit_signal('pressed')
	$TabContainer/Enemies/select_texture_enemy.show()
	call_deferred('delayed_button_enemy')
func delayed_button_enemy():
	$TabContainer/Enemies/select_texture_enemy.get_child(3).get_child(0).get_child(5).emit_signal("button_down")
	$TabContainer/Enemies/select_texture_enemy.get_child(3).get_child(0).get_child(5).emit_signal("button_up")
	$TabContainer/Enemies/select_texture_enemy.get_child(3).get_child(0).get_child(5).emit_signal("pressed")


func _on_enemy_list_item_selected(index):
	enem_selected = all_data["enemies"][index]
	for item in $TabContainer/Enemies/data/name_of.get_item_count():
		$TabContainer/Enemies/data/name_of.remove_item(0)
	for Name in enem_selected["Name"]:
		$TabContainer/Enemies/data/name_of.add_item(Name)
	$TabContainer/Enemies/data/enemy_health.text = str(enem_selected["Stats"][3])
	$TabContainer/Enemies/data/enemy_def.text = str(enem_selected["Stats"][0])
	$TabContainer/Enemies/data/enemy_sup.text = str(enem_selected["Stats"][1])
	$TabContainer/Enemies/data/enemy_str.text = str(enem_selected["Stats"][2])
	$TabContainer/Enemies/data/TextureRect.texture = load(enem_selected["Icon"])
	$TabContainer/Enemies/data/enemy_id.text = enem_selected["ID"]
	$TabContainer/Enemies/data/strength.text = str(enem_selected["Stats"][4]).replace("[",'').replace(']','').replace(' ','')
	$TabContainer/Enemies/data/weakness.text = str(enem_selected["Stats"][5]).replace("[",'').replace(']','').replace(' ','')
	$TabContainer/Enemies/data/TextureRect/change_enemy_tex.show()
	for item in $TabContainer/Enemies/data/owned_cards.get_item_count():
		$TabContainer/Enemies/data/owned_cards.remove_item(0)
	for card in enem_selected["Cards"]:
		$TabContainer/Enemies/data/owned_cards.add_item(card)
	


func _on_enem_add_name_pressed():
	if !enem_selected["Name"].has($TabContainer/Enemies/data/enemy_name.text):
		enem_selected["Name"].append($TabContainer/Enemies/data/enemy_name.text)
	$TabContainer/Enemies/data/name_of.add_item($TabContainer/Enemies/data/enemy_name.text)
	$TabContainer/Enemies/data/enemy_name.text = ""


var selected_name = 0
func _on_enem_remove_name_pressed():
	if !$TabContainer/Enemies/data/name_of.is_anything_selected():return
	var to_remove = $TabContainer/Enemies/data/name_of.get_item_text(selected_name)
	$TabContainer/Enemies/data/name_of.remove_item(selected_name)
	enem_selected["Name"].erase(to_remove)


func _on_enem_add_name2_pressed():
	if !all_data.has("enemies"):all_data["enemies"] = []
	all_data["enemies"].append({
"Cards": [ "Punch", "Heals" ],
"Icon": "res://Assets/Textures/Entities/Characters/green_slime.png",
"Name": [ "Victor" ],
"Stats": [ 1, 1, 1, 10, "null", "PHYSICAL" ],
"ID":"Slime"
})
	
	update_enemy_list()
func update_enemy_list():
	for item in $TabContainer/Enemies/enemy_list.get_item_count():
		$TabContainer/Enemies/enemy_list.remove_item(0)
	for enemy in all_data["enemies"]:
		$TabContainer/Enemies/enemy_list.add_item(enemy["ID"],load(enemy["Icon"]))

func _on_enem_remove_name2_pressed():
	if !$TabContainer/Enemies/enemy_list.is_anything_selected():return
	all_data["enemies"].remove($TabContainer/Enemies/enemy_list.get_selected_items()[0])
	$TabContainer/Enemies/enemy_list.remove_item($TabContainer/Enemies/enemy_list.get_selected_items()[0])


func _on_enemy_id_text_changed(new_text):
	enem_selected["ID"] = new_text


func _on_char_add_name3_pressed():
	all_data["characters"].append({
"Cards": {
"Heals": 1,
"Punch": 3,
"Shield": 1
},
"Default_Stats": [ 10, 10, 10, 40 ],
"Defense": 10,
"Health": 40,
"Icon": "res://Assets/Textures/Entities/Characters/Char0.png",
"Level_Rate": [ 1, 1, 2, 5 ],
"Name": "Dave",
"STRENGTHS": [ "null", "null" ],
"Strength": 10,
"Support": 10
})
	update_character_list()
func update_character_list():
	for item in $TabContainer/Characters/char_list.get_item_count():
		$TabContainer/Characters/char_list.remove_item(0)
	for character in all_data["characters"]:
		$TabContainer/Characters/char_list.add_item(character["Name"],load(character["Icon"]))

func _on_char_remove_name3_pressed():
	if !$TabContainer/Characters/char_list.is_anything_selected():return
	var selected = $TabContainer/Characters/char_list.get_selected_items()[0]
	all_data["characters"].remove(selected)
	$TabContainer/Characters/char_list.remove_item(selected)
	


func _on_enemy_name_text_entered(new_text):
	_on_enem_add_name_pressed()


func _on_ColorPickerButton_color_changed(color):
	if !$TabContainer/Cards/card_list.is_anything_selected():return
	var selected = $TabContainer/Cards/card_list.get_item_text($TabContainer/Cards/card_list.get_selected_items()[0])
	$TabContainer/Cards/data/TextureRect.self_modulate = color
	all_data["cards"][selected][5] = color


func _on_cancel_add_card_char_pressed():
	$TabContainer/Characters/add_chard_char_panel.hide()

var level_selected = {}
func change_to_levels():
	for item in $TabContainer/Levels/Data/enemys_in/add_enemy_to_list.get_item_count():
		$TabContainer/Levels/Data/enemys_in/add_enemy_to_list.remove_item(0)
	$TabContainer/Levels/Data/enemys_in/add_enemy_to_list.add_item("Add",-1)
	for enem_num in all_data["enemies"].size():
		var enem = all_data["enemies"][enem_num]
		$TabContainer/Levels/Data/enemys_in/add_enemy_to_list.add_item(str(enem_num)+"_"+str(enem["ID"]))


func _on_min_text_changed(new_text):
	if str(int(new_text)) != new_text:
		$TabContainer/Levels/Data/Lvl_Range/min.text = str(int(new_text))
	level_selected["levels"][0] = int(new_text)


func _on_max_text_changed(new_text):
	if str(int(new_text)) != new_text:
		$TabContainer/Levels/Data/Lvl_Range/max.text = str(int(new_text))
	level_selected["levels"][1] = int(new_text)
	


func _on_remove_enemy_from_list_pressed():
	if !$TabContainer/Levels/Data/enemys_in/enemies.is_anything_selected() || !$TabContainer/Levels/Level_List.is_anything_selected():return
	var selected = $TabContainer/Levels/Data/enemys_in/enemies.get_selected_items()[0]
	level_selected["enemies"].erase(int($TabContainer/Levels/Data/enemys_in/enemies.get_item_text(selected).split(": ")[0]))
	$TabContainer/Levels/Data/enemys_in/enemies.remove_item(selected)


func _on_TabContainer_tab_selected(tab):
	if tab == 4:change_to_levels()


func _on_add_enemy_to_list_item_selected(index):
	if !$TabContainer/Levels/Level_List.is_anything_selected()||$TabContainer/Levels/Data/enemys_in/enemy_ratio.text == ""||level_selected["enemies"].keys().has($TabContainer/Levels/Data/enemys_in/add_enemy_to_list.get_item_text(index).split("_")[0]) || index == -1:
		$TabContainer/Levels/Data/enemys_in/add_enemy_to_list.call_deferred('select',0)
		$TabContainer/Levels/Data/enemys_in/add_enemy_to_list.text = "Add"
		return
	var selected = $TabContainer/Levels/Data/enemys_in/add_enemy_to_list.get_item_text(index)
	selected = selected.split("_")[0]
	$TabContainer/Levels/Data/enemys_in/enemies.add_item(selected+": "+$TabContainer/Levels/Data/enemys_in/enemy_ratio.text)
	if !level_selected["enemies"].has(int(selected)):level_selected["enemies"][int(selected)] = 0
	level_selected["enemies"][int(selected)] += int($TabContainer/Levels/Data/enemys_in/enemy_ratio.text)
	$TabContainer/Levels/Data/enemys_in/add_enemy_to_list.text = "Add"
	$TabContainer/Levels/Data/enemys_in/add_enemy_to_list.call_deferred('select',0)
	for item in $TabContainer/Levels/Data/enemys_in/enemies.get_item_count():
		$TabContainer/Levels/Data/enemys_in/enemies.remove_item(0)
	for enemy in level_selected["enemies"].keys():
		$TabContainer/Levels/Data/enemys_in/enemies.add_item(str(enemy)+": "+str(level_selected["enemies"][enemy]))


func _on_Level_List_item_selected(index):
	var selected = $TabContainer/Levels/Level_List.get_item_text($TabContainer/Levels/Level_List.get_selected_items()[0])
	level_selected = all_data["levels"][index]
	$TabContainer/Levels/Data/Lvl_Range/min.text = str(level_selected["levels"][0])
	$TabContainer/Levels/Data/Lvl_Range/max.text = str(level_selected["levels"][1])
	$TabContainer/Levels/Data/level_song.text = level_selected["level_song"][0]
	$TabContainer/Levels/Data/level_db_offset.text = str(level_selected["level_song"][1])
	$TabContainer/Levels/Data/level_name/name_label.text = level_selected["Name"]
	if !level_selected.has("level_tileset"):level_selected["level_tileset"] = "dungeon"
	$TabContainer/Levels/Data/level_tileset.text = level_selected["level_tileset"]
	for item in $TabContainer/Levels/Data/enemys_in/enemies.get_item_count():
		$TabContainer/Levels/Data/enemys_in/enemies.remove_item(0)
	for enemy_count in level_selected["enemies"].keys():
		$TabContainer/Levels/Data/enemys_in/enemies.add_item(str(enemy_count)+": "+str(level_selected["enemies"][enemy_count]))


func _on_enemy_ratio_text_changed(new_text):
	if str(int(new_text)) != new_text:
		new_text = str(int(new_text))


func _on_Save_level_pressed():
	if !$TabContainer/Levels/Level_List.is_anything_selected():return
	var selected_level = $TabContainer/Levels/Level_List.get_selected_items()[0]
	all_data["levels"][selected_level] = level_selected


func _on_new_level_pressed():
	all_data["levels"].append(
		{
"Name": "Level_0",
"enemies": {
0: 3,
1: 1
},
"levels": [ 1, 10 ],
"level_song":["song_0",-10],
"level_hidden":false
})
	update_level_list()
func update_level_list():
	for item in $TabContainer/Levels/Level_List.get_item_count():
		$TabContainer/Levels/Level_List.remove_item(0)
	for level in all_data["levels"]:
		$TabContainer/Levels/Level_List.add_item(level["Name"])


func _on_remove_level_pressed():
	if !$TabContainer/Levels/Level_List.is_anything_selected():return
	var selected_level = $TabContainer/Levels/Level_List.get_selected_items()[0]
	all_data["levels"].erase(selected_level)
	update_level_list()


func _on_name_edit_text_changed(new_text):
	$TabContainer/Levels/Data/level_name/name_label.text = new_text
	level_selected["Name"] = new_text


func _on_strength_text_changed(new_text):
	if new_text != "":enem_selected["Stats"][4] = new_text.split(",")
	else:enem_selected["Stats"][4] = "null"


func _on_weakness_text_changed(new_text):
	if new_text != "":enem_selected["Stats"][5] = new_text.split(",")
	else:enem_selected["Stats"][5] = "null"


func _on_weakness_c_text_changed(new_text):
	if new_text != "":char_selected["STRENGTHS"][1] = new_text.split(",")
	else:char_selected["STRENGTHS"][1] = "null"


func _on_strength_c_text_changed(new_text):
	if new_text != "":char_selected["STRENGTHS"][0] = new_text.split(",")
	else:char_selected["STRENGTHS"][0] = "null"

func load_card_list():
	for item in $TabContainer/Characters/add_chard_char_panel/c_name.get_item_count():
		$TabContainer/Characters/add_chard_char_panel/c_name.remove_item(0)
	for card in all_data["cards"].keys():
		$TabContainer/Characters/add_chard_char_panel/c_name.add_item(card)
	$TabContainer/Characters/add_chard_char_panel/c_name.text = "ADD CARD"


func _on_level_song_text_changed(new_text):
	level_selected["level_song"][0] = new_text


func _on_level_db_offset_text_changed(new_text):
	if str(int(new_text)) != new_text:
		$TabContainer/Levels/Data/level_db_offset.text = str(int(new_text))
	level_selected["level_song"][1] = int(new_text)
		


func _on_level_tileset_text_changed(new_text):
	level_selected["level_tileset"] = new_text




func _on_level_hidden_toggled(button_pressed):
	level_selected["level_hidden"] = button_pressed


func _on_name_of_item_selected(index):
	selected_name = index
