extends RigidBody2D

@export var damage_multiplier: int
@export var damage_minimum: int

func calculate_damage() -> int:
	# TODO: Rethink this. Its resulting in some really inconsistent damage numbers, which just isnt very fun.
	# Either change the calculation to make the damage far smaller in numbers (which means it varies less since it will have less increments)
	# OR make it entirely static and forget changing damage based on velocity. 
	var damage = (abs(linear_velocity[0]) + abs(linear_velocity[1])) * damage_multiplier / 10
	if damage < damage_minimum:
		return 0
	else:
		return damage

func _on_pickup_body_entered(body: Node) -> void:	
	var index = body.get_children().find_custom(func(child: Node): return child is Health)
	if (index != -1):
		do_damage(calculate_damage(), body.get_child(index))
	if body is Player:
		body.poison(5)
		

func do_damage(damage: int, health_component: Health) -> void:
	health_component.damaged.emit(damage)
