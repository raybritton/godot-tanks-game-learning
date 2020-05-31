extends Node2D

const Tree = preload("res://World/Tree.tscn")
const InvincibleBrick = preload("res://World/InvincibleBrick.tscn")
const Brick = preload("res://World/Brick.tscn")
const Tank = preload("res://Enemies/EnemyTank.tscn")

export(bool) var debug = true

const MAP_WIDTH = 384
const MAP_HEIGHT = 384
const TREE_SIZE = 16
const BRICK_SIZE = 8
const MAX_ENEMIES = 3

const OFFSET = Vector2(8, 8)

const ENEMY_SPAWN_LOCATIONS = [
	(Vector2(3, 3) * TREE_SIZE) + OFFSET,
	(Vector2(10, 3) * TREE_SIZE) + OFFSET,
	(Vector2(15, 3) * TREE_SIZE) + OFFSET,
	(Vector2(20, 3) * TREE_SIZE) + OFFSET
]

const PLAYER_HOME_LOCATION = Vector2(12, 19) * TREE_SIZE
const PLAYER_SPAWN_LOCATION = Vector2(10, 20) * TREE_SIZE

onready var tanks = $Tanks
onready var background = $Border
onready var camera = $Camera

var enemies = [];

func _ready():
	camera.update_limits(0, 0, MAP_WIDTH, MAP_HEIGHT)
	
	var horz_tiles = MAP_WIDTH / TREE_SIZE
	var vert_tiles = MAP_HEIGHT / TREE_SIZE
	
	add_rect_of_nodes(0, 0, horz_tiles, vert_tiles, TREE_SIZE, "spawnTree")
	add_rect_of_nodes(1, 1, horz_tiles - 1, vert_tiles - 1, TREE_SIZE, "spawnTree")
	add_rect_of_nodes(2, 2, horz_tiles - 2, vert_tiles - 2, TREE_SIZE, "spawnInvincibleBrickBlock")
	
	spawnBrickBlock(4 * TREE_SIZE, 4 * TREE_SIZE)
	spawnBrickBlock(19 * TREE_SIZE, 4 * TREE_SIZE)
	spawnBrickBlock(4 * TREE_SIZE, 19 * TREE_SIZE)
	spawnBrickBlock(19 * TREE_SIZE, 19 * TREE_SIZE)
	
	# ' ' nothing
	# # brick
	# = water
	# * tough brick
	# + invincible brick
	var levelData = ResourceLoader.load("res://Levels/level_1.tres") as TextFile
	

func _process(_delta):
	if debug:
		if Input.is_action_just_pressed("debug1"):
			var current_zoom = int(camera.zoom.x)
			match current_zoom:
				1:
					camera.zoom = Vector2(2,2)
				2:
					camera.zoom = Vector2(3,3)
				3:
					camera.zoom = Vector2(1,1)
		if Input.is_action_just_pressed("debug2"):
			($Tanks/Player/Tank/Stats).set_health(($Tanks/Player/Tank/Stats).max_health)
		if Input.is_action_just_pressed("debug3"):
			($Tanks/Player/Tank/Stats).set_shielded(true)
		if Input.is_action_just_pressed("debug4"):
			($Tanks/Player/Tank/Stats).set_max(3)

func add_rect_of_nodes(start_x, start_y, end_x, end_y, tile_size, method):
	add_vert_line_of_nodes(start_x, start_y, end_y, tile_size, method)
	add_vert_line_of_nodes(end_x - 1, start_y, end_y, tile_size, method)
	add_horz_line_of_nodes(start_y, start_x + 1, end_x - 1, tile_size, method)
	add_horz_line_of_nodes(end_y - 1, start_x + 1, end_x - 1, tile_size, method)

func add_vert_line_of_nodes(x, start_y, end_y, tile_size, method):
	for y in range(start_y, end_y):
		call(method, x * tile_size, y * tile_size)

func add_horz_line_of_nodes(y, start_x, end_x, tile_size, method):
	for x in range(start_x, end_x):
		call(method, x * tile_size, y * tile_size)	

func spawnTree(x, y):
	var tree = Tree.instance()
	background.add_child(tree)
	tree.global_position = Vector2(x, y)
	tree.get_node("Sprite").flip_h = randf() > 0.5
	
func spawnBlock(x, y, scene):
	var invincibleBrickTL = scene.instance()
	var invincibleBrickTR = scene.instance()
	var invincibleBrickBL = scene.instance()
	var invincibleBrickBR = scene.instance()
	background.add_child(invincibleBrickTL)
	background.add_child(invincibleBrickTR)
	background.add_child(invincibleBrickBL)
	background.add_child(invincibleBrickBR)
	invincibleBrickTL.global_position = Vector2(x, y)
	invincibleBrickTR.global_position = Vector2(x, y)
	invincibleBrickTR.global_position.x += BRICK_SIZE
	invincibleBrickBL.global_position = Vector2(x, y)
	invincibleBrickBL.global_position.y += BRICK_SIZE
	invincibleBrickBR.global_position = Vector2(x, y)
	invincibleBrickBR.global_position.x += BRICK_SIZE
	invincibleBrickBR.global_position.y += BRICK_SIZE

func spawnInvincibleBrickBlock(x, y):
	spawnBlock(x, y, InvincibleBrick)

func spawnBrickBlock(x, y):
	spawnBlock(x, y, Brick)

func _on_EnemySpawnTimer_timeout():
	if enemies.size() < MAX_ENEMIES:
		var spawnAtIdx = rand_range(0,3)
		var spawnAt = ENEMY_SPAWN_LOCATIONS[spawnAtIdx]
		
		var tank = Tank.instance()
		tanks.add_child(tank)
		tank.global_position = spawnAt
		enemies.push_back(weakref(tank))

func clear_up_tanks():
	for item in enemies:
		if !item.get_ref():
			enemies.erase(item)
