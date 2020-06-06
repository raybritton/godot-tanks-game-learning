extends Node2D

const Tree = preload("res://World/Tree.tscn")
const InvincibleBrick = preload("res://World/InvincibleBrick.tscn")
const Brick = preload("res://World/Brick.tscn")
const Water = preload("res://World/Water.tscn")
const Leaves = preload("res://World/Leaves.tscn")
const Home = preload("res://World/Home.tscn")
const Tank = preload("res://Enemies/EnemyTank.tscn")
const Powerup = preload("res://Powerups/Powerup.tscn")
const EnemySpawnLocation = preload("res://World/EnemySpawnArea.tscn")

export(bool) var debug = true

const MAP_WIDTH = 384
const MAP_HEIGHT = 384
const TREE_SIZE = 16
const BRICK_SIZE = 8
const MAX_ENEMIES = 3

const OFFSET = Vector2(8, 8)

const PLAYER_HOME_LOCATION = Vector2(12, 19) * TREE_SIZE
const PLAYER_SPAWN_LOCATION = Vector2(10, 20) * TREE_SIZE

onready var tanks = $Tanks
onready var background = $Border
onready var camera = $Camera
onready var map = $Map
onready var powerups = $Powerups
onready var pickupSpawnTimer = $PickupSpawnTimer
onready var player = $Tanks/Player
onready var topLayer = $TopLayer

var enemySpawnLocations = []
var pickupSpawnLocations = [];
var enemies = [];
var lastEnemySpawnIdx = -1
var homeSpawned = false
var tanksFrozen = false
var enemiesLeftBeforePowerupSpawn = rand_range(3, 6)

func _ready():
	randomize()
	camera.update_limits(0, 0, MAP_WIDTH, MAP_HEIGHT)
	
	var horz_tiles = MAP_WIDTH / TREE_SIZE
	var vert_tiles = MAP_HEIGHT / TREE_SIZE
	
	add_rect_of_nodes(0, 0, horz_tiles, vert_tiles, TREE_SIZE, "spawnTree")
	add_rect_of_nodes(1, 1, horz_tiles - 1, vert_tiles - 1, TREE_SIZE, "spawnTree")
	add_rect_of_nodes(2, 2, horz_tiles - 2, vert_tiles - 2, TREE_SIZE, "spawnInvincibleBrickBlock")
	
	var levelIdx = get_node("/root/System").levelToLoad
	var level = File.new()
	level.open("res://Levels/level" + str(levelIdx) + ".tres", level.READ)
		
	var data = []
	while not level.eof_reached():
		var line = level.get_line()
		if line.begins_with("="):
			data.push_back(line.substr(1))
	
	validate(data)
	load_level(data)

func validate(data):
	var prefix = "Map parse error: "
	if data.size() != 18:
		push_error(prefix + "map must be 18 lines long")
		get_tree().quit()
	var lineIdx = 0
	for line in data:
		lineIdx = lineIdx + 1
		if line.length() != 18:
			push_error(prefix + "each map line must have exactly 18 characters after the =")
			get_tree().quit()	
		
func load_level(data):
	var offset = 3
	var lineIdx = -1
	for line in data:
		lineIdx = lineIdx + 1
		for i in range(0, 18):
			var x = (i + offset) * TREE_SIZE
			var y = (lineIdx + offset) * TREE_SIZE
			match line.substr(i, 1):
				"#":
					spawnBrickBlock(x, y)
				"+":
					spawnInvincibleBrickBlock(x, y)
				"~":
					spawnWater(x, y)
				"@":
					spawnBrickBlock(x, y)
					pickupSpawnLocations.push_back(Vector2(x, y) + OFFSET)
				"H":
					if !homeSpawned:
						homeSpawned = true
						spawnHome(i + offset, lineIdx + offset)
				"-":
					spawnLeaves(x, y)
				"x":
					var spawner = EnemySpawnLocation.instance()
					map.add_child(spawner)
					spawner.position = Vector2(x, y)
					enemySpawnLocations.push_back(spawner)
				" ":
					pass
				"*":
					player.global_position = Vector2(x, y)
				"": #this might be the newline char
					pass
				_:
					push_error("Invalid letter in map: '" + str(line.substr(i, 1)) + "'")
					get_tree().quit()

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
			pass
		if Input.is_action_just_pressed("debug4"):
			($Tanks/Player/Tank/Stats).set_max(3)
		if Input.is_key_pressed(KEY_CONTROL) && Input.is_key_pressed(KEY_KP_1):
			on_power_up_pick_up("shield")
		if Input.is_key_pressed(KEY_CONTROL) && Input.is_key_pressed(KEY_KP_2):
			on_power_up_pick_up("clear")
		if Input.is_key_pressed(KEY_CONTROL) && Input.is_key_pressed(KEY_KP_3):
			on_power_up_pick_up("firepower")
		if Input.is_key_pressed(KEY_CONTROL) && Input.is_key_pressed(KEY_KP_4):
			on_power_up_pick_up("time")

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

func spawnLeaves(x, y):
	var leaves = Leaves.instance()
	topLayer.add_child(leaves)
	leaves.position = Vector2(x, y)

func spawnHome(x, y):
	if x < 1 || x > 19 || y < 1 || y > 19:
		push_error("Invalid Home, must be block of 4 H")
		get_tree().quit()
	
	var home = Home.instance()
	home.global_position = Vector2(x * TREE_SIZE, y * TREE_SIZE) + Vector2(TREE_SIZE, TREE_SIZE)
	topLayer.add_child(home)
	
	#if x > 1:
	#	add_vert_line_of_nodes(x - 1, y, y + 1, TREE_SIZE, "spawnSingleBrick")
	#if y > 1:
	#	add_horz_line_of_nodes(y, x, x + 1, TREE_SIZE, "spawnSingleBrick")

func spawnSingleBrick(x, y):
	var brick = Brick.instance()
	background.add_child(brick)
	brick.position = Vector2(x, y)

func _on_EnemySpawnTimer_timeout():
	clear_up_tanks()
	if enemies.size() < MAX_ENEMIES:
		
		#make a list of empty spawn locations
		var valid_spawns = [];
		for i in range(0, 4):
			if !enemySpawnLocations[i].is_full():
				valid_spawns.push_front(i)
				
		#remove the previously used spawn location, if there's at least one other spawn location available
		if valid_spawns.size() > 1:
			for idx in valid_spawns:
				if idx == lastEnemySpawnIdx:
					valid_spawns.erase(idx)
		
		var spawnAtIdx = valid_spawns[rand_range(0, valid_spawns.size())]
		
		var spawnAt = enemySpawnLocations[spawnAtIdx].position + OFFSET
		
		var tank = Tank.instance()
		tanks.add_child(tank)
		tank.enabled = !tanksFrozen
		tank.global_position = spawnAt
		enemies.push_back(weakref(tank))

func clear_up_tanks():
	for item in enemies:
		if !item.get_ref():
			enemies.erase(item)
			if enemiesLeftBeforePowerupSpawn == null:
				enemiesLeftBeforePowerupSpawn = rand_range(3, 6)
			enemiesLeftBeforePowerupSpawn -= 1
			if enemiesLeftBeforePowerupSpawn == 0:
				enemiesLeftBeforePowerupSpawn == null
				pickupSpawnTimer.start(rand_range(2, 6))

func spawnPowerUp():
	var powerup = Powerup.instance()
	powerup.random()
	powerups.add_child(powerup)
	powerup.position = calc_power_up_position()
	powerup.connect("on_pick_up", self, "on_power_up_pick_up")
	
func calc_power_up_position():
	var idx = rand_range(0, pickupSpawnLocations.size())
	var position = pickupSpawnLocations[idx]
	pickupSpawnLocations.remove(idx)
	return position
	
func on_power_up_pick_up(type):
	match type:
		"shield":
			player.activate_shield()
		"firepower":
			player.increase_firepower()
		"time":
			tanksFrozen = !tanksFrozen
			for item in enemies:
				if item.get_ref():
					item.get_ref().enabled = tanksFrozen
		"clear":
			for item in enemies:
				if item.get_ref():
					item.get_ref().die()

func _on_PickupSpawnTimer_timeout():
	spawnPowerUp()
