## Here's a little lesson in trickery
extends Area2D

@export var remove_objects: bool = true
@export var objects: Array[Node2D]


func _ready() -> void:
	collision_layer = 0
	collision_mask = 48


func _en(body: Node2D) -> void:
	if (remove_objects && body is Rabbitball):
		for obj: Node2D in objects:
			obj.queue_free()
