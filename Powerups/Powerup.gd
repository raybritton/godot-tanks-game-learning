extends Node2D

const ShieldImage = preload("res://Powerups/shield.png")
const ClearImage = preload("res://Powerups/clear.png")
const FirepowerImage = preload("res://Powerups/firepower.png")

enum Type {
	SHIELD,
	CLEAR,
	FIREPOWER
}

signal on_pick_up

onready var timer = $Timer
onready var sprite = $Sprite

export(Type) var type = null

var player = null

func _ready():
	sprite.texture = get_image()
	
func get_image():
	match type:
		Type.SHIELD:
			return ShieldImage
		Type.CLEAR:
			return ClearImage
		Type.FIREPOWER:
			return FirepowerImage

func random():
	var idx = int(rand_range(0, Type.size()))
	type = Type.values()[idx]

func _on_Powerup_body_entered(body):
	player = body
	timer.start()

func _on_Powerup_body_exited(_body):
	player = null
	timer.stop()

func _on_Timer_timeout():
	if player != null:
		var distance = position.distance_to(player.position)
		if distance < 2:
			match type:
				Type.SHIELD:
					emit_signal("on_pick_up", "shield")
				Type.CLEAR:
					emit_signal("on_pick_up", "clear")
				Type.FIREPOWER:
					emit_signal("on_pick_up", "firepower")
			queue_free()
