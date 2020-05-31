extends KinematicBody2D

const SPEED = 2

export(int) var damage = 1
var direction = Vector2.ZERO

func _physics_process(delta):
	assert(direction != Vector2.ZERO)
	
	match direction:
		Vector2.UP:
			rotation_degrees = 0
		Vector2.RIGHT:
			rotation_degrees = 90
		Vector2.DOWN:
			rotation_degrees = 180
		Vector2.LEFT:
			rotation_degrees = -90

	move_and_collide(direction * SPEED)

#Hit tank/brick
func _on_Hitbox_area_entered(area):
	queue_free()

#Hit wall/tree
func _on_Hitbox_body_entered(body):
	queue_free()
