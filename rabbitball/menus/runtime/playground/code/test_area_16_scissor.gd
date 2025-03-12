extends Node2D

@onready var hold_boundry: Array[StaticBody2D] = [$HoldBoundry, $HoldBoundry2, $HoldBoundry3]


func _process(_delta: float) -> void:
	for boundry: StaticBody2D in hold_boundry:
		boundry.get_node("CollisionPolygon2D").set_deferred("disabled", PlayerInput.FLIP_A_HELD)
