class_name Weapon extends Node2D

@onready var timer: Timer = $FiringTimer
@onready var barrel_marker: Marker2D = $BarrelMarker
@onready var sprite: Sprite2D = $WeaponSprite
@onready var effect_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var pickup_address = "res://scenes/Weapon/pickup.tscn"
@export var throw_force = 1500
const weapon_scene = preload("res://scenes/Weapon/weapon.tscn")
var pickup = load(pickup_address)


var can_fire: bool = true
@export var player_holding: Player
func setup(player: Player):
	# Two way tracking: Weapon knows whos holding it, player knows what weapon its holding. 
	# To help with conditional logic
	player_holding = player
	player.state.equipped_weapon = self

func _on_throw():
	# Spawn a new pickup and apply force to it
	var pickup: RigidBody2D = pickup.instantiate()
	get_tree().root.add_child(pickup)
	pickup.global_position = barrel_marker.global_position
	var direction = (barrel_marker.global_position - global_position).normalized()
	pickup.apply_impulse(Vector2.ONE * throw_force * direction)
	
	# Remove from UI canvas
	var pickup_component: Pickup = pickup.find_child("PickupComponent")
	pickup_component.remove_equipped_from_canvas(player_holding)
	
	# Remove instance of this node from Players state and then delete
	player_holding.state.equipped_weapon = null
	call_deferred("queue_free")
