extends CharacterBody2D

@export var SPEED = 300.0
@export var spawn_point: Vector2


func _ready():
	$".".global_position=spawn_point  # move to correct position
	$".".scale=Vector2(0,0)  # make it temporarily invisible until spawn() is called
	spawn()
	pass

# This should get called by combat manager
func spawn():
	#play spawn animation
	$".".scale=Vector2(1,1)
	
	#move camera	
	pass

func move_toward_player():
	#implement pathfinding
	# use singleton to find player position
	pass
