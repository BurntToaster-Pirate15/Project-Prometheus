extends CharacterBody2D


const SPEED: float = 100




func _physics_process(delta):
	# faster way to fetch direction
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")

	velocity =  direction * SPEED 
	# not multiplying by delta because move and slide does it for us
	move_and_slide()
