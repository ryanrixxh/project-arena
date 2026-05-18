class_name Weapon extends Node2D

@onready var timer: Timer = $FiringTimer
@onready var barrel_marker: Marker2D = $BarrelMarker
@onready var sprite: Sprite2D = $WeaponSprite
@onready var effect_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var pickup_address = "res://scenes/Weapon/pickup.tscn"
@export var throw_force = 1500
const weapon_scene: PackedScene = preload("res://scenes/Weapon/weapon.tscn")
var pickup_scene: PackedScene = load(pickup_address)


var can_fire: bool = true
@export var player_holding: Player

func _ready() -> void:
	effect_sprite.play("default")

func setup(player: Player):	
	name = name + player.name
	set_multiplayer_authority(player.name.to_int())
	# Two way tracking: Weapon knows whos holding it, player knows what weapon its holding. 
	# To help with conditional logic
	player_holding = player
	player.state.equipped_weapon = self

func _on_throw():
	#var spawner: MultiplayerSpawner = get_node("../../../../PickupSpawner")
	#print(spawner.is_inside_tree())
	#print(spawner.is_multiplayer_authority())
	#spawner.spawn([pickup_scene, global_position, barrel_marker.global_position, throw_force])
	
	# Spawn a new pickup and apply force to it
	# TODO: This cant happen on the server. Because the authority to throw at all is on the client
	# The way around this might be to make an RPC call? On throw, request server to spawn a pickup? 
	# MultiplayerSpawner should be doing this for us though, since it tracks instantians (but its broken...)
	
	# It COULD be because the resources arent dynamic in the first place. They need to all be spawned in and out dynamically?
	# Try to spawn in a Pickup immediately without any interaction and see if that works, similar to players currently
	if is_multiplayer_authority():
		print("Creating server side projectile")
		# FIXME: There is a multiplayerSpawner that should be picking up this instantiate and propogating but its not and I dont know why
		#var pickup: RigidBody2D = pickup_scene.instantiate()

		authority_spawn.rpc_id(1)
		#print(pickups_node.get_children().map(func(child): return child.name))
		#
		#pickup.global_position = barrel_marker.global_position
		#var direction = (barrel_marker.global_position - global_position).normalized()
		#pickup.apply_impulse(Vector2.ONE * throw_force * direction)
		#player_holding.released.emit()

@rpc("any_peer", "call_local", "reliable")
func authority_spawn():
	if multiplayer.is_server():
		var spawner: MultiplayerSpawner = get_node("/root/Main/PickupSpawner")
		spawner.spawn(randi() % 100)
