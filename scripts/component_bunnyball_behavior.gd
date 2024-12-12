class_name BunnyballBehaviorComponent
extends Node

@onready var bunnyball: Bunnyball = get_parent()

@export var remove_off_screen: bool = false


func _ready() -> void:
	await bunnyball.ready
	
	if remove_off_screen:
		bunnyball.screen_notifier.screen_entered.connect(func():
			bunnyball.screen_notifier.screen_exited.connect(func():
				bunnyball.queue_free()
			)
		)
		
