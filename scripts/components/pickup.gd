class_name Pickup extends Node

#TODO: Its worth reconsidering this component structure. Seems like its not actually providing much benefit? 
# Hard to tell though, will need to make more pickups to see

@export var pickup: RigidBody2D
@export var pickup_area: Area2D
@export var pickup_light: PointLight2D
@export var cooldown_timer: Timer
@export var weapon_scene_address: String = "res://scenes/Weapon/weapon.tscn"

var weapon_scene: PackedScene = load(weapon_scene_address) # Can't preload this because its called from an export var
var pickup_blocked = true
var player_in_range = false

func _on_pickup_area_area_entered(area: Area2D) -> void:
	# Only players should trigger pickup logic
	if area.owner.get_script().get_global_name() != "Player" or pickup_blocked:
		return

	if (area.owner as Player).state.equipped_weapon and (area.owner as Player).state.equipped_weapon is Weapon:
		return

	var player: Player = area.owner
	player_in_range = true
	toggle_light.rpc_id(player.get_multiplayer_authority())
	
	#Tell the player this pickup can be equipped
	player.allow_equip.emit(self)

func _on_pickup_area_area_exited(area: Area2D) -> void:	
	# Only players should trigger pickup logic
	if !area.owner or area.owner.get_script().get_global_name() != "Player" or pickup_blocked:
		return
	
	var player: Player = area.owner
	player_in_range = false
	
	# FIXME: This signal is triggered, and the below line produces an error, when equipping happens and the pickup despawns.
	# It doesnt seem to effect anything, but its red and in big capital letter, so it could be bad later.
	if area.is_inside_tree() and area.multiplayer.get_unique_id() == player.get_multiplayer_authority():
		toggle_light()
	
	#Tell the player that this is no longer available to equip
	player.allow_equip.emit(null)

func _on_cooldown_timer_timeout() -> void:
	pickup_blocked = false

## Despawns 	
@rpc("any_peer", "call_local", "reliable")
func server_despawn():
	if multiplayer.is_server():
		pickup.queue_free()

## Toggles a pickup light. Should only be called on the client which is interacting it by using the multiplayer authority of the player body
@rpc("any_peer", "call_local")
func toggle_light():	
	if player_in_range:
		pickup_light.show()
	else:
		pickup_light.hide()
