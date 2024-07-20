extends Node2D

enum TURN {PLAYER, ENEMY}

@export var TURNORDER=TURN.PLAYER

var player: CharacterBody2D
var grid: TileMap
var areas: Array
var in_combat: bool = false



func _on_combat_area_entered(body: Node2D, area: Area2D):
	body.switch_to_grid()
	in_combat = true
	combat_prepare()

# Called when the node enters the scene tree for the first time.
func _ready():
	player = $"../Player"
	grid = $"../TileMap"
	
	for child in get_children():
		child.connect("body_entered", _on_combat_area_entered.bind(child))
		areas.append(child)



func _draw():
	if !in_combat || TURNORDER != TURN.PLAYER:
		return
	
	var mouse_pos := get_global_mouse_position()
	var color: Color = Color(0, 0, 0)
	
	var arr: Array = grid.get_grid_path(player.position, mouse_pos)
	mouse_pos = grid.local_to_map(mouse_pos)
	mouse_pos = grid.map_to_local(mouse_pos)
	
	
	if len(arr) >= PlayerProperties.max_moves or len(arr) == 0:
		color = Color(1.0, 0, 0)
		draw_line(player.position, mouse_pos, color, 1)
	else:
		arr.insert(0, player.position)
		for i in range(len(arr)):
			if len(arr) > i+1:
				draw_line(arr[i], arr[i+1], color, 1)
	
	draw_rect(Rect2(mouse_pos.x - 16, mouse_pos.y-16, 32, 32), color, false)
	
	


func combat_prepare():
	# get entity_data from levels
	# move camera around to point at each sunflower, then back to player
	pass


func _process(_delta):
	queue_redraw()

func end_turn():
	if TURNORDER == TURN.PLAYER:
		TURNORDER = TURN.ENEMY
		PlayerProperties.actions = 5
	else:
		TURNORDER = TURN.PLAYER

func end_combat():
	player.switch_to_pixel()
	in_combat = false

func turn_start_player():
	var mouse_pos: Vector2
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouse_pos = get_global_mouse_position()
		var arr: Array = grid.get_grid_path(player.position, mouse_pos)
		
		
		
		if len(arr) < PlayerProperties.max_moves and len(arr) > 0:
			for path in arr:
				var direction: Vector2 = (path - player.position).normalized()
				player.move_grid(direction)
				await get_tree().create_timer(0.35).timeout

func _physics_process(_delta):
	if TURNORDER == TURN.PLAYER:
		if PlayerProperties.actions != 0:
			turn_start_player()
	else:
		turn_start_npc()
	
func turn_start_npc():
# play NPC turn cutscene
	end_turn()

