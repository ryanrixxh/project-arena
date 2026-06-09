# Component for health definition and any utility functions around the health value
# Added to scenes of entities that have a health and can die i.e. players

# TODO: Dont think this needs to be a component. Doesnt really make much sense as this wont apply to much else
class_name Health extends Node

@export var health = 1000
@export var free_on_death = true

func _ready() -> void:
	check_health()

func check_health():
	get_parent().get_node("DebugLabels/HealthLabelDebug").text = str(health)
	if health <= 0 and free_on_death:
		$"../MultiplayerSynchronizer".public_visibility = false
		die.rpc_id(Gamestate.SERVER_AUTHORITY)

## Tells the server to free the player
@rpc("call_local")
func die():
	get_parent().queue_free()
