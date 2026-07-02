extends MultiplayerSpawner

func _ready() -> void:
	spawn_function = spawn_weapon

func spawn_weapon(data):
	# FIXME: Classic RPC object parsing. Gotta map it
	var weapon = data.weapon_scene.instantiate()
	var player_equipping: Player = get_tree().root.get_node("Main/" + data.player_name)
	
	weapon.player_holding = player_equipping
	player_equipping.state.equipped_weapon = weapon
	player_equipping.throw.connect(weapon._on_throw)
	
	# FIXME: This still doesnt work lol
	#weapon.global_position = player_equipping.reticle_marker.global_position + weapon.POSITION_OFFSET
	
	weapon.set_multiplayer_authority(player_equipping.get_multiplayer_authority(), true)
	return weapon
