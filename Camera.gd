extends Camera2D

onready var topLeft = $Limits/TopLeft
onready var bottomRight = $Limits/BottomRight

func _ready():
	apply_limits()

func update_limits(left, top, right, bottom):
	topLeft.position.x = left
	topLeft.position.y = top
	bottomRight.position.x = right
	bottomRight.position.y = bottom
	apply_limits()
	
func apply_limits():
	limit_top = topLeft.position.y
	limit_left = topLeft.position.x
	limit_bottom = bottomRight.position.y
	limit_right = bottomRight.position.x
