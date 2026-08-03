extends Sprite2D

## Hit Textures
var textures: Dictionary = {
	"blunt": [], "pierce": [], "slash": [], "critical": []
}

func _ready() -> void:
	textures["blunt"].append(preload("res://media/battle/vfx/hit/blunt_orange.png"))
	textures["blunt"].append(preload("res://media/battle/vfx/hit/blunt_yellow.png"))
	textures["blunt"].append(preload("res://media/battle/vfx/hit/blunt_white.png"))
	textures["pierce"].append(preload("res://media/battle/vfx/hit/pierce_orange.png"))
	textures["pierce"].append(preload("res://media/battle/vfx/hit/pierce_yellow.png"))
	textures["pierce"].append(preload("res://media/battle/vfx/hit/blunt_white.png"))
	textures["slash"].append(preload("res://media/battle/vfx/hit/slash_orange.png"))
	textures["slash"].append(preload("res://media/battle/vfx/hit/slash_yellow.png"))
	textures["slash"].append(preload("res://media/battle/vfx/hit/slash_white.png"))
	textures["critical"].append(preload("res://media/battle/vfx/hit/critical_orange.png"))
	textures["critical"].append(preload("res://media/battle/vfx/hit/critical_yellow.png"))
	textures["critical"].append(preload("res://media/battle/vfx/hit/critical_white.png"))

func hit(attack_type: String) -> void:
	if attack_type == 'stab':
		texture = textures['pierce'].pick_random()
	else:
		var types: Array[String] = ['slash', 'blunt', 'critical']
		texture = textures[types.pick_random()].pick_random()
	show()
	# Fade out animation
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.finished.connect(
		func():
			hide()
			modulate.a = 1.0
	)
