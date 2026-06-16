extends MultiplayerSpawner

func _ready() -> void:
	spawn_function = spawn_player

func spawn_player(data) -> Player:
	var player: Player = load("res://scenes/player.tscn").instantiate()
	player.name = str(data.id)
	player.global_position = data.position
	print(data)
	player.set_multiplayer_authority(data.authority)
	return player
