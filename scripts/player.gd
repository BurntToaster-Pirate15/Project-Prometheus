extends CharacterBody2D

@export_category("movement settings")
@export var SPEED: float = 100.0
@export var DASH_SPEED: float = 200.0
@export var DASHING_TIME: float = 0.5

var is_dashing: bool = false
var dash_direction: Vector2
var move_direction: Vector2 = Vector2.ZERO
@onready var timer: Timer = $DashTimer

func switch_to_grid() -> void:
	position = position.snapped(Vector2.ONE * TILE_SIZE)
	position -= Vector2.ONE * (TILE_SIZE / 2)

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
	# faster way to fetch direction
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if movement_type == MOVEMENT_TYPE.PIXEL_BASED:
		move_pixel(direction)
	else:
		move_grid(direction)

func _on_dash_timer_timeout():
	is_dashing = false
