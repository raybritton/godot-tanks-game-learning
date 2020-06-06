extends KinematicBody2D

const Explosion = preload("res://Effects/Explosion.tscn")
const Shell = preload("res://Shell.tscn")

enum Type {
	SMALL,
	MEDIUM,
	FAST,
	LARGE
}

export(Type) var type = Type.SMALL

enum State {
	IDLE,
	DRIVE
}

onready var stats = $Tank/Stats
onready var tank = $Tank
onready var shootTimer = $ShootTimer
onready var sprite = $Tank/AnimatedSprite

var enabled = true
var velocity = Vector2.ZERO
var direction = Vector2.DOWN
var state = State.IDLE

func _ready():
	stats.set_max_shells_in_flight(get_max_shells())
	sprite.play(get_animation())
	shootTimer.wait_time = get_wait_time()

func _physics_process(delta):
	if !enabled: 
		return
	if state == State.DRIVE:
		sprite.playing = true
		velocity = velocity.move_toward(direction * get_speed(), delta * get_speed() * 2)
		match direction:
			Vector2.LEFT, Vector2.RIGHT:
				velocity.y = 0
			Vector2.UP, Vector2.DOWN:
				velocity.x = 0
		velocity = move_and_slide(velocity)

func _on_ChangeStateTimer_timeout():
	if !enabled: 
		return
	match int(rand_range(1, 8)):
		1:
			state = State.DRIVE
			direction = Vector2.UP
			rotation_degrees = 0
		2:
			state = State.DRIVE
			direction = Vector2.RIGHT
			rotation_degrees = 90
		3: 
			state = State.DRIVE
			direction = Vector2.DOWN
			rotation_degrees = 180
		4:
			state = State.DRIVE
			direction = Vector2.LEFT
			rotation_degrees = -90
		5, 6, 7, 8:
			state = State.IDLE
			sprite.playing = false

func _on_Stats_on_zero_health():
	die()
	
func die():
	var explosion = Explosion.instance()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	queue_free()

func get_speed():
	if type == Type.FAST:
		return 200
	else:
		return 100
		
func get_max_shells():
	match type:
		Type.SMALL, Type.FAST: 
			return 1
		Type.MEDIUM:
			return 2
		Type.LARGE:
			return 3

func get_animation():
	match type:
		Type.SMALL:
			return "Small"
		Type.LARGE:
			return "Large"

func get_wait_time():
	match type:
		Type.SMALL, Type.FAST:
			return 2
		Type.MEDIUM:
			return 1.6
		Type.LARGE:
			return 1.2

func _on_ShootTimer_timeout():
	if !enabled: 
		return
	if state == State.IDLE:
		tank.fire_shell(global_position, direction, false)
