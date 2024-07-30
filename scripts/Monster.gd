extends CharacterBody2D

@export var SPEED = 300.0
@export var spawn_point: Vector2

@export var path: Array[Vector2]
var index: int = 0

var is_moving: bool = false

var move_direction: Vector2
var player: CharacterBody2D

var occupied_positions: Array[CharacterBody2D]

signal moved
signal turn_finished

var actions: int = 1

func _ready():
	position = spawn_point
	position = position.snapped(Vector2.ONE * MapProperties.TILESIZE)
	position -= Vector2.ONE * (MapProperties.TILESIZE * 0.5)


func start_turn(grid: TileMap, combatants: Array[CharacterBody2D]):
	actions = 1
	index %= path.size() # make index wrap around
	
	# find player and move towards him one space per turn
	for combatant in combatants:
		if combatant.name == "Player":
			player = combatant
			continue
		if combatant == self:
			continue
		occupied_positions.append(combatant)
	

	for occupied_position in occupied_positions:
		grid.grid.set_point_solid(grid.local_to_map(occupied_position.global_position))
	
	var curr_path: Array = grid.get_grid_path(position, player.position)
	if curr_path.is_empty() or len(curr_path) > 10:
		# move with predefined path
		# idle behaviour
		curr_path = grid.get_grid_path(position, path[index])
		if curr_path.is_empty():
			print(position)
			print(path[index])
			
	
	for occupied_position in occupied_positions:
		grid.grid.set_point_solid(grid.local_to_map(occupied_position.global_position), false)

	
		
	
	for tile in path:
		if actions > 0:
			move_grid((grid.map_to_local(curr_path.pop_front()) - position).normalized())
			actions -= 1
			await moved
			break
	
	if global_position == path[index]:
		index += 1 # update index
	turn_finished.emit()

func move_grid(direction: Vector2):
	# there must be a better way...
	# this branching if statement is ugly
	# 			- stealthninja
	if !is_moving && direction.length() > 0:
		var movement: Vector2
		if direction.y < 0:
			movement = Vector2.UP
		elif direction.y > 0:
			movement = Vector2.DOWN
		elif direction.x > 0:
			movement = Vector2.RIGHT
		elif direction.x < 0:
			movement = Vector2.LEFT
	
	
		is_moving = true
		move_direction = movement
		var _position: Vector2 = position + (move_direction * MapProperties.TILESIZE)
		
		if player.position == _position:
			player.take_damage()
			_position = position
		

			
		
		var tween: Tween = create_tween()
		tween.tween_property(self, "position", _position, 1)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(func(): move_direction = Vector2.ZERO; is_moving = false; moved.emit())


