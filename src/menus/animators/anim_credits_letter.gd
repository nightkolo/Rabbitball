extends Label

@export var anim_area: PackedScene = preload("res://objects/interface/credits_letter_anim_area.tscn")

var is_spinning: bool
var tween: Tween


func _ready() -> void:
	pivot_offset = size / 2
	
	var letter_area: LetterAnimArea = anim_area.instantiate()
	letter_area.position.y += 13.0
	add_child(letter_area)
	
	letter_area.spin.connect(anim_letter_spin)


func anim_letter_spin() -> void:
	var aud: AudioStreamPlayer = Audio.letter_spin
	aud.play()
	
	if !is_spinning:
		is_spinning = true
		if tween:
			tween.kill()
		tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self,"scale:x",-1.0,0.4)
		tween.tween_property(self,"scale:x",1.0,0.4)
		await tween.finished
		is_spinning = false
