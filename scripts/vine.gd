extends Area2D

signal grabbed(body: Node2D, source: Node2D)

var swinging_left = true
var grab_marker: Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grab_marker = get_node("GrabMarker")
	body_entered.connect(on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process_swing()

# Processes the swinging motion of the vine, reversing direction when 90 degrees is hit
# TODO: Make this configurable - so that vines can rotate at different speeds and lengths 
func process_swing() -> void:
	if rotation_degrees > 90:
		swinging_left = false
	
	if rotation_degrees < -90:
		swinging_left = true
		
	rotation_degrees = rotation_degrees + 0.5 if swinging_left else rotation_degrees - 0.5

func on_body_entered(body: Node2D):
	grab_marker.global_position = body.global_position
	
	# For debugging
	#var box = ColorRect.new()
	#box.size = Vector2(20,20)
	#grab_marker.add_child(box)
	
	grabbed.emit(body, self)
