class_name Pickup extends Node

@export var pickup: RigidBody2D
@export var pickup_area: Area2D
@export var weapon_scene_address: String = "res://scenes/Weapon/weapon.tscn"
var weapon_scene: PackedScene = load(weapon_scene_address) # Can't preload this because its called from an export var
var can_pickup = false

#FIXME: This pickup component does not have authority to despawn the pickup when it gets picked up. 
# Need an RPC call, to tell the server to do the despawning instead!

func _on_pickup_area_area_entered(area: Area2D) -> void:
	# Only players should trigger pickup logic
	if area.get_parent() is not Player or not can_pickup:
		return
	
	if (area.get_parent() as Player).state.equipped_weapon is Weapon:
		print("A weapon is already equipped, skipping equip logic")
		return
		
	var player: Player = area.get_parent()
	print(str(multiplayer.get_unique_id()) + ": Is emitting equip signal")
	player.equip.emit(weapon_scene)
	server_despawn.rpc()

func _on_cooldown_timer_timeout() -> void:
	can_pickup = true

@rpc("any_peer", "call_local", "reliable")
func server_despawn():
	if multiplayer.is_server():
		var callable_pickup_destroy = pickup.queue_free.bind()
		#get_tree().process_frame.connect()
		
		#FIXME: Unless this delay is added, the Main trees PickupSpawner may delete a Pickup on the server side, before the player script has a chance
		# to see and equip it. This means that once colliding with the players hitbox, it will effectively vanish into thin air. 
		
		# The fix for this is probably just signal ordering. Instead of emitting, and then immediately despawning the item. We should emit a signal,
		# and then somehow await some kind of response from the equip (another signal maybe?) before executing the server_despawn.rpc() call.
		
		# Manual pickup events will need to implement this signal waiting anyway, so maybe the fix is just to make that happen
		get_tree().create_timer(0.2).timeout.connect(callable_pickup_destroy, CONNECT_ONE_SHOT)
		
