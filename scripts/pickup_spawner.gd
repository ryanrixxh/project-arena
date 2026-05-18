extends MultiplayerSpawner

func _init() -> void:
	spawn_function = _spawn_pickup

func _spawn_pickup(pickup_scene: PackedScene, equipment_position: Vector2, marker_position: Vector2, throw_force: int) -> Node: 
	print(is_inside_tree())
	print(multiplayer.has_multiplayer_peer())
	print(is_multiplayer_authority())
	var pickup: RigidBody2D = pickup_scene.instantiate()
	pickup.global_position = marker_position
	var direction = (marker_position - equipment_position).normalized()
	pickup.apply_impulse(Vector2.ONE * throw_force * direction)
	return pickup
