extends MultiplayerSpawner

@export var network_player: PackedScene

func _init() -> void:
	spawn_function = spawn_player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Player spawner authority: ", get_multiplayer_authority())
	multiplayer.peer_connected.connect(spawn_player)

func spawn_player(id: int) -> void:
	if not multiplayer.is_server(): return
	var player = network_player.instantiate()
	player.name = str(id)
	get_node(spawn_path).call_deferred("add_child", player)
	
