extends MultiplayerSpawner

@export var network_pickup: PackedScene
var spawn_count: int = 0

func _init() -> void:
	spawn_function = spawn_pickup

func _ready() -> void:
	# Only the server should handle peer connections and trigger spawns
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)

func _on_peer_connected(peer_id: int) -> void:
	if not multiplayer.is_server(): return
	# Call the spawner's built-in spawn method, passing a unique ID as an argument
	var unique_projectile_id = randi() % 10000
	%PickupSpawner.spawn(unique_projectile_id)

func spawn_pickup(id: int):
	var pickup: RigidBody2D = network_pickup.instantiate()
	
	# Configure unique name and starting data
	pickup.name = str(id)
	pickup.global_position = Vector2(1000, 200)
	
	# Note: Physics impulses on RigidBodies must happen AFTER they enter the tree.
	# We defer the impulse using a lambda so it fires on the next frame.
	var apply_force = func(): pickup.apply_impulse(Vector2.ONE * 1000)
	pickup.ready.connect(apply_force, CONNECT_ONE_SHOT)
	return pickup

	
