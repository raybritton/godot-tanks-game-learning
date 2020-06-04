extends Node2D

const Tree = preload("res://World/Tree.tscn")
const InvincibleBrick = preload("res://World/InvincibleBrick.tscn")
const Brick = preload("res://World/Brick.tscn")
const Water = preload("res://World/Water.tscn")
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
onready var enemySpawnLocations = [$Map/EnemySpawnArea1, $Map/EnemySpawnArea2, $Map/EnemySpawnArea3, $Map/EnemySpawnArea4]

var enemies = [];
var lastEnemySpawnIdx = -1

func _ready():
	randomize()
	camera.update_limits(0, 0, MAP_WIDTH, MAP_HEIGHT)
	
	for i in range(0, 4):
		enemySpawnLocations[i].position = ENEMY_SPAWN_LOCATIONS[i]
		print(enemySpawnLocations[i].position)
	
	var horz_tiles = MAP_WIDTH / TREE_SIZE
	var vert_tiles = MAP_HEIGHT / TREE_SIZE
	
	add_rect_of_nodes(0, 0, horz_tiles, vert_tiles, TREE_SIZE, "spawnTree")
	add_rect_of_nodes(1, 1, horz_tiles - 1, vert_tiles - 1, TREE_SIZE, "spawnTree")
	add_rect_of_nodes(2, 2, horz_tiles - 2, vert_tiles - 2, TREE_SIZE, "spawnInvincibleBrickBlock")
	
	# ' ' nothing
	# * tough brick
#	var levelData = ResourceLoader.load("res://Levels/level_1.tres") as TextFile
	
	var level = File.new()
	level.open("res://Levels/level1.tres", level.READ)
		
	var data = []
	while not level.eof_reached():
		var line = level.get_line()
		if line.begins_with("="):
			data.push_back(line.substr(1))
	
	validate(data)
	load_level(data)

func validate(data):
	var prefix = "Map parse error: "
	if data.size() != 20:
		push_error(prefix + "map must be 20 lines long")
		get_tree().quit()
	var lineIdx = 0
	for line in data:
		lineIdx = lineIdx + 1
		if line.length() != 20:
			push_error(prefix + "each map line must have 20 characters after the =")
			get_tree().quit()	
	if data[0].substr(0, 1) != " ":
		push_error(prefix + "0, 0 must be empty")
		get_tree().quit()
	if data[0].substr(19, 1) != " ":
		push_error(prefix + "19, 0 must be empty")
		get_tree().quit()
		
func load_level(data):
	var offset = 3
	var lineIdx = -1
	for line in data:
		lineIdx = lineIdx + 1
		for i in range(0, 19):
			var x = (i + offset) * TREE_SIZE
			var y = (lineIdx + offset) * TREE_SIZE
			match line.substr(i, 1):
				"#":
					spawnBrickBlock(x, y)
				"+":
					spawnInvincibleBrickBlock(x, y)
				"~":
					spawnWater(x, y)
		

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
	
func spawnWater(x, y):
	var water = Water.instance()
	background.add_child(water)
	water.global_position = Vector2(x, y)
	
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
	clear_up_tanks()
	if enemies.size() < MAX_ENEMIES:
		
		#make a list of empty spawn locations
		var valid_spawns = [];
		for i in range(0, 4):
			if !enemySpawnLocations[i].is_full():
				valid_spawns.push_front(i)
				
		#remove the last spawn location, if there's at least one other spawn location available
		if valid_spawns.size() > 1:
			for idx in valid_spawns:
				if idx == lastEnemySpawnIdx:
					valid_spawns.erase(idx)
		
		var spawnAtIdx = valid_spawns[rand_range(0, valid_spawns.size())]
		
		var spawnAt = ENEMY_SPAWN_LOCATIONS[spawnAtIdx]
		
		var tank = Tank.instance()
		tanks.add_child(tank)
		tank.global_position = spawnAt
		enemies.push_back(weakref(tank))

func clear_up_tanks():
	for item in enemies:
		if !item.get_ref():
			enemies.erase(item)
