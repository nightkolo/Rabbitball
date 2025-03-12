extends VisibleOnScreenNotifier2D

func _en() -> void:
	if (get_parent() as FlipperBlock).is_flipper == RuntimeMgr.FlipperType.A:
		RuntimeMgr.flipper_A_blocks_onscreen += 1
	elif (get_parent() as FlipperBlock).is_flipper == RuntimeMgr.FlipperType.B:
		RuntimeMgr.flipper_B_blocks_onscreen += 1

func _ex() -> void:
	if (get_parent() as FlipperBlock).is_flipper == RuntimeMgr.FlipperType.A:
		RuntimeMgr.flipper_A_blocks_onscreen -= 1
	elif (get_parent() as FlipperBlock).is_flipper == RuntimeMgr.FlipperType.B:
		RuntimeMgr.flipper_B_blocks_onscreen -= 1
