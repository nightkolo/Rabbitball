class_name LauncherTrail
extends Line2D
 
var trail: Array[Vector2]
@export var max_length: int = 10
 
var show_trail: bool = false


func _process(_delta: float) -> void:
	if show_trail:
		var pos = (get_parent() as Launcher).position

		trail.push_front(pos)
	 
		if trail.size() > max_length:
			trail.pop_back()
	 
		clear_points()
	 
		for point: Vector2 in trail:
			add_point(point)
