extends Node

@onready var pickup_area = $PickupArea
@onready var pickup_cooldown_timer = $CooldownTimer
@export var weapon_scene_address: String = "res://scenes/Weapon/weapon.tscn"
var weapon_scene = load(weapon_scene_address) # Can't preload this because its called from an export var

var off_pickup_cooldown = false

func _on_pickup_area_area_entered(area: Area2D) -> void:
	var player: Player = area.get_parent()
	equip(player)
	queue_free()

func equip(player: Player) -> void:
	var weapon: Weapon = weapon_scene.instantiate()
	player.weapon_marker.add_child(weapon)
	weapon.global_transform = player.weapon_marker.global_transform
	player.trigger_pull.connect(weapon._on_trigger_pull)
	
