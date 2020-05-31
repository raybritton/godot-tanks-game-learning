extends Node

export(int) var max_health = 1 setget set_max_health
export(int) var health = 1 setget set_health
export(int) var damage = 1 setget set_damage
export(int) var max_shells_in_flight = 1 setget set_max_shells_in_flight
export(bool) var shielded = false setget set_shielded

signal max_health_changed(value)
signal health_changed(value)
signal damage_changed(value)
signal on_zero_health()
signal max_shells_in_flight_changed(value)
signal shielded_changed(value)

func set_max_health(value):
	max_health = max(value, 1)
	emit_signal("max_health_changed", value)
	
func set_health(value):
	health = max(value, 0)
	emit_signal("health_changed", value)
	if health == 0:
		emit_signal("on_zero_health")
	
func set_damage(value):
	damage = max(value, 1)
	emit_signal("damage_changed", value)

func set_max_shells_in_flight(value):
	max_shells_in_flight = value
	emit_signal("max_shells_in_flight_changed", value)

func set_shielded(value):
	shielded = value
	emit_signal("shielded_changed", value)

func hurt(amount):
	self.health -= amount
