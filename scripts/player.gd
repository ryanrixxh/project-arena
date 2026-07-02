class_name Player extends CharacterBody2D

signal throw
@warning_ignore("unused_signal")
signal released

## Emitted by the pickups themselves when pickup zone collision occurs, used to set the available pickup and allow input for equipping
@warning_ignore("unused_signal")
signal allow_equip

## Used to signal when the weapon should be equipped by the player 
signal equip
## Used to make sure the weapon does not despawn to early before being equipped properly
@warning_ignore("unused_signal")
signal done_equipping 


var spawn_position

# Control assignments
var controller_device_id
@export var jump_control = "jump"
@export var left_control = "left"
@export var right_control = "right"
@export var throw_control = "throw"
@export var equip_control = "equip"

# Movement stats
@export var speed = 100
@export var min_speed = 200
@export var max_speed = 1000
@export var speed_increase_rate = 3
@export var speed_decrease_rate = -5
@onready var acceleration: float = 2000
@export var jump_velocity = -850
@export var gravity = 1500
@export var hover_energy = 500
@export var max_hover_energy = 500
var energy_bar: ProgressBar

@onready var health_component: Health = $Health

@onready var speed_label: Label = $CanvasLayer/PlayerStatus/SpeedPanel/SpeedLabel
@onready var health_label: Label = $CanvasLayer/PlayerStatus/HealthPanel/HealthLabel
@onready var canvas: CanvasLayer = $CanvasLayer
@onready var sprite: AnimatedSprite2D = $WizardSprite
@onready var weapon_marker: Marker2D = %WeaponMarker
@onready var reticle_marker: Marker2D = %ReticleMarker
@onready var weapon_spawner: MultiplayerSpawner = $WeaponSpawner

# Class for keeping track of multiple player state values.
# Initialised immediately
class PlayerState:
	enum AirState {
		GROUNDED,
		AIRBORN
	}
	var air_state: AirState # You can never be airborn and grounded at the same time. This structure ensures that.
	var walled: bool
	var hovering: bool
	
	var available_pickup: Pickup
	var equipped_weapon

	func _init() -> void:
		air_state = AirState.GROUNDED
		walled = false
		hovering = false

	func is_grounded() -> bool:
		return air_state == AirState.GROUNDED

var state = PlayerState.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%HealthLabelDebug.text = str(health_component.health)
	$HoverEffect.animation_finished.connect(func(): $HoverEffect.play("default"))
	energy_bar = get_node("/root/Main/ScoreCanvasLayer/HoverEnergyBar")

func _enter_tree() -> void:
	%IDLabelDebug.text = str(name)

func _process(_delta: float) -> void:
	if state.is_grounded() and abs(velocity) > Vector2(0,0):
		sprite.play("walk")
	elif not state.is_grounded():
		sprite.play("airborn")
	else:
		sprite.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Main driver for all other player script handling, as most of it is based on input handling.
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return # Processing of player should only run client side and then be synced after the fact
	move_and_slide()

	get_horizontal_movement.call_deferred(delta)
	# FIXME: Orientation handler isnt really syncing correctly in network multiplayer
	handle_orientation()
	handle_input()

	if is_on_wall_only():
		state.walled = true
	
	if state.hovering:
		$HoverEffect.show()
		if not $HoverEffect.is_playing(): $HoverEffect.play("buildup")
	else:
		$HoverEffect.hide()
		$HoverEffect.stop()
	if hover_energy <= max_hover_energy:
		hover_energy += 3
	energy_bar.value = hover_energy

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
	$WizardSprite.global_transform.x.x = -abs($WizardSprite.global_transform.x.x) if looking_left else abs($WizardSprite.global_transform.x.x)


func get_horizontal_movement(delta: float):
	var direction = Input.get_axis(left_control, right_control)
	var arial_acceleration: float = acceleration * 0.5
	velocity.x = move_toward(velocity.x, direction * speed, (acceleration if state.is_grounded() else arial_acceleration) * delta)


## Input handling: At the top level [method handle_input] handles all direct input and calls various utility function based on that input
func handle_input():
	#if Input.is_action_just_pressed(jump_control):
		##sprite.play("crouch")
	if Input.is_action_pressed(jump_control):
		handle_hover_input()
	
	if Input.is_action_just_released(jump_control):
		state.hovering = false
		sprite.stop()
		handle_jump_input()

	if Input.is_action_pressed(throw_control):
		throw.emit()
	
	if Input.is_action_pressed(equip_control):
		if state.available_pickup:
			equip.emit(state.available_pickup.weapon_scene)
			

# TODO: Hover should actually just replace jump I think? 
# But then wall jumping would break. 
func handle_jump_input():
	if state.is_grounded():
		jump()
	elif state.walled:
		wall_jump()

func jump():
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

func handle_hover_input():
	if state.air_state == PlayerState.AirState.GROUNDED: 
		state.hovering = false
		return
	if hover_energy == 0: 
		state.hovering = false
		return
	
	state.hovering = true
	if hover_energy > 0: hover_energy -= 10 
	if velocity.y > -1000 and hover_energy > 0:
		velocity.y -= (speed * 0.1) 

func _on_animation_trigger_area_body_entered(_body: Node2D) -> void:
	sprite.play("default")
	

# WEAPON EQUIPPING
func _on_allow_equip(pickup: Pickup = null) -> void:
	state.available_pickup = pickup

func _on_equip(weapon_scene: PackedScene) -> void:
	if is_multiplayer_authority():
		weapon_spawner.spawn({"player_name": name, "weapon_scene": weapon_scene})
		
		# Tell the server to despawn the pickup after we have equipped it and forget about it
		state.available_pickup.server_despawn.rpc_id(1)
		state.available_pickup = null

func _on_released() -> void:
	if is_multiplayer_authority():
		$Equipment.remove_child(state.equipped_weapon)
		state.equipped_weapon.call_deferred("queue_free")
		state.equipped_weapon = null
