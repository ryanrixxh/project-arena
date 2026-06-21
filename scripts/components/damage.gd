class_name Damage extends Node

@export var pickup_body: RigidBody2D
@export var damage_multiplier: int
@export var damage_minimum: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func calculate_damage() -> int:
	var damage = (abs(pickup_body.linear_velocity[0]) + abs(pickup_body.linear_velocity[1])) * damage_multiplier / 10
	if damage < damage_minimum:
		return 0
	else:
		return damage

func _on_pickup_body_entered(body: Node) -> void:
	var index = body.get_children().find_custom(func(child: Node): return child is Health)
	if (index != -1):
		do_damage(calculate_damage(), body.get_child(index))

func do_damage(damage: int, health_component: Health) -> void:
	health_component.damaged.emit(damage)
