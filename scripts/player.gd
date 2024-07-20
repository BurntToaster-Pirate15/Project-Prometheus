extends CharacterBody2D

enum MOVEMENT_TYPE {PIXEL_BASED, GRID_BASED}
enum COMBAT_MODE {ATTACK, MOVE}

@export_category("movement settings")
@export var SPEED: float = 100.0
@export var SPRINT_SPEED: float = 200.0
@export var movement_type: MOVEMENT_TYPE = MOVEMENT_TYPE.PIXEL_BASED


var is_sprinting: bool = true
var is_moving: bool = false
var is_my_turn: bool = false
var action_done: bool = false

var combat_mode: COMBAT_MODE

var dash_direction: Vector2
var move_direction: Vector2 = Vector2.ZERO

@onready var HUD: Control = $"HUD"

signal moved
signal turn_finished

func _ready():
	turn_finished.connect(
		func():
			is_my_turn = false;
			$HUD/TurnStatus.text = "Enemy Turn"
	)

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

		action_done = true		
		is_moving = true
		move_direction = movement
		var _position: Vector2 = position + (move_direction * MapProperties.TILESIZE)
		
		if (len(grid.get_grid_path(position, _position)) == 0):
			is_moving = false
			return
		


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
	get_tree().reload_current_scene()


func _draw():
	if combat_mode == COMBAT_MODE.ATTACK && movement_type == MOVEMENT_TYPE.GRID_BASED:
		var mouse_pos := get_global_mouse_position()
		var color: Color = Color(0, 0, 0)
	
		mouse_pos = grid.local_to_map(mouse_pos)
		mouse_pos = grid.map_to_local(mouse_pos)
		mouse_pos = to_local(mouse_pos)
		
		var radius: int = 500
		
		if mouse_pos.length() > radius:
			color = Color(255, 0, 0)

		
		
		draw_rect(Rect2(mouse_pos.x-16, mouse_pos.y-16, 32, 32), color, false)
		draw_line(Vector2(0, 0), mouse_pos, color, 2)
		
	


func _physics_process(_delta):
	# faster way to fetch direction
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if movement_type == MOVEMENT_TYPE.PIXEL_BASED:
		move_pixel(direction)
	if movement_type == MOVEMENT_TYPE.GRID_BASED:
		if not is_my_turn:
			return
		
		
		if combat_mode == COMBAT_MODE.MOVE:
			move_grid(direction)
			#$Control/Button3.visible = true
			await moved
			turn_finished.emit()
			return
		
		if combat_mode == COMBAT_MODE.ATTACK:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				var mouse_pos := grid.local_to_map(
					grid.to_local(get_global_mouse_position())
				)
					
					

				grid.set_cell(0, mouse_pos, 1, Vector2(0, 4))
				grid.grid.set_point_solid(grid.local_to_map(get_global_mouse_position()))
				turn_finished.emit()
				return
		


func _process(_delta):
	$DebugLabel_HP.text="HP: {hp}/{max_hp}".format(
		{"hp": PlayerProperties.health,
		"max_hp":PlayerProperties.max_health,
		})
	queue_redraw()

func start_turn(_grid: TileMap, _combatants: Array[CharacterBody2D]):
	grid = _grid
	$HUD/TurnStatus.text = "Player Turn"
	HUD.visible = true
	action_done = false
	is_my_turn = true


func _on_button_2_toggled(toggled_on):
	if toggled_on:
		combat_mode = COMBAT_MODE.MOVE


func _on_button_toggled(toggled_on):
	if toggled_on:
		combat_mode = COMBAT_MODE.ATTACK


func _on_button_3_pressed():
	turn_finished.emit()
	$Control/Button3.visible = false
