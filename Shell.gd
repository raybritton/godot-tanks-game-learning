extends KinematicBody2D

const BulletImpact = preload("res://Effects/BulletImpact.tscn")

const SPEED = 2

export(int) var damage = 1
var direction = Vector2.ZERO
var collided = false

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

#Hit hurtbox
func _on_Hitbox_area_entered(area):
	queue_free()

#Hit collision shape
func _on_Hitbox_body_entered(body):
	if collided:
		return
	collided = true
	var cell_size = 8 #hack: this should be obtained from the body
	var bulletImpact = BulletImpact.instance()
	get_parent().add_child(bulletImpact)
	bulletImpact.global_position = body.global_position
	match direction:
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
	queue_free()
