extends Node

const IP_ADDRESS = "localhost" #FIXME: This will need to change to be inputable
const PORT = 10567
const MAX_PEERS = 4

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

func start_game():
	assert(multiplayer.is_server())
	
	# Tell all other clients to load the game world
	load_main.rpc()
	
	# Load all players into the game world
	var player_scene = load("res://scenes/player.tscn")
	var spawn_position = Vector2(1000,500)
	
	# The host wont see any incoming connection from itself, so we need to add it as a player manually
	players.push_front(str(1))
	
	for p in players:
		var player: Player = player_scene.instantiate()
		player.spawn_position = spawn_position
		player.name = str(p)
		get_tree().root.get_node("Main").call_deferred("add_child", player)
		
		spawn_position = spawn_position + Vector2(300, 0)

@rpc("call_local")
func load_main():
	print("Loading game world for client: ", multiplayer.get_remote_sender_id())
	var main = load("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child(main)
	get_tree().root.get_node("Lobby").hide()
	
