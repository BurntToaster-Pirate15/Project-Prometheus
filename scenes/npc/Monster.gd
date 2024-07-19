extends CharacterBody2D

@export var SPEED = 300.0
@export var spawn_point: Vector2
@export var player: CharacterBody2D


func _ready():
	position = spawn_point
	pass

func start_combat():
	player = $"../player"



func move_toward_player():
	#implement pathfinding
	# use singleton to find player position
	pass
