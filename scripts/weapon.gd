class_name Weapon extends Node2D

@onready var barrel_marker = $WeaponBody/BarrelMarker
@onready var timer = $WeaponBody/FiringTimer
@onready var body = $WeaponBody

@export var weapon_name = "Placeholder"

var can_fire: bool = false

var rifle_bullet = preload("res://scenes/rifle_bullet.tscn")

func _process(delta: float) -> void:
	global_skew = 0

func _on_firing_timer_timeout() -> void:
	can_fire = true

func _on_trigger_pull(player_speed: int):
	if (can_fire):
		timer.start() # Prevents double firing when the trigger is pulled right as the timer is reset
		var bullet_scene = rifle_bullet.instantiate()
		var bullet: Bullet = bullet_scene.get_child(0)
		bullet.damage = player_speed * bullet.damage_multi
		print(bullet.damage)
		get_tree().root.add_child(bullet_scene)
		bullet_scene.global_transform = barrel_marker.global_transform
		can_fire = false
	
