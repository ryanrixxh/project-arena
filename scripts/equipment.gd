extends Node2D
@onready var aim_area = $WeaponMarker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	follow_mouse()
	
func follow_mouse():
	var mouse_pos = get_global_mouse_position()
	aim_area.look_at(mouse_pos)
 
