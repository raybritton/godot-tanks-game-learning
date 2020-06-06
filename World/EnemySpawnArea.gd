extends Area2D

onready var label = $Label

var body_count = 0

func _on_EnemySpawnArea_body_entered(_body):
	body_count += 1
	label.text = str(body_count)

func _on_EnemySpawnArea_body_exited(_body):
	body_count -= 1
	label.text = str(body_count)

func is_full():
	return body_count > 0
