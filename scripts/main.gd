extends Node2D

@export var pickup_scene = preload("res://scenes/Weapon/pickup.tscn")

func _on_pickup_spawner_spawned(node: Node) -> void:
	pass
	#print(node)


func _on_player_spawner_spawned(node: Node) -> void:
	print("Player spawned! ", node.name)
