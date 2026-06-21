class_name Weapon extends Node2D

@onready var timer: Timer = $FiringTimer
@onready var barrel_marker: Marker2D = %BarrelMarker
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
	# Two way tracking: Weapon knows whos holding it, player knows what weapon its holding. 
	# To help with conditional logic
	player_holding = player
	player.state.equipped_weapon = self
	#global_position = player.reticle_marker.global_position

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
	
