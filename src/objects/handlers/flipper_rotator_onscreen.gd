## Must be a child of [FlipperRotator].
extends VisibleOnScreenNotifier2D

@onready var rotator: FlipperRotator = get_parent()

func _en() -> void:
	if rotator:
		rotator.can_play_sound = true
	else:
		push_error(str(self) + " is not child of " + str(FlipperRotator))
	#RuntimeMgr.number_of_flipper_rotators_onscreen += 1

func _ex() -> void:
	if rotator:
		rotator.can_play_sound = false
		rotator.play_rotator_sound(false)
		
	else:
		push_error(str(self) + " is not child of " + str(FlipperRotator))
	#RuntimeMgr.number_of_flipper_rotators_onscreen -= 1
