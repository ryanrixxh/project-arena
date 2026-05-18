extends MultiplayerSpawner

@export var network_pickup: PackedScene

func _init() -> void:
	spawn_function = spawn_pickup

func _ready() -> void:
	print("Pickup spawner authority: ", get_multiplayer_authority())
	multiplayer.peer_connected.connect(spawn_pickup)

func spawn_pickup(id: int):
	#if not multiplayer.is_server(): return
	var pickup: RigidBody2D = network_pickup.instantiate()
	pickup.global_position = Vector2(1000,200)
	pickup.name = str(id)
	pickup.apply_impulse(Vector2.ONE * 1000)
	get_node(spawn_path).add_child(pickup)
	print(pickup.name)
	return pickup
			#pickup.global_position = barrel_marker.global_position
		#var direction = (barrel_marker.global_position - global_position).normalized()

	
