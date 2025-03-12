## [b]Warning:[/b] shes a lil kawaii ball :3
class_name ChibiRabbitball
extends Sprite2D

@export var mimick_rabbits_rotation: bool = true
@export var greyscale: bool = false
@export_group("Assets")
@export var asset_colorful: Texture2D = preload("res://assets/objects/rabbitball-chibi.png")
@export var asset_greyscale: Texture2D = preload("res://assets/world/rabbitball-chibi-greyscale.png")


func _ready() -> void:
	if greyscale:
		texture = asset_greyscale
	else:
		texture = asset_colorful


func _process(_delta: float) -> void:
	if RuntimeMgr.current_rabbitball != null && mimick_rabbits_rotation:
		rotation = RuntimeMgr.current_rabbitball.rotation
		#rotation = lerpf(rotation, RuntimeMgr.current_rabbitball.rotation, delta * 24.0)
		
#		$Sprite2D.position = $Sprite2D.position.lerp(mouse_pos, delta * FOLLOW_SPEED)
		
	elif !mimick_rabbits_rotation:
		set_process(false)
