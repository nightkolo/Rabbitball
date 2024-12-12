class_name LetterAnimArea
extends Area2D

signal spin()


func _ready() -> void:
	body_entered.connect(func(body: Node2D):
		if body is Rabbitball:
			spin.emit()
		)
