extends CharacterBody2D

enum MOVEMENT_TYPE {PIXEL_BASED, GRID_BASED}
enum COMBAT_MODE {ATTACK, MOVE}

const blocks: Dictionary = {
	"wall": Vector2(0, 4)
}

@export_category("movement settings")
@export var SPEED: float = 100.0
@export var SPRINT_SPEED: float = 200.0
@export var movement_type: MOVEMENT_TYPE = MOVEMENT_TYPE.PIXEL_BASED

var grid: TileMap

var is_sprinting: bool = true
var is_moving: bool = false
var is_my_turn: bool = false

var combat_mode: COMBAT_MODE

var dash_direction: Vector2
var move_direction: Vector2 = Vector2.ZERO

var actions: int = 1

@onready var HUD: Control = $"HUD"

signal moved
signal turn_finished

func _ready():
	turn_finished.connect(
		func():
			is_my_turn = false;
			$HUD/TurnStatus.text = "Enemy Turn"
	)

func _process(_delta):
	$DebugLabel_HP.text="HP: {hp}/{max_hp}\n ACTIONS: {actions}/{max_actions}".format(
		{"hp": PlayerProperties.health,
		"max_hp":PlayerProperties.max_health,
		"actions": actions,
		"max_actions": 1
		})
	queue_redraw()

func _physics_process(_delta):
	# faster way to fetch direction
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if movement_type == MOVEMENT_TYPE.PIXEL_BASED:
		move_pixel(direction)
	if movement_type == MOVEMENT_TYPE.GRID_BASED:
		if not is_my_turn:
			return
		
		if actions == 0:
			return
		
		if combat_mode == COMBAT_MODE.MOVE:
			move_grid(direction)
			await moved
			turn_finished.emit()
			return
		


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

# capture mouse input and place block
func _input(event: InputEvent):
	if event is InputEventMouseButton:
		# BUG: check if mouse event is conusmed by button!
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if is_my_turn and actions != 0 and combat_mode == COMBAT_MODE.ATTACK:
				var mouse_pos := get_global_mouse_position()
				var location_to_place := grid.local_to_map(grid.to_local(mouse_pos))

				place_block(location_to_place, blocks["wall"])
				actions -= 1
				turn_finished.emit()


			

func switch_to_grid() -> void:
	position = position.snapped(Vector2.ONE * MapProperties.TILESIZE)
	position -= Vector2.ONE * (MapProperties.TILESIZE * 0.5)
	movement_type = MOVEMENT_TYPE.GRID_BASED

func switch_to_pixel() -> void:
	movement_type = MOVEMENT_TYPE.PIXEL_BASED

# map_coordinate: where in the tile map should the block be placed
# tile_coordinate: what tile should be placed (coordinate in tile set)
func place_block(map_coordinate: Vector2, tile_coordinate: Vector2) -> void:
	grid.set_cell(0, map_coordinate, 1, tile_coordinate)
	grid.grid.set_point_solid(map_coordinate)

# handle player inputs

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

		actions -=1
		is_moving = true
		move_direction = movement
		var _position: Vector2 = position + (move_direction * MapProperties.TILESIZE)
		
		if (len(grid.get_grid_path(position, _position)) == 0):
			is_moving = false
			return
		


		var tween: Tween = create_tween()
		tween.tween_property(self, "position", _position, 0.25)
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


func start_turn(_grid: TileMap, _combatants: Array[CharacterBody2D]):
	grid = _grid
	$HUD/TurnStatus.text = "Player Turn"
	HUD.visible = true
	is_my_turn = true
	actions = 1


# ===============+ GUI +================= #


func _on_button_2_toggled(toggled_on):
	if toggled_on:
		combat_mode = COMBAT_MODE.MOVE


func _on_button_toggled(toggled_on):
	if toggled_on:
		combat_mode = COMBAT_MODE.ATTACK


func _on_button_3_pressed():
	turn_finished.emit()
	$Control/Button3.visible = false

# =============== GUI END ================= #
