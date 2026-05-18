extends Node

const IP_ADDR: String = "localhost"
const PORT: int = 8080

var peer: ENetMultiplayerPeer

func start_server() -> void:
	print("Starting multiplayer server")
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer

func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDR, PORT)
	multiplayer.multiplayer_peer = peer
