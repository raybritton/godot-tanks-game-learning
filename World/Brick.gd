extends StaticBody2D

func _on_Hurtbox_area_entered(area):
	if !area.hasInteracted:
		area.hasInteracted = true
		queue_free()
