extends Node2D

@export var pickup_scene = preload("res://scenes/Weapon/pickup.tscn")

var pickup_count = 0

# TODO: Dictionary of players to keep track of winners and losers
var player_count = 0
var spawn_positions

func _ready() -> void:
	spawn_positions = $SpawnPositions.get_children().map(func(marker: Marker2D): return marker.global_position)
	spawn_initial_pickups()
	
func spawn_initial_pickups():
	if not multiplayer.is_server(): return
	%PickupSpawner.spawn(["Pickup" + str(pickup_count), Vector2(500, 200), 1000, Vector2(1,1)])
	

# ONLY CALLED ON REMOTE PEERS, NOT HOST
func _on_player_spawner_spawned(player: Player) -> void:
	# We need to set position here, because the MultiplayerSynchroniser doesn't work on spawn, so otherwise remote peers will have players spawn at (0,0)
	player.global_position = spawn_positions[player_count]
	player_count += 1

func _on_player_spawner_despawned(player: Player) -> void:
	show_death_screen.rpc_id(int(player.name))
	player_count -= 1
	
	# Last player surviving triggers the end of the round
	if player_count == 1:
		Gamestate.end_round.rpc_id(Gamestate.SERVER_AUTHORITY)

@rpc("any_peer", "call_local")
func show_death_screen():
	$DeathScreen.show()
