extends MultiplayerSpawner

@export var boulder: PackedScene
@export var poison_dagger: PackedScene

var pickup_map: Dictionary
var spawn_count: int = 0

func _init() -> void:
	spawn_function = spawn_pickup

func _ready() -> void:
	pickup_map = {
		"boulder": boulder,
		"poison_dagger": poison_dagger
	}

func spawn_pickup(data):
	var id = data.id
	var spawn_position = data.spawn_position
	var throw_force = data.throw_force
	var throw_direction = data.throw_direction
	var pickup: RigidBody2D = pickup_map.get(data.type).instantiate()

	# Configure unique name and starting data
	pickup.name = str(id)

	# Note: Physics impulses on RigidBodies must happen AFTER they enter the tree.
	# We defer the impulse using a lambda so it fires on the next frame.
	var apply_force = func(): pickup.apply_impulse(Vector2.ONE * throw_force * throw_direction)
	pickup.ready.connect(apply_force, CONNECT_ONE_SHOT)
	pickup.ready.connect(func(): pickup.global_position = spawn_position, CONNECT_ONE_SHOT)
	return pickup
