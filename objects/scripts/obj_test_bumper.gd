extends Area2D


func _ready() -> void:
	body_entered.connect(func(body: Node2D):
		if body is Rabbitball:
			(body as Rabbitball).linear_velocity = Vector2(2000.0,-500.0)
		)
		
