extends Control

func _ready() -> void:
	if multiplayer.is_server():
		$NextRoundButton.show()

func _on_next_round_button_pressed() -> void:
	assert(multiplayer.is_server())
	Gamestate.start_game(Gamestate.StartSource.NEXTROUND)
