extends Line2D
 
var trail: Array[Vector2]
@export var max_length: int = 20
 
func _process(_delta: float) -> void:
	var pos = get_global_mouse_position()

	trail.push_front(pos)
 
	if trail.size() > max_length:
		trail.pop_back()
 
	clear_points()
 
	for point in trail:
		add_point(point)
