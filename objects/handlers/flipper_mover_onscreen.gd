extends VisibleOnScreenNotifier2D

func _on_screen_entered() -> void:
	if (get_parent() as FlipperMover).is_flipper == RuntimeMgr.FlipperType.A:
		RuntimeMgr.flipper_A_movers_onscreen += 1
	elif (get_parent() as FlipperMover).is_flipper == RuntimeMgr.FlipperType.B:
		RuntimeMgr.flipper_B_movers_onscreen += 1
	
func _on_screen_exited() -> void:
	if (get_parent() as FlipperMover).is_flipper == RuntimeMgr.FlipperType.A:
		RuntimeMgr.flipper_A_movers_onscreen -= 1
	elif (get_parent() as FlipperMover).is_flipper == RuntimeMgr.FlipperType.B:
		RuntimeMgr.flipper_B_movers_onscreen -= 1
