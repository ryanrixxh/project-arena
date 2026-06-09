extends Node

const IP_ADDRESS = "localhost" #FIXME: This will need to change to be inputable
const PORT = 10567
const MAX_PEERS = 4

const SERVER_AUTHORITY = 1

signal players_changed
var player_ids = []

var current_round = 0
var current_round_winner: Player = null

var total_rounds = 3
var game_winner: Player = null

func _ready() -> void:
	multiplayer.peer_connected.connect(player_connected)

# The peer for this client
var peer: ENetMultiplayerPeer = null

func host():
	print("Starting game server")
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_PEERS)
	multiplayer.multiplayer_peer = peer
	
func join():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func player_connected(id: int):
	register_player.rpc_id(id)

@rpc("any_peer")
func register_player():
	var id = multiplayer.get_remote_sender_id()
	player_ids.push_front(str(id))
	players_changed.emit()

enum StartSource {
	LOBBY,
	NEXTROUND
}

# TODO: Need to have a seperate start game / start round
func start_game(start_source: StartSource):
	assert(multiplayer.is_server())
	assert(player_ids.size() <= 4)
	
	# Tell all other clients to load the game world
	load_main.rpc(start_source)
	var main = get_tree().root.get_node("Main")
	
	# Load all players into the game world
	var player_scene = load("res://scenes/player.tscn")
	var spawn_positions = main.get_node("SpawnPositions").get_children().map(func(marker: Marker2D): return marker.global_position)
	
	# The host wont see any incoming connection from itself, so we need to add it as a player manually
	if !player_ids.has(str(1)):
		player_ids.push_front(str(1))
	
	
	for i in player_ids.size():
		var player: Player = player_scene.instantiate()
		player.name = str(player_ids[i])
		player.global_position = spawn_positions[i]
		main.add_child(player)

## Ends the round for all players. Called by whichever peer is the last to day when player count is tracked to one by their Main client.
@rpc("any_peer", "call_local")
func end_round(player: Player):
	assert(multiplayer.is_server())
	load_end_round.rpc(player.name)

@rpc("call_local")
func load_main(start_source: StartSource):
	current_round += 1
	var main = load("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child(main)
	match start_source:
		StartSource.LOBBY:
			get_tree().root.get_node("Lobby").queue_free()
		StartSource.NEXTROUND:
			get_tree().root.get_node("EndRoundScreen").queue_free()

@rpc("call_local")
func load_end_round(winner_id):
	var end_round_screen: Control = load("res://scenes/end_round_screen.tscn").instantiate()
	var main = get_tree().root.get_node("Main")
	var winner: Player = main.find_child(winner_id, true, false) 
	var winner_sprite: AnimatedSprite2D = winner.find_child("WizardSprite").duplicate() # Duplicate here to remove any chance of trying to reparent a freed node
	
	get_tree().root.add_child(end_round_screen)
	end_round_screen.add_child(winner_sprite)
	end_round_screen.find_child("WinnerLabel").text = winner_id + " has won the round"
	winner_sprite.global_position = end_round_screen.find_child("SpriteMarker").global_position
	winner_sprite.scale = Vector2(0.8, 0.8)
	
	main.queue_free()

	
