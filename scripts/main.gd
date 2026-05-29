extends Node2D

@export var pickup_scene = preload("res://scenes/Weapon/pickup.tscn")

var pickup_count = 0

# TODO: Dictionary of players to keep track of winners and losers
var player_count = 0

func _ready() -> void:
	spawn_initial_pickups()
	
func spawn_initial_pickups():
	if not multiplayer.is_server(): return
	%PickupSpawner.spawn(["Pickup" + str(pickup_count), Vector2(500, 200), 1000, Vector2(1,1)])

func _on_player_spawner_spawned(node: Node) -> void:
	print_debug("Player spawned! ", node.name)
	player_count += 1
	print("Player count: ", player_count)

func _on_player_spawner_despawned(node: Node) -> void:
	# TODO: If we had a dictionary of players, we'd be able to rpc the player who has despawned to notify their client of a game over for them.
	# With the ability spectate of course ;)
	player_count -= 1
	if player_count == 1:
		end_round()
	print("Player count: ", player_count)

func end_round() -> void:
	# TODO: This needs to load a brand new Game Over scene!
	print("ROUND OVER")
	return
