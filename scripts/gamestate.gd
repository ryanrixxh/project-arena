extends Node

const IP_ADDRESS = "localhost" #FIXME: This will need to change to be inputable
const PORT = 10567
const MAX_PEERS = 4

const SERVER_AUTHORITY = 1

signal players_changed
var players = []

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
	print(id, " connected!")
	register_player.rpc_id(id)

@rpc("any_peer")
func register_player():
	print("Registering player: ", multiplayer.get_remote_sender_id())
	var id = multiplayer.get_remote_sender_id()
	players.push_front(str(id))
	players_changed.emit()

enum StartSource {
	LOBBY,
	NEXTROUND
}

# TODO: Need to have a seperate start game / start round
func start_game(start_source: StartSource):
	assert(multiplayer.is_server())
	assert(players.size() <= 4)
	
	# Tell all other clients to load the game world
	load_main.rpc(start_source)
	var main = get_tree().root.get_node("Main")
	
	# Load all players into the game world
	var player_scene = load("res://scenes/player.tscn")
	var spawn_positions = main.get_node("SpawnPositions").get_children().map(func(marker: Marker2D): return marker.global_position)
	
	# The host wont see any incoming connection from itself, so we need to add it as a player manually
	if !players.has(str(1)):
		players.push_front(str(1))
	
	
	for i in players.size():
		var player: Player = player_scene.instantiate()
		player.name = str(players[i])
		player.global_position = spawn_positions[i]
		main.add_child(player)

## Ends the round for all players. Called by whichever peer is the last to day when player count is tracked to one by their Main client.
@rpc("any_peer", "call_local")
func end_round():
	assert(multiplayer.is_server())
	load_end_round.rpc()

@rpc("call_local")
func load_main(start_source: StartSource):
	var main = load("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child(main)
	match start_source:
		StartSource.LOBBY:
			get_tree().root.get_node("Lobby").queue_free()
		StartSource.NEXTROUND:
			get_tree().root.get_node("EndRoundScreen").queue_free()

@rpc("call_local")
func load_end_round():
	var end_round_screen = load("res://scenes/end_round_screen.tscn").instantiate()
	get_tree().root.add_child(end_round_screen)
	get_tree().root.get_node("Main").queue_free()
	
