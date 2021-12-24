extends CanvasLayer




func apply_motion(val):
	$Particles2D.process_material.direction = (Vector3(-1,1,0)-Vector3(val.x,val.y,0).normalized()*0.5).normalized()
	$Particles2D.process_material.initial_velocity = 64+abs(val.length())
func toggle_leaves(toggled):
	$Particles2D.emitting = toggled
