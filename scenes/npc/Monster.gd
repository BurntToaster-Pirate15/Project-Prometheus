extends CharacterBody2D

@export var SPEED = 300.0
@export var spawn_point: Vector2

var is_moving: bool = false
var move_direction: Vector2
var player: CharacterBody2D

signal moved
signal turn_finished

var actions: int = 1

func _ready():
	position = spawn_point
	position = position.snapped(Vector2.ONE * MapProperties.TILESIZE)
	position -= Vector2.ONE * (MapProperties.TILESIZE * 0.5)


func start_turn(grid: TileMap, combatants: Array[CharacterBody2D]):
	actions = 1
	# find player and move towards him one space per turn
	for combatant in combatants:
		if combatant.name == "Player":
			player = combatant
			break
	
	var path: Array = grid.get_grid_path(position, player.position)
	
	
	for tile in path:
		if actions > 0:
			move_grid((path.pop_front() - position).normalized())
			print(actions)
			actions -= 1
			await moved
			break
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
		
		
		var tween: Tween = create_tween()
		tween.tween_property(self, "position", _position, 0.35)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(func(): move_direction = Vector2.ZERO; is_moving = false; moved.emit())


