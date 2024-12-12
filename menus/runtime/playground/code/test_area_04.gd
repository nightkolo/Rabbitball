extends Node2D

@onready var switch: Switch = $Switch
@onready var door: Door = $Door

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	replay()
	await get_tree().create_timer(1.0).timeout
	replay_2()


func replay() -> void:
	anim_1()
	await get_tree().create_timer(2.0).timeout
	replay()

func replay_2() -> void:
	anim_2()
	await get_tree().create_timer(2.0).timeout
	replay_2()


func anim_1() -> void:
	door.anim_activated()
	
func anim_2() -> void:
	door.anim_deactivated()
