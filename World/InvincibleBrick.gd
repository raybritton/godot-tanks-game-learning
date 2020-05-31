extends StaticBody2D

const BulletImpact = preload("res://Effects/BulletImpact.tscn")

func _on_Hurtbox_area_entered(area):
	var cell_size = 8 #hack: this should be obtained from the body
	var bulletImpact = BulletImpact.instance()
	get_parent().add_child(bulletImpact)
	bulletImpact.global_position = global_position
	match area.get_parent().direction:
		Vector2.UP:
			bulletImpact.rotation_degrees = 90
			bulletImpact.global_position.y += cell_size
			bulletImpact.global_position.x += cell_size
		Vector2.RIGHT:
			bulletImpact.rotation_degrees = 180
			bulletImpact.global_position.y += cell_size
		Vector2.DOWN:
			bulletImpact.rotation_degrees = -90
		Vector2.LEFT:
			bulletImpact.rotation_degrees = 0
			bulletImpact.global_position.x += cell_size

