class_name Weapon extends Node2D

@onready var timer: Timer = $FiringTimer
@onready var barrel_marker: Marker2D = $BarrelMarker
var rifle_bullet = preload("res://scenes/rifle_bullet.tscn")

@export var pickup_address = "res://scenes/Weapon/pickup.tscn"
@export var throw_force = 1500
var pickup = load(pickup_address)


var can_fire: bool = true
func _process(_delta: float) -> void:
	pass

func _on_firing_timer_timeout() -> void:
	can_fire = true

func _on_trigger_pull(player_speed: int):
	if (can_fire):
		timer.start() # Prevents double firing when the trigger is pulled right as the timer is reset
		var bullet_scene = rifle_bullet.instantiate()
		var bullet: Bullet = bullet_scene.get_child(0)
		bullet.damage = player_speed * bullet.damage_multi
		get_tree().root.add_child(bullet_scene)
		bullet_scene.global_transform = barrel_marker.global_transform
		can_fire = false

func _on_throw():
	var pickup: RigidBody2D = pickup.instantiate()
	get_tree().root.add_child(pickup)
	pickup.global_position = barrel_marker.global_position
	var direction = (barrel_marker.global_position - global_position).normalized()
	print(direction)
	pickup.apply_impulse(Vector2.ONE * throw_force * direction)
	queue_free()
