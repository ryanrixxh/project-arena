class_name EndRound extends Control

@export var game_over: bool = false

func _ready() -> void:
	$EndRoundLabel.text = "Game Over" if game_over else "Round Over"
	if multiplayer.is_server():
		if game_over:
			$ReturnToLobbyButton.show()
		else:
			$NextRoundButton.show()

func _on_next_round_button_pressed() -> void:
	assert(multiplayer.is_server())
	Gamestate.start_game(Gamestate.StartSource.NEXTROUND)


func _on_return_to_lobby_button_pressed() -> void:
	assert(multiplayer.is_server())
	Gamestate.load_lobby.rpc()
