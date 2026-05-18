extends Node2D

@export var pickup_scene = preload("res://scenes/Weapon/pickup.tscn")

func _on_button_pressed() -> void:
	NetworkHandler.start_client()

func _on_server_button_pressed() -> void:
	NetworkHandler.start_server()


func _on_pickup_spawner_spawned(node: Node) -> void:
	pass
	#print(node)
