extends MultiplayerSpawner

func _ready() -> void:
	spawn_function = spawn_weapon

func spawn_weapon(data):
	var weapon: Weapon = load("res://scenes/Weapon/weapon.tscn").instantiate()
	var player_equipping: Player = get_tree().root.get_node("Main/" + data.player_name)
	
	weapon.player_holding = player_equipping
	player_equipping.state.equipped_weapon = weapon
	player_equipping.throw.connect(weapon._on_throw)
	
	weapon.set_multiplayer_authority(player_equipping.get_multiplayer_authority(), true)
	return weapon
