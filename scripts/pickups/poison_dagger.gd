extends RigidBody2D

@export var type: String = "poison_dagger"
@export var damage: int
@export var dot_ticks: int
@export var tick_damage: int

func _on_pickup_body_entered(body: Node) -> void:	
	var index = body.get_children().find_custom(func(child: Node): return child is Health)
	if (index != -1):
		do_damage(damage, body.get_child(index))
	if body is Player:
		body.poison(dot_ticks, tick_damage)
		

func do_damage(damage: int, health_component: Health) -> void:
	health_component.damaged.emit(damage)
