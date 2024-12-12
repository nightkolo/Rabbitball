extends Node2D

@export var anim_scale: float = 1.0

@onready var bumper: Bumper = $Bumper
@onready var bumper_2: Bumper = $Bumper2
@onready var door: Door = $Door


func _ready() -> void:
	for bump: Bumper in [bumper_2, bumper]:
		bump.preview_loop_anim()
	anim_loop()


func anim_loop() -> void:
	anim_loop_1()
	await get_tree().create_timer(1.0).timeout
	anim_loop_2()

func anim_loop_1() -> void:
	($Launcher/AnimationPlayer as AnimationPlayer).play("rest")
	($Launcher2/AnimationPlayer as AnimationPlayer).play("rest")
	($FlipperScissor/AnimationPlayer as AnimationPlayer).play("hold")
	door.anim.play("on")
	await get_tree().create_timer(2.0).timeout
	anim_loop_1()


func anim_loop_2() -> void:
	($Launcher/AnimationPlayer as AnimationPlayer).play("rest")
	($Launcher2/AnimationPlayer as AnimationPlayer).play("rest")
	($FlipperScissor/AnimationPlayer as AnimationPlayer).play("rest")
	door.anim.play("off")
	await get_tree().create_timer(2.0).timeout
	anim_loop_2()
