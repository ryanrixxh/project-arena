extends RigidBody2D

@export var type := "frog"
@export var damage: int
@export var max_jumps := 5
@export var jump_distance := 300
@export var jump_height := 750

var current_jumps

func _ready() -> void:
	current_jumps = 0
	global_rotation = 0

func _on_pickup_body_entered(body: Node) -> void:	
	$Sprite2D.play("bounce")
	apply_impulse(Vector2(jump_distance, -1 * jump_height)) #FIXME: The frog will always jump right regardless of which direction it was thrown because of the static x value in this vector
		

func do_damage(damage: int, health_component: Health) -> void:
	health_component.damaged.emit(damage)
