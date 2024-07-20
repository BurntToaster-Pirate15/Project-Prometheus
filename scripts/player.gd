extends CharacterBody2D

enum MOVEMENT_TYPE {PIXEL_BASED, GRID_BASED}

@export_category("movement settings")
@export var SPEED: float = 100.0
@export var SPRINT_SPEED: float = 200.0
@export var movement_type: MOVEMENT_TYPE = MOVEMENT_TYPE.PIXEL_BASED


var is_sprinting: bool = true
var is_moving: bool = false
var is_my_turn: bool = false


var dash_direction: Vector2
var move_direction: Vector2 = Vector2.ZERO

signal moved
signal turn_finished


var grid: TileMap

func switch_to_grid() -> void:
	position = position.snapped(Vector2.ONE * MapProperties.TILESIZE)
	position -= Vector2.ONE * (MapProperties.TILESIZE * 0.5)
	movement_type = MOVEMENT_TYPE.GRID_BASED

func switch_to_pixel() -> void:
	movement_type = MOVEMENT_TYPE.PIXEL_BASED



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

func move_pixel(direction: Vector2):
	var speed := SPEED

	if Input.is_action_pressed("Dash"):
		is_sprinting = !is_sprinting
	if is_sprinting:
		speed = SPRINT_SPEED
	
	velocity = direction * speed

	# not multiplying by delta because move and slide does it for us
	move_and_slide()
	
func take_damage(damage_amount:int=1) -> void:
	PlayerProperties.health -= damage_amount
	
	if PlayerProperties.health <= 0:
		die()

func die():
	print("You died")


func _draw():
	if is_my_turn:
		var mouse_pos := get_global_mouse_position()
		var color: Color = Color(0, 0, 0)
	
		var arr: Array = grid.get_grid_path(position, mouse_pos)
		mouse_pos = grid.local_to_map(mouse_pos)
		mouse_pos = grid.map_to_local(mouse_pos)
	
	
		if len(arr) >= PlayerProperties.max_moves or len(arr) == 0:
			color = Color(1.0, 0, 0)
			draw_line(position, mouse_pos, color, 1)
		else:
			arr.insert(0, position)
			for i in range(len(arr)):
				if len(arr) > i+1:
					draw_line(arr[i], arr[i+1], color, 1)
	
		draw_rect(Rect2(mouse_pos.x - 16, mouse_pos.y-16, 32, 32), color, false)
	
	

func _physics_process(_delta):
	# faster way to fetch direction
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if movement_type == MOVEMENT_TYPE.PIXEL_BASED:
		move_pixel(direction)
	if movement_type == MOVEMENT_TYPE.GRID_BASED:
		# finish turns if no moves are left
		if PlayerProperties.actions == 0:
			turn_finished.emit()
			return
		
		# check for mouse input for movement
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var mouse_pos = get_global_mouse_position()
			var arr: Array = grid.get_grid_path(position, mouse_pos)
		
			# if it takes more moves than allowed return
			if len(arr) > PlayerProperties.max_moves or len(arr) < 0:
				return
			
			# move to position
			for path in arr:
				if PlayerProperties.actions > 0:
					direction = (path - position).normalized()
					move_grid(direction)
					await moved
			
			PlayerProperties.actions -= 1

func _process(_delta):
	$DebugLabel_HP.text="HP: {hp}/{max_hp}\n Actions: {actions}/{max_actions}".format(
		{"hp": PlayerProperties.health,
		"max_hp":PlayerProperties.max_health,
		"actions": PlayerProperties.actions,
		"max_actions": 5
		})
	

func start_turn(grid: TileMap, _combatants: Array[CharacterBody2D]):
	self.grid = grid
	is_my_turn = true
