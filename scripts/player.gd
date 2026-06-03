class_name Player extends CharacterBody2D

signal throw
signal released

## Emitted by the pickups themselves when pickup zone collision occurs, used to set the available pickup and allow input for equipping
signal allow_equip

## Used to signal when the weapon should be equipped by the player 
signal equip
## Used to make sure the weapon does not despawn to early before being equipped properly
signal done_equipping 


var spawn_position

# Movement stats
@export var speed = 100
@export var min_speed = 200
@export var max_speed = 1000
@export var speed_increase_rate = 3
@export var speed_decrease_rate = -5
@onready var acceleration: float = 2000
@export var jump_velocity = -850
@export var gravity = 1500

@onready var health_component: Health = $Health

@onready var speed_label: Label = $CanvasLayer/PlayerStatus/SpeedPanel/SpeedLabel
@onready var health_label: Label = $CanvasLayer/PlayerStatus/HealthPanel/HealthLabel
@onready var canvas: CanvasLayer = $CanvasLayer
@onready var sprite: AnimatedSprite2D = $WizardSprite
@onready var weapon_marker: Marker2D = $Equipment/WeaponMarker

# Class for keeping track of multiple player state values.
# Initialised immediately
class PlayerState:
	enum AirState {
		GROUNDED,
		AIRBORN
	}
	var air_state: AirState # You can never be airborn and grounded at the same time. This structure ensures that.
	var walled: bool
	
	var available_pickup: Pickup
	var equipped_weapon: Weapon

	func _init() -> void:
		air_state = AirState.GROUNDED
		walled = false

	func is_grounded() -> bool:
		return air_state == AirState.GROUNDED

var state = PlayerState.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%HealthLabelDebug.text = str(health_component.health)
	pass

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())
	%IDLabelDebug.text = str(name)

func _process(_delta: float) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Main driver for all other player script handling, as most of it is based on input handling.
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return # Processing of player should only run client side and then be synced after the fact
	move_and_slide()

	get_horizontal_movement(delta)
	# FIXME: Orientation handler isnt really syncing correctly in network multiplayer
	#handle_orientation()
	handle_input()

	if is_on_wall_only():
		state.walled = true

	if not is_on_floor():
		speed = speed + speed_increase_rate if speed < max_speed else max_speed
		state.air_state = PlayerState.AirState.AIRBORN
		velocity.y += gravity * delta
	else:
		speed = speed + speed_decrease_rate if speed > min_speed else min_speed
		state.walled = false
		state.air_state = PlayerState.AirState.GROUNDED

	speed_label.text = "SPEED: " + str(abs(int(velocity.x)))

func handle_orientation():
	var mouse_pos = get_global_mouse_position()
	var looking_left = mouse_pos.x < global_position.x
	global_transform.x.x = -abs(global_transform.x.x) if looking_left else abs(global_transform.x.x)


func get_horizontal_movement(delta: float):
	var direction = Input.get_axis("left", "right")
	var arial_acceleration: float = acceleration * 0.5
	velocity.x = move_toward(velocity.x, direction * speed, (acceleration if state.is_grounded() else arial_acceleration) * delta)


## Input handling: At the top level [method handle_input] handles all direct input and calls various utility function based on that input
func handle_input():
	if Input.is_action_just_pressed("jump"):
		sprite.play("crouch")

	if Input.is_action_just_released("jump"):
		sprite.stop()
		handle_jump_input("jump")

	if Input.is_action_pressed("throw"):
		throw.emit()
	
	if Input.is_action_pressed("equip"):
		if state.available_pickup:
			equip.emit(state.available_pickup.weapon_scene)
			

func handle_jump_input(delta):
	if state.is_grounded():
		jump(delta)
	elif state.walled:
		wall_jump()

func jump(delta):
	sprite.play("jump")
	state.air_state = PlayerState.AirState.AIRBORN
	velocity.y = jump_velocity - (speed * 0.5)

func wall_jump():
	var collision = get_last_slide_collision()
	if collision:
		var direction = collision.get_normal()[0]
		state.air_state = PlayerState.AirState.AIRBORN
		velocity.y = jump_velocity - (speed * 0.5)
		velocity.x = direction * speed
		state.walled = false

func _on_animation_trigger_area_body_entered(_body: Node2D) -> void:
	sprite.play("default")
	

# WEAPON EQUIPPING
func _on_allow_equip(pickup: Pickup = null) -> void:
	state.available_pickup = pickup

func _on_equip(weapon_scene: PackedScene) -> void:
	if is_multiplayer_authority():
		var weapon: Weapon = weapon_scene.instantiate()
		weapon.setup(self)
		weapon_marker.add_child.call_deferred(weapon)	
		#weapon.global_transform = weapon_marker.global_transform
		throw.connect(weapon._on_throw)
		
		# Tell the server to despawn the pickup after we have equipped it and forget about it
		state.available_pickup.server_despawn.rpc_id(1)
		state.available_pickup = null

func _on_released() -> void:
	if is_multiplayer_authority():
		weapon_marker.remove_child(state.equipped_weapon)
		state.equipped_weapon.call_deferred("queue_free")
		state.equipped_weapon = null
