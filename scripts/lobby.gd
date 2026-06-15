extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Gamestate.players_changed.connect(load_player_list)
	if Gamestate.player_ids.size() > 0:
		show_lobby()

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
	Gamestate.join()
	show_lobby()

func _on_start_game_button_pressed() -> void:
	Gamestate.start_game(Gamestate.StartSource.LOBBY)

func show_lobby():
	$ButtonContainer.hide()
	$PlayerPanel.show()
	if multiplayer.is_server():
		$StartGameButton.show()
	load_player_list()
