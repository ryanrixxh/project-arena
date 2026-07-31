extends RigidBody2D

@export var type := "frog"
@export var damage := 450
@export var max_jumps := 5
@export var jump_distance := 500
@export var jump_height := 1000

var from_player: bool
var travelling_left: bool
var current_jumps := 0
var	direction_scaler: int = 1

func _ready() -> void:
	if not from_player:
		$ComboExplosion.play("explode")
	current_jumps = 0
	global_rotation = 0
	set_travel_direction()
	
func _on_pickup_body_entered(body: Node) -> void:	
	if not from_player: return
	
	$Sprite2D.play("bounce")
	$DamageArea/FrogExplosion.play("explode")
	await $Sprite2D.animation_finished
	
	# Get all players in the area of the frog when it collides and do damage to them
	var collided_players: Array[Node2D] = $DamageArea.get_overlapping_bodies().filter(func(body): return body is CharacterBody2D)
	for player in collided_players:
		var index = player.get_children().find_custom(func(child: Node): return child is Health) #FIXME: Having to perform a search every time we do damage is going to seriously hurt performance long run
		if (index != -1):
			do_damage(player.get_child(index))
	
	if current_jumps == max_jumps and from_player:
		$Pickup.call_deferred("server_despawn")
		return
	
	# Jump again
	set_travel_direction()
	apply_impulse(Vector2(jump_distance * direction_scaler, -1 * jump_height))
	if current_jumps < max_jumps:
		current_jumps += 1
		

func set_travel_direction() -> void:
	await get_tree().create_timer(0.2).timeout	
	direction_scaler = -1 if linear_velocity.x < 0 else 1

func do_damage(health_component: Health) -> void:
	health_component.damage.rpc_id(health_component.get_multiplayer_authority(), damage)
