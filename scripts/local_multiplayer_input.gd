extends Node

var player_controls = ["left", "right", "jump", "down", "throw", "equip"]
var inputs

# IMPORTANT: This is client side, these IDs can and should conflict with each other on the client end.
# How the actual networked IDs of these players is resolved, or if they even need to be resolved is another question entirely

func _ready() -> void:
	# Filter all the inputs we care about
	inputs = InputMap.get_actions().filter(func(input: String): return player_controls.has(input))

## Duplicates all inputs by creating a new set of actions. These actions are then wiped of their original input events, and assigned events with a device id that matches the local_input_id argument.
func duplicateInputs(local_input_id: int):
	var new_actions = []
	for input in inputs:
		var new_action = input + "_" + str(local_input_id)
		# FIXME: InputMap is recieving duplicate actions. Its ignoring them because its a Dictionary, so nothing breaks. But should be fixed.
		InputMap.add_action(new_action)
		new_actions.push_back(new_action)
		
		var new_events = []
		var events = InputMap.action_get_events(input)
		InputMap.action_erase_events(new_action)
		for event in events:
			var new_event = event.duplicate(true)
			new_event.device = local_input_id
			InputMap.action_add_event(new_action, new_event)
			new_events.push_back(new_event)
	
	return new_actions
