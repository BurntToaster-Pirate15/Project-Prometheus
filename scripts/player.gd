extends CharacterBody2D


const SPEED: float = 100.0
const DASHSPEED: float = 900.0
var is_dashing: bool = false

@onready var timer: Timer = $DashTimer


func _physics_process(delta):
	var speed := SPEED
	# faster way to fetch direction
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	
	if Input.is_action_just_pressed("Dash") && !is_dashing:
		is_dashing = true
		timer.start()
		speed = DASHSPEED

	velocity = direction * speed

	# not multiplying by delta because move and slide does it for us
	move_and_slide()


func _on_dash_timer_timeout():
	is_dashing = false
