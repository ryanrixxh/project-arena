extends RigidBody2D

var from_player: bool #TODO: Move to pickup component and use it from there instead?

@export var type:= "boulder"
@export var damage: int

func _on_pickup_body_entered(body: Node) -> void:
	var index = body.get_children().find_custom(func(child: Node): return child is Health)
	if (index != -1):
		do_damage(body.get_child(index))
	
	if from_player:
		$Pickup.call_deferred("server_despawn")

func do_damage(health_component: Health) -> void:
	health_component.damage.rpc_id(health_component.get_multiplayer_authority(), damage)
