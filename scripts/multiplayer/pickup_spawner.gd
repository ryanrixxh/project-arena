extends MultiplayerSpawner

#@export var boulder: PackedScene
#@export var poison_dagger: PackedScene
@export var pickup_map: Dictionary[String, PackedScene]
var spawn_count: int = 0

func _init() -> void:
	spawn_function = spawn_pickup

func spawn_pickup(data):
	var pickup: RigidBody2D = pickup_map.get(data.type).instantiate()

	# Configure unique name and starting data
	pickup.name = str(data.id)

	# Note: Physics impulses on RigidBodies must happen AFTER they enter the tree.
	# We defer the impulse using a lambda so it fires on the next frame.
	var apply_force = func(): pickup.apply_impulse(Vector2.ONE * data.throw_force * data.throw_direction)
	pickup.ready.connect(apply_force, CONNECT_ONE_SHOT)
	pickup.ready.connect(func(): pickup.global_position = data.spawn_position, CONNECT_ONE_SHOT)
	return pickup
