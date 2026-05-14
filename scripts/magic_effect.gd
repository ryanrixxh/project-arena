extends AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Regardless of the rotation occuring on the rest of the objects, this effect should remain upright
	# This forces that at every process loop
	global_rotation = 0 
