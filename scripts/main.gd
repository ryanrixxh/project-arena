extends Node2D

@export var pickup_scene = preload("res://scenes/Weapon/pickup.tscn")

var pickup_count = 0

# TODO: Dictionary of players to keep track of winners and losers
# TODO: Spawn logic should be in here so then we can keep track of despawning it aswell
var player_count = 0
var players = {}
var spawn_positions

func _ready() -> void:
	spawn_positions = $SpawnPositions.get_children().map(func(marker: Marker2D): return marker.global_position)
	spawn_initial_pickups()
	
func spawn_initial_pickups():
	if not multiplayer.is_server(): return
	%PickupSpawner.spawn(["Pickup" + str(pickup_count), Vector2(500, 200), 1000, Vector2(1,1)])
	

# ONLY CALLED ON REMOTE PEERS, NOT HOST
func _on_player_spawner_spawned(player: Player) -> void:
	# We need to set position here using player count, because the MultiplayerSynchroniser doesn't work on spawn, so otherwise remote peers will have players spawn at (0,0)
	# Note: clients themselves dont actually use or care about player_count beyond this point, as its the host responsibility to keep track of it
	player.global_position = spawn_positions[player_count]
	player_count += 1

## Keep track of when a player exits 
func _on_child_entered_tree(node: Node) -> void:
	if !node.get_script() or node.get_script().get_global_name() != "Player": return
	if multiplayer.is_server():
		player_count += 1

## Keep track of when a child is exiting the tree. Only perform actions on this when we are the server, to prevent repeat handling of state changes
func _on_child_exiting_tree(node: Node) -> void:
	if !node.get_script() or node.get_script().get_global_name() != "Player": return
	
	if node.name == str(multiplayer.get_unique_id()):
		$DeathScreen.show()
	
	if multiplayer.is_server():
		player_count -= 1
		print(player_count)
		if player_count == 1:
			Gamestate.end_round()
