extends KinematicBody2D

const SPEED = 80
const ACCELERATION = 160
const TIME_BETWEEN_FIRING = 0.5

onready var sprite = $Tank/AnimatedSprite
onready var tank = $Tank
onready var cannonTimer = $CannonTimer

var allowed_to_fire = true
var velocity = Vector2.ZERO
var last_input = Vector2.UP

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	match input_vector:
		Vector2.UP:
			update_velocity(0, 0, delta, input_vector)
		Vector2.RIGHT:
			update_velocity(90, 1, delta, input_vector)
		Vector2.DOWN:
			update_velocity(180, 0, delta, input_vector)
		Vector2.LEFT:
			update_velocity(-90, 1, delta, input_vector)
		Vector2.ZERO:
			sprite.playing = false
			velocity = Vector2.ZERO
		
	velocity = move_and_slide(velocity)
	
	if Input.is_action_just_pressed("shoot"):
		if allowed_to_fire:
			allowed_to_fire = false
			tank.fire_shell(global_position, last_input)
			cannonTimer.start()

func update_velocity(degrees, vector_idx_to_clear, delta, input_vector):
	sprite.playing = true
	rotation_degrees = degrees
	velocity = velocity.move_toward(input_vector * SPEED, delta * ACCELERATION)
	velocity[vector_idx_to_clear] = 0
	last_input = input_vector

func _on_Stats_on_zero_health():
	OS.alert("DEAD")
	get_tree().quit()

func _on_CannonTimer_timeout():
	allowed_to_fire = true

func _on_Stats_max_shells_in_flight_changed(value):
	match value:
		1:
			sprite.play("Normal")
		2:
			sprite.play("Upgrade1")
		3:
			sprite.play("Upgrade2")
