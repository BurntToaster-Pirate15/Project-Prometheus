extends CharacterBody2D

const TILE_SIZE = 32
enum MOVEMENT_TYPE {PIXEL_BASED, GRID_BASED}

@export_category("movement settings")
@export var SPEED: float = 100.0
@export var SPRINT_SPEED: float = 200.0
@export var movement_type: MOVEMENT_TYPE = MOVEMENT_TYPE.PIXEL_BASED

var is_sprinting: bool = true
var is_moving: bool = false

var dash_direction: Vector2
var move_direction: Vector2 = Vector2.ZERO
@onready var timer: Timer = $DashTimer




func switch_to_grid() -> void:
	position = position.snapped(Vector2.ONE * TILE_SIZE)
	position -= Vector2.ONE * (TILE_SIZE * 0.5)
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
		var _position: Vector2 = position + (move_direction * TILE_SIZE)
		
		
		var tween: Tween = create_tween()
		tween.tween_property(self, "position", _position, 0.35)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(func(): move_direction = Vector2.ZERO; is_moving = false)

func move_pixel(direction: Vector2):
	var speed := SPEED

	if Input.is_action_pressed("Dash"):
		is_sprinting = !is_sprinting
	if is_sprinting:
		speed = SPRINT_SPEED
	
	velocity = direction * speed

	# not multiplying by delta because move and slide does it for us
	move_and_slide()


func _physics_process(_delta):
	# faster way to fetch direction
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if movement_type == MOVEMENT_TYPE.PIXEL_BASED:
		move_pixel(direction)
	else:
		move_grid(direction)

