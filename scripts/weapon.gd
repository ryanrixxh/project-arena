class_name Weapon extends RigidBody2D

@onready var timer: Timer = $FiringTimer
@onready var barrel_marker: Marker2D = %BarrelMarker
@onready var sprite: Sprite2D = $WeaponSprite

@export var pickup_address = "res://scenes/Weapon/pickup.tscn"
@export var throw_force = 1500
const weapon_scene: PackedScene = preload("res://scenes/Weapon/weapon.tscn")
const FOLLOW_SPEED = 10
const POSITION_OFFSET = Vector2(10,10)
var pickup_scene: PackedScene = load(pickup_address)


var can_fire: bool = true
@export var player_holding: Player

func _ready() -> void:
	$MagicEffect.play("default")
	global_position = player_holding.reticle_marker.global_position + POSITION_OFFSET



func _process(delta: float) -> void:
	$WeaponSprite.global_rotation = 0
	$MagicEffect.global_rotation = 0
	
	if player_holding:
		global_rotation = player_holding.reticle_marker.global_rotation
		var velocity = ((player_holding.reticle_marker.global_position + POSITION_OFFSET) - global_position) * delta * FOLLOW_SPEED
		move_and_collide(velocity)
		
func setup(player: Player):	
	name = name + player.name
	# Two way tracking: Weapon knows whos holding it, player knows what weapon its holding. aa
	# To help with conditional logic
	player_holding = player
	player.state.equipped_weapon = self
	set_multiplayer_authority(player.get_multiplayer_authority(), true)

func _on_throw():
	if is_multiplayer_authority():
		server_spawn.rpc(randi() % 10000)
		# Remove instance of this node from Players state and then delete
		player_holding.released.emit()

@rpc("any_peer", "call_local", "reliable")
func server_spawn(id: int):
	if multiplayer.is_server():
		var spawner: MultiplayerSpawner = get_node("/root/Main/PickupSpawner")
		var direction = (barrel_marker.global_position - global_position).normalized()
		spawner.spawn([id, barrel_marker.global_position, throw_force, direction])
	
