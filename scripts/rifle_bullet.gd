class_name Bullet extends Area2D

@export var bullet_speed = 400
@export var damage_multi = 1
@export var damage: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	position += transform.x * bullet_speed

func _on_body_entered(body: Node2D) -> void:
	queue_free()
	pass

func _on_area_entered(area: Area2D) -> void:
	hit(area)
	queue_free()
	pass # Replace with function body.

func hit(area: Area2D):
	var target: Target = area.get_parent()
	target.health -= damage
	target.check_health()
