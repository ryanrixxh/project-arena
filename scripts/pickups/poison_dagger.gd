extends RigidBody2D

var from_player: bool

@export var type := "poison_dagger"
@export var damage: int
@export var dot_ticks: int
@export var tick_damage: int

func _on_pickup_body_entered(body: Node) -> void:	
	var index = body.get_children().find_custom(func(child: Node): return child is Health)
	if (index != -1):
		do_damage(body.get_child(index))
	if body is Player:
		body.poison.rpc_id(body.get_multiplayer_authority(), dot_ticks, tick_damage)
		$Pickup.call_deferred("server_despawn")
	
	if from_player:
		$Pickup.call_deferred("server_despawn")

func do_damage(health_component: Health) -> void:
	health_component.damage.rpc_id(health_component.get_multiplayer_authority(), damage)
