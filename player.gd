extends CharacterBody2D

@export var speed = 400
@export var acceleration = 1000
@export var jump_velocity = -1000
@export var gravity = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	get_horizontal_movement(delta)

		
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
		
	move_and_slide()
	
func get_horizontal_movement(delta: float):
	var direction = Input.get_axis("left", "right")	
	var arial_acceleration = acceleration / 2
	velocity.x = move_toward(velocity.x, direction * speed, (acceleration if is_on_floor() else arial_acceleration)  * delta)
	
func jump():
	velocity.y = jump_velocity
