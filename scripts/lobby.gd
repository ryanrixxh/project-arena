extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Gamestate.players_changed.connect(load_player_list)

func load_player_list():
	var player_ids = Gamestate.player_ids
	player_ids.sort()
	$PlayerPanel/PlayerList.clear()
	$PlayerPanel/PlayerList.add_item(str(multiplayer.get_unique_id()) + "(You)")
	for p in player_ids:
		$PlayerPanel/PlayerList.add_item(str(p))

func _on_host_button_pressed() -> void:
	$ButtonContainer.hide()
	$PlayerPanel.show()
	$StartGameButton.show()
	Gamestate.host()
	load_player_list()


func _on_join_button_pressed() -> void:
	$ButtonContainer.hide()
	$PlayerPanel.show()
	Gamestate.join()
	load_player_list()


func _on_start_game_button_pressed() -> void:
	Gamestate.start_game(Gamestate.StartSource.LOBBY)
