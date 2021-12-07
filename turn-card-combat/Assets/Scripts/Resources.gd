extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func set_energy(val):
	$Energy.max_value = val
	$Energy.value = val

func add_energy(val):
	return update_energy(max(min($Energy.max_value,$Energy.value+val),0))

func update_energy(val):
	$Energy.value = val
	if $Energy.value == 0:return false
	return true
