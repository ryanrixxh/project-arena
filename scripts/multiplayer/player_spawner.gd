extends MultiplayerSpawner

func _ready() -> void:
	spawn_function = spawn_player

func spawn_player(data) -> Player:
	var player: Player = load("res://scenes/player.tscn").instantiate()
	player.name = str(data.id)
	player.global_position = data.position

	player.set_multiplayer_authority(data.authority)
	if data.local:
		player.controller_device_id = data.local_id
		var new_controller_assignments = LocalMultiplayerInput.duplicateInputs(data.local_id)
		for assignment in new_controller_assignments:
			match assignment:
				_ when "jump" in assignment:
					player.jump_control = assignment
				_ when "left" in assignment:
					player.left_control = assignment
				_ when "right" in assignment:
					player.right_control = assignment
				_ when "throw" in assignment:
					player.throw_control = assignment
				_ when "equip" in assignment:
					player.equip_control = assignment
	
	return player
