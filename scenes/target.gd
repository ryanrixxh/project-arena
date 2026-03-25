class_name Target extends Node2D


@export var health = 1000
@onready var label = $Label

func _ready() -> void:
	check_health()

func check_health():
	label.text = "Health: " + str(health)
	if health <= 0:
		queue_free()
