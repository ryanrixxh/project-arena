extends Node

const IP_ADDRESS = "localhost" #FIXME: This will need to change to be inputable
const PORT = 10567
const MAX_PEERS = 4

const SERVER_AUTHORITY = 1
const PEER_SYNC_INTERVAL = 0.5

signal players_changed
signal score_changed
var player_ids = []

var current_round = 0
var current_round_winner: Player = null

var winning_rounds_required = 3
var win_tally = {}
var game_winner: Player = null

## CLIENT SIDE
var local_players: int = 0

func _ready() -> void:
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.connected_to_server.connect(connected_to_server)

# The peer for this client
var peer: ENetMultiplayerPeer = null
var peer_sync_elapsed = 0.0

func _process(delta: float) -> void:
	if not multiplayer.is_server() or peer == null:
		return

	peer_sync_elapsed += delta
	if peer_sync_elapsed < PEER_SYNC_INTERVAL:
		return

	peer_sync_elapsed = 0.0
	register_connected_peers()

func host():
	print("Starting game server")
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_PEERS)
	multiplayer.multiplayer_peer = peer
	register_player(multiplayer.get_unique_id())
	
func join():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func player_connected(id: int):
	if multiplayer.is_server():
		register_player(id)

func register_connected_peers() -> void:
	for id in multiplayer.get_peers():
		register_player(id)

func connected_to_server() -> void:
	request_registration.rpc_id(SERVER_AUTHORITY)

func local_join() -> void:
	local_players += 1
	request_registration(true)

@rpc("any_peer", "call_local", "reliable")
func request_registration(local: bool = false) -> void:
	if not multiplayer.is_server():
		return
	print(multiplayer.get_unique_id() + local_players)
	
	register_player(multiplayer.get_remote_sender_id() if !local else multiplayer.get_unique_id() + local_players)


func register_player(id: int):
	var player_id = str(id)
	if player_ids.has(player_id):
		return

	player_ids.push_front(player_id)
	win_tally[player_id] = 0
	sync_player_state.rpc(player_ids, win_tally)

@rpc("call_local", "reliable")
func sync_player_state(updated_player_ids: Array, updated_win_tally: Dictionary) -> void:
	player_ids = updated_player_ids.duplicate()
	win_tally = updated_win_tally.duplicate()
	score_changed.emit()
	players_changed.emit()

func get_score_snapshot() -> Array[Dictionary]:
	var ids = win_tally.keys()
	ids.sort_custom(func(a, b): return str(a).to_int() < str(b).to_int())
	var scores: Array[Dictionary] = []
	for id in ids:
		scores.append({
			"player_id": str(id),
			"wins": int(win_tally[id])
		})
	return scores

@rpc("call_local", "reliable")
func sync_score_tally(updated_tally: Dictionary) -> void:
	win_tally = updated_tally.duplicate()
	score_changed.emit()

enum StartSource {
	LOBBY,
	NEXTROUND
}

# TODO: Need to have a seperate start game / start round
func start_game(start_source: StartSource):
	assert(multiplayer.is_server())
	assert(player_ids.size() <= 4)

	sync_player_state.rpc(player_ids, win_tally)

	# Tell all other clients to load the game world
	load_main.rpc(start_source)
	var main = get_tree().root.get_node("Main")
	var player_spawner: MultiplayerSpawner = main.get_node("PlayerSpawner")
	
	# Load all players into the game world
	var spawn_positions = main.get_node("SpawnPositions").get_children().map(func(marker: Marker2D): return marker.global_position)
	
	var latest_remote_index = null
	for i in player_ids.size():
		var authority
		if int(player_ids[i]) == int(player_ids[i-1]) + 1:
			authority = player_ids[latest_remote_index].to_int()
		else:
			authority = player_ids[i].to_int()
			latest_remote_index = i
		player_spawner.spawn({"id": i, "position": spawn_positions[i], "authority": authority})
		

## Ends the round for all players. Called by whichever peer is the last to day when player count is tracked to one by their Main client.
@rpc("any_peer", "call_local")
func end_round(player: Player):
	assert(multiplayer.is_server())
	win_tally[player.name] += 1
	score_changed.emit()
	sync_score_tally.rpc(win_tally)
	load_end_round.rpc(player.name, win_tally[player.name] >= winning_rounds_required)

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
func load_end_round(winner_id, game_over: bool):
	var end_round_screen: EndRound = load("res://scenes/end_round_screen.tscn").instantiate()
	end_round_screen.game_over = game_over
	var main = get_tree().root.get_node("Main")
	var winner: Player = main.find_child(winner_id, true, false) 
	var winner_sprite: AnimatedSprite2D = winner.find_child("WizardSprite").duplicate() # Duplicate here to remove any chance of trying to reparent a freed node
	
	get_tree().root.add_child(end_round_screen)
	end_round_screen.add_child(winner_sprite)
	
	# TODO: This can be moved to end_round.gd script 
	end_round_screen.find_child("WinnerLabel").text = winner_id + " has won the " + ("game!" if game_over else "round")
	winner_sprite.global_position = end_round_screen.find_child("SpriteMarker").global_position
	winner_sprite.scale = Vector2(0.8, 0.8)

	main.queue_free()

@rpc("call_local")
func load_lobby():
	var lobby = load("res://scenes/lobby.tscn").instantiate()
	var end_round_screen = get_tree().root.get_node("EndRoundScreen")
	
	get_tree().root.add_child(lobby)
	end_round_screen.queue_free()

	
