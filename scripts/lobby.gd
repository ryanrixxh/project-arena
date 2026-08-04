extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Gamestate.players_changed.connect(load_player_list)
	if Gamestate.player_ids.size() > 0:
		show_lobby()
	
	multiplayer.connected_to_server.connect(on_join_success)
	multiplayer.connection_failed.connect(on_join_fail)

func load_player_list():
	var player_ids = Gamestate.player_ids
	player_ids.sort()
	$PlayerPanel/PlayerList.clear()
	var own_id = str(multiplayer.get_unique_id())
	$PlayerPanel/PlayerList.add_item(own_id + " (You)")
	for p in player_ids:
		var label = str(p)
		if label == own_id:
			continue
		$PlayerPanel/PlayerList.add_item(label)

func _on_host_button_pressed() -> void:
	Gamestate.host()
	show_lobby()


func _on_join_button_pressed() -> void:
	$ButtonContainer.hide()
	$JoinInputContainer.show()

func _on_start_game_button_pressed() -> void:
	Gamestate.start_game(Gamestate.StartSource.LOBBY)

func show_lobby():
	$ButtonContainer.hide()
	$PlayerPanel.show()
	$AddLocalPlayerButton.show()
	if multiplayer.is_server():
		$StartGameButton.show()
	load_player_list()


func _on_add_local_player_button_pressed() -> void:
	Gamestate.local_join()

func _on_join_input_text_submitted(new_text: String) -> void:
	Gamestate.join(new_text)
	$JoinInputContainer/LoadingOrb.show()
	$JoinInputContainer/JoinFail.hide()

func on_join_success() -> void:
	$JoinInputContainer.hide()
	show_lobby()

func on_join_fail() -> void:
	$JoinInputContainer/LoadingOrb.hide()
	$JoinInputContainer/JoinFail.show()

func _on_label_meta_clicked(meta: Variant) -> void:
	print(meta)
	OS.shell_open(str(meta))


func _on_go_back_pressed() -> void:
	$ButtonContainer.show()
	$JoinInputContainer.hide()
