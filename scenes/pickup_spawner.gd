extends MultiplayerSpawner

@export var network_pickup: PackedScene
var spawn_count: int = 0

func _init() -> void:
	spawn_function = spawn_pickup

func _ready() -> void:
	# Only the server should handle peer connections and trigger spawns
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)

func _on_peer_connected(_peer_id: int) -> void:
	if not multiplayer.is_server(): return
	# Call the spawner's built-in spawn method, passing a unique ID as an argument
	var unique_projectile_id = randi() % 10000
	%PickupSpawner.spawn([unique_projectile_id, Vector2(500, 200), 1000, Vector2(1,1)])

func spawn_pickup(data):
	print(data)
	var id = data[0]
	var spawn_position = data[1]
	var throw_force = data[2]
	var throw_direction = data[3]
	var pickup: RigidBody2D = network_pickup.instantiate()
	
	# Configure unique name and starting data
	pickup.name = str(id)
 #FIXME: For some reason the projectile sits in a super random spot outside the map?
	
	# Note: Physics impulses on RigidBodies must happen AFTER they enter the tree.
	# We defer the impulse using a lambda so it fires on the next frame.
	var apply_force = func(): pickup.apply_impulse(Vector2.ONE * throw_force * throw_direction)
	pickup.ready.connect(apply_force, CONNECT_ONE_SHOT)
	pickup.ready.connect(func(): pickup.global_position = spawn_position, CONNECT_ONE_SHOT)
	return pickup
