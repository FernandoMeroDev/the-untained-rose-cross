extends Sprite2D

## Blood Textures
var textures: Array[Texture] = []

func _ready() -> void:
	textures.append(preload("res://media/battle/vfx/blood/blood_1.png"))
	textures.append(preload("res://media/battle/vfx/blood/blood_2.png"))
	textures.append(preload("res://media/battle/vfx/blood/blood_3.png"))

func splash() -> void:
	texture = textures.pick_random()
	show()
	# Fade out animation
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.finished.connect(
		func():
			hide()
			modulate.a = 1.0
	)
	await tween.finished
