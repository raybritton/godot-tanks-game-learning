extends KinematicBody2D

const Explosion = preload("res://Effects/Explosion.tscn")

const SPEED = 2

export(int) var damage = 1
var direction = Vector2.ZERO

func _physics_process(_delta):
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
func _on_Hitbox_area_entered(_area):
	queue_free()

#Hit wall/tree
func _on_Hitbox_body_entered(_body):
	queue_free()

func _on_ShellHitbox_area_entered(area):
	var explosion = Explosion.instance()
	get_parent().add_child(explosion)
	explosion.scale = Vector2(0.5, 0.5)
	explosion.global_position = global_position
	queue_free()
