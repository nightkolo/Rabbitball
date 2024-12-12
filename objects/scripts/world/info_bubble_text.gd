## Used only for the short cutscene in the intro.
class_name InfoBubble
extends MarginContainer

signal letter_showing_started()
signal letter_showing_finished()
signal letter_showed() # Could sent each letter through the signal call but it's a bit overkill
signal size_changed(is_size: Vector2)

@onready var info_text: Label = %Label
@onready var audio: AudioStreamPlayer = $Speech

var current_text: String = ""
var letter_index: int = 0
var letter_time: float = 0.04
var space_time: float = 0.06
var punctuation_time: float = 0.3
var speed_up_time: float = 0.01
var speed_it_up: bool = false

const MAX_BUBBLE_WIDTH = 270.0

var _letter_show_timer: Timer = Timer.new()


func _ready() -> void:
	_letter_show_timer.one_shot = true
	add_child(_letter_show_timer)
	
	#letter_showed.connect(func():
		#print("banana")
		#)
	letter_showing_finished.connect(func():
		speed_it_up = false
		)
	_letter_show_timer.timeout.connect(func():
		_show_letter()
		letter_showed.emit()
		)


func show_text(text_to_show: String, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	modulate = Color(Color.WHITE, 0.0)
	current_text = text_to_show
	info_text.horizontal_alignment = align
	info_text.text = text_to_show

	await get_tree().create_timer(0.01).timeout # signal resized doesn't emit
	custom_minimum_size.x = min(size.x, MAX_BUBBLE_WIDTH)
	
	if size.x > MAX_BUBBLE_WIDTH:
		info_text.autowrap_mode = TextServer.AUTOWRAP_WORD
		await get_tree().create_timer(0.02).timeout
		custom_minimum_size.y = size.y
	
	size_changed.emit(size)
	
	# TODO: Add different positioning options
	## positioning for up
	position.x -= size.x / 2
	position.y -= size.y + 28.0
	
	info_text.text = ""
	modulate = Color(Color.WHITE, 1.0)
	await get_tree().create_timer(0.1).timeout
	_show_letter()
	letter_showing_started.emit()


func _show_letter() -> void:
	info_text.text += current_text[letter_index]
	
	letter_index += 1
	if letter_index < current_text.length():
		if speed_it_up:
			_letter_show_timer.start(speed_up_time)
			
		else:
			match current_text[letter_index]:
				
				"!", ",", ".", "?":
					_letter_show_timer.start(letter_time)
					
				" ":
					_letter_show_timer.start(letter_time)
					
				_:
					_letter_show_timer.start(letter_time)
					
					var aud := audio.duplicate() as AudioStreamPlayer
					aud.volume_db = -35.0
					aud.pitch_scale += randf_range(-0.1,0.1)
					get_tree().root.add_child(aud)
					
					if current_text[letter_index] in ["a", "e", "i", "o", "u"]:
						aud.pitch_scale += 0.2
						
					aud.play()
					await aud.finished
					aud.queue_free()
	else:
		letter_showing_finished.emit()
