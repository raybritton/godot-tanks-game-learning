extends Node 

export(int) var lives = 3 setget set_lives

func set_lives(value):
	lives = max(value, 1)
	emit_signal("lives_changed", value)
	
func remove_life():
	self.lives -= 1
