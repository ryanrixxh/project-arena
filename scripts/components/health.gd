# Component for health definition and any utility functions around the health value
# Added to scenes of entities that have a health and can die i.e. players
class_name HealthComponent extends Node

@export var health = 1000
@export var free_on_death = true

func _ready() -> void:
	check_health()

func check_health():
	print(health)
	if health <= 0 and free_on_death:
		get_parent().queue_free()
