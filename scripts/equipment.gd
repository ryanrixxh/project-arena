extends Node2D
@onready var aim_area = $WeaponMarker

enum InputMode { CONTROLLER, MNK }
var input_mode: InputMode
var device_id = 0

@export var deadzone = 0.2
@export var rotation_speed = 5.0
var target_angle = 0

func _input(event: InputEvent) -> void:
	if(event is InputEventKey or event is InputEventMouse):
		input_mode = InputMode.MNK
	
	if(event is InputEventJoypadButton or event is InputEventJoypadMotion):
		input_mode = InputMode.CONTROLLER

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_mode = InputMode.MNK
	device_id = get_parent().controller_device_id or 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# TODO: look_at doesnt respect collision, because it overrides the position of the object too quickly. Need a different method
	if not is_multiplayer_authority(): return
	if input_mode == InputMode.MNK:	
		follow_mouse()
	else:
		follow_joystick(delta)

func follow_mouse():
	var mouse_pos = get_global_mouse_position()
	aim_area.look_at(mouse_pos)

func follow_joystick(delta):
	var input_vector: Vector2 = Vector2(Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X), 
										Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y))
	
	if input_vector.length() >= deadzone:
		target_angle = input_vector.angle() + deg_to_rad(90.0)
	
	if rotation != target_angle:
		var lerp_weight = 1.0 - exp(-rotation_speed * delta)
		rotation = lerp_angle(rotation, target_angle, lerp_weight)


 
