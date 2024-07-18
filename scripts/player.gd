extends CharacterBody2D

@export_category("movement settings")
@export var SPEED: float = 100.0
@export var DASH_SPEED: float = 200.0
@export var DASHING_TIME: float = 0.5

var is_dashing: bool = false

@onready var timer: Timer = $DashTimer


func _physics_process(delta):
	var speed := SPEED
	# faster way to fetch direction
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	
	if Input.is_action_just_pressed("Dash") && !is_dashing:
		is_dashing = true
		timer.start(DASHING_TIME)
	
	if is_dashing:
		speed = DASH_SPEED

	velocity = direction * speed

	# not multiplying by delta because move and slide does it for us
	move_and_slide()


func _on_dash_timer_timeout():
	is_dashing = false
