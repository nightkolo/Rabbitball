class_name OneWayPlatform
extends StaticBody2D

@export var enable_one_way_collision: bool = true


func _ready() -> void:
	var platform: CollisionPolygon2D = get_node_or_null("CollisionPolygon2D")
	
	if platform:
		platform.one_way_collision = enable_one_way_collision
