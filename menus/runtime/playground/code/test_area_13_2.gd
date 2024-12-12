extends Node2D

@onready var pointer_thing: Node2D = $PointerThing
@onready var pointer_thing_2: Node2D = $PointerThing3

@onready var launcher: Node2D = $Launcher # done

@onready var bumper: Bumper = $Bumper# done
@onready var bumper_2: Bumper = $Bumper2# done

@onready var door: Door = $Door# done
@onready var door_2: Door = $Door2# done

@onready var switch: Switch = $Switch# done

@onready var flipper_scissor: Node2D = $FlipperScissor # done
@onready var flipper_scissor_2: Node2D = $FlipperScissor2 # done

@onready var flipper_rotator: FlipperRotator = $FlipperRotator# done
@onready var flipper_rotator_2: FlipperRotator = $FlipperRotator2# done


func _ready() -> void:
	anim_loop()


func anim_loop() -> void:
	anim_loop_1()
	await get_tree().create_timer(1.5).timeout
	anim_loop_2()


func anim_loop_1() -> void:
	print("one")
	PlayerInput.FLIP_A_HELD = true
	PlayerInput.FLIP_B_HELD = true
	launcher.hold_or_release(true)
	switch.anim_hit()
	door._anim.play("on")
	door_2._anim.play("on")
	flipper_scissor.move_down()
	flipper_scissor_2.move_down()
	bumper.anim_bounce()
	bumper_2.anim_bounce()
	pointer_thing.anim_down()
	pointer_thing_2.anim_down()
	await get_tree().create_timer(3.0).timeout
	anim_loop_1()


func anim_loop_2() -> void:
	print("two")
	PlayerInput.FLIP_A_HELD = false
	PlayerInput.FLIP_B_HELD = false
	launcher.hold_or_release(false)
	switch.anim_unhit()
	door._anim.play("off")
	door_2._anim.play("off")
	flipper_scissor.move_up()
	flipper_scissor_2.move_up()
	bumper.anim_bounce()
	bumper_2.anim_bounce()
	pointer_thing.anim_up()
	pointer_thing_2.anim_up()
	await get_tree().create_timer(3.0).timeout
	anim_loop_2()
