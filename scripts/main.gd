extends Node2D

@export var pickup_scene = preload("res://scenes/Weapon/pickup.tscn")

var pickup_count = 0

func _ready() -> void:
	spawn_initial_pickups()

func spawn_initial_pickups():
	if not multiplayer.is_server(): return
	%PickupSpawner.spawn(["Pickup" + str(pickup_count), Vector2(500, 200), 1000, Vector2(1,1)])

func _on_player_spawner_spawned(node: Node) -> void:
	print_debug("Player spawned! ", node.name)
