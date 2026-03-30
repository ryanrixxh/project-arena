class_name Pickup extends Node

@onready var pickup_area = $PickupArea

@export var pickup_body: RigidBody2D
@export var weapon_scene_address: String = "res://scenes/Weapon/weapon.tscn"
var weapon_scene = load(weapon_scene_address) # Can't preload this because its called from an export var
var can_pickup = false

func _on_pickup_area_area_entered(area: Area2D) -> void:
	if not can_pickup: return
	
	var player: Player = area.get_parent()
	equip(player)
	pickup_body.queue_free()

func equip(player: Player) -> void:
	var weapon: Weapon = weapon_scene.instantiate()
	player.weapon_marker.add_child(weapon)
	weapon.global_transform = player.weapon_marker.global_transform
	player.throw.connect(weapon._on_throw)
	player.trigger_pull.connect(weapon._on_trigger_pull)


func _on_cooldown_timer_timeout() -> void:
	can_pickup = true
