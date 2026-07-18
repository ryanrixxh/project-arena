extends RigidBody2D

@export var type: String = "boulder"
@export var damage: int

func _on_pickup_body_entered(body: Node) -> void:
	var index = body.get_children().find_custom(func(child: Node): return child is Health)
	if (index != -1):
		do_damage(damage, body.get_child(index))

func do_damage(damage: int, health_component: Health) -> void:
	health_component.damaged.emit(damage)
