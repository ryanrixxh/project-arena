extends MultiplayerSpawner

func _ready() -> void:
	print("Weapon spawner authority: ", get_multiplayer_authority())
	
