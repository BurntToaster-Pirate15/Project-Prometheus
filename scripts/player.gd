extends CharacterBody2D

enum MOVEMENT_TYPE {TILE_BASED, PIXEL_BASED}
const TILE_SIZE: int = 32

@export_category("movement settings")
@export var SPEED: float = 100.0
@export var DASH_SPEED: float = 200.0
@export var DASHING_TIME: float = 0.5
@export var movement_type: MOVEMENT_TYPE = MOVEMENT_TYPE.PIXEL_BASED

var is_dashing: bool = false
var is_moving: bool = false
var dash_direction: Vector2

@onready var timer: Timer = $DashTimer
@onready var tween: Tween = create_tween()


func move_grid():
	pass

func move_pixel():
	var speed := SPEED
	# faster way to fetch direction
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
		
		
	if Input.is_action_just_pressed("Dash") && !is_dashing:
		is_dashing = true
		dash_direction = direction
		timer.start(DASHING_TIME)
	if is_dashing:
		speed = DASH_SPEED
		direction = dash_direction

	velocity = direction * speed

	# not multiplying by delta because move and slide does it for us
	move_and_slide()

func _physics_process(delta):
	if movement_type == MOVEMENT_TYPE.PIXEL_BASED:
		move_pixel()
	else:
		move_grid()



func _on_dash_timer_timeout():
	is_dashing = false
