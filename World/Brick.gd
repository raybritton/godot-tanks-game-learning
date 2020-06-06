extends StaticBody2D

func _on_Hurtbox_area_entered(area):
	if "hasInteracted" in area:
		if !area.hasInteracted:
			area.hasInteracted = true
			queue_free()
	else:
		var msg = "invalid object collision - self: %s (%s)  obj: %s (%s)"
		push_error(msg % [self, self.get_path(), area, area.get_path()])
