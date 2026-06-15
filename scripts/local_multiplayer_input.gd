extends Node

var player_controls = ["left", "right", "jump", "down", "throw", "equip"]
var inputs
var inputSets

# TODO: For each player: Duplicate all input actions, assign them an action name that matches the device number
# When a player is created, if created locally, assign input handling to check for the duplicated input actions. 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inputs = InputMap.get_actions().filter(func(input: String): return player_controls.has(input))
	InputMap.get
	print(inputs[0].action)

#func duplicateInputs()
