extends MultiplayerSpawner

var skin_index: int
var skins: Array[SpriteFrames]

func _ready() -> void:
	spawn_function = spawn_player
	# TODO: Skin selection in lobby somehow. Make a feature ticket
	skin_index = 0
	skins = [load("res://assets/red-animated-wizard.tres"), 
			 load("res://assets/blue-animated-wizard.tres"),
			 load("res://assets/green-animated-wizard.tres"),
			 load("res://assets/pink-animated-wizard.tres")] 

func spawn_player(data) -> Player:
	var player: Player = load("res://scenes/player.tscn").instantiate()
	player.name = str(data.id)
	player.global_position = data.position
	
	# Set the new player to a different skin
	var wizard_sprite: AnimatedSprite2D = player.get_node("WizardSprite")
	wizard_sprite.sprite_frames = skins[skin_index]
	skin_index += 1
	
	# Assign peer authority and local controller assignment if nessecary
	player.set_multiplayer_authority(data.authority, true)
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
