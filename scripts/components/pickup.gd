class_name Pickup extends Node

@export var pickup: RigidBody2D
@export var pickup_area: Area2D
@export var weapon_scene_address: String = "res://scenes/Weapon/weapon.tscn"
var weapon_scene: PackedScene = load(weapon_scene_address) # Can't preload this because its called from an export var
var can_pickup = false

func _on_pickup_area_area_entered(area: Area2D) -> void:
	# Only players should trigger pickup logic
	if area.get_parent() is not Player or not can_pickup:
		return
	
	if (area.get_parent() as Player).state.equipped_weapon is Weapon:
		print("A weapon is already equipped, skipping equip logic")
		return
		
	var player: Player = area.get_parent()
	player.equip.emit(weapon_scene)
	pickup.queue_free()

func _on_cooldown_timer_timeout() -> void:
	can_pickup = true
