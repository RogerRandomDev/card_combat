extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func add_energy(val):
	update_energy(max(min($Energy.max_value,$Energy.value+val),0))

func update_energy(val):
	$Energy.value = val
