class_name ScoreDisplay extends Control

enum Presentation {
	COMPACT,
	RESULTS
}

@export var presentation: Presentation = Presentation.COMPACT

@onready var round_label: Label = %RoundLabel
@onready var score_rows: VBoxContainer = %ScoreRows

func _ready() -> void:
	_apply_presentation()
	if not Gamestate.score_changed.is_connected(_refresh_scores):
		Gamestate.score_changed.connect(_refresh_scores)
	_refresh_scores()

func _exit_tree() -> void:
	if Gamestate.score_changed.is_connected(_refresh_scores):
		Gamestate.score_changed.disconnect(_refresh_scores)

func _refresh_scores() -> void:
	round_label.text = _get_title_text()
	for child in score_rows.get_children():
		child.queue_free()

	var scores = Gamestate.get_score_snapshot()
	if scores.is_empty():
		_add_empty_score_row()
		return

	for score in scores:
		_add_score_row(str(score["player_id"]), int(score["wins"]))

func _apply_presentation() -> void:
	match presentation:
		Presentation.COMPACT:
			round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			round_label.add_theme_font_size_override("font_size", 24)
			score_rows.add_theme_constant_override("separation", 2)
		Presentation.RESULTS:
			round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			round_label.add_theme_font_size_override("font_size", 34)
			score_rows.add_theme_constant_override("separation", 8)

func _get_title_text() -> String:
	match presentation:
		Presentation.RESULTS:
			return "Scoreboard"
		_:
			return "Round " + str(Gamestate.current_round)

func _add_empty_score_row() -> void:
	var label = Label.new()
	label.text = "No scores yet"
	label.clip_text = true
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if presentation == Presentation.RESULTS else HORIZONTAL_ALIGNMENT_RIGHT
	label.add_theme_font_size_override("font_size", _get_row_font_size())
	score_rows.add_child(label)

func _add_score_row(player_id: String, wins: int) -> void:
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 12)

	var player_label = Label.new()
	player_label.text = "Player " + player_id
	player_label.clip_text = true
	player_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_label.add_theme_font_size_override("font_size", _get_row_font_size())
	row.add_child(player_label)

	var score_label = Label.new()
	score_label.text = str(wins)
	score_label.clip_text = true
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.custom_minimum_size.x = 32 if presentation == Presentation.COMPACT else 72
	score_label.add_theme_font_size_override("font_size", _get_row_font_size())
	row.add_child(score_label)

	score_rows.add_child(row)

func _get_row_font_size() -> int:
	return 28 if presentation == Presentation.RESULTS else 20
