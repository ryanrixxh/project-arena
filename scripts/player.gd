extends CharacterBody2D

@export var speed = 400
@export var acceleration = 2000
@export var jump_velocity = -850
@export var gravity = 1500

var current_vine: Node2D

# State Machine
enum States {GROUNDED, AIRBORN, SWINGING}
var state: States = States.GROUNDED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump()

	if state == States.SWINGING:
		global_position = current_vine.get_node("GrabMarker").global_position
		move_and_slide()
		return

	get_horizontal_movement(delta)

	if not is_on_floor_2():
		state = States.AIRBORN
		velocity.y += gravity * delta
	else:
		state = States.GROUNDED

	move_and_slide()



func get_horizontal_movement(delta: float):
	var direction = Input.get_axis("left", "right")
	var arial_acceleration = acceleration / 2
	velocity.x = move_toward(velocity.x, direction * speed, (acceleration if state == States.GROUNDED else arial_acceleration)  * delta)


func jump():
	state = States.AIRBORN
	velocity.y = jump_velocity


# When the vine is grabbed set the current vine to source of the vine_grabbed signal
func _on_interactable_grabbed(body: Node2D, source: Node2D) -> void:
	current_vine = source
	state = States.SWINGING
	var marker = current_vine.get_node("GrabMarker")
	print(marker)
	velocity = Vector2(0, 0)
