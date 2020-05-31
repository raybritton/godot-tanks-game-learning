extends Node2D

const Shell = preload("res://Shell.tscn")

onready var stats = $Stats
onready var sprite = $AnimatedSprite

var shells_in_flight = []

func _on_Hurtbox_area_entered(area):
	if stats.shielded:
		stats.shielded = false
	else:
		stats.hurt(area.damage)

func _on_Stats_shielded_changed(value):
	if value:
		sprite.modulate = Color(0, 1, 1, 0.5)
	else:
		sprite.modulate = Color(1, 1, 1)

func fire_shell(position, direction):
	clear_up_shells_in_flight()
	if shells_in_flight.size() < stats.max_shells_in_flight:
		var shell_pos_offset = 10
		var shell = Shell.instance()
		get_parent().get_parent().add_child(shell)
		shell.global_position = position
		shell.global_position[0] += direction[0] * shell_pos_offset
		shell.global_position[1] += direction[1] * shell_pos_offset
		shell.damage = stats.damage
		shell.direction = direction
		shells_in_flight.push_back(weakref(shell))

func clear_up_shells_in_flight():
	for item in shells_in_flight:
		if !item.get_ref():
			shells_in_flight.erase(item)
