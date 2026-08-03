extends Node2D

func flip_h_vfx(flip: bool) -> void:
	if flip:
		$AttackTrail.position = Vector2(-94, 0)
		$AttackTrail.flip_h = true
	else:
		$AttackTrail.position = Vector2(94, 0)
		$AttackTrail.flip_h = false

func show_attack_trail_of(animation: String) -> void:
	var texture: Texture2D = load(
		'res://media/actors/sprites/lucine/effects/' 
		+ animation + '_trail.png'
	)
	$AttackTrail.texture = texture
	$AttackTrail.show()
	# Fade out animation
	var tween: Tween = create_tween()
	tween.tween_property($AttackTrail, "modulate:a", 0.0, 0.5)
	tween.finished.connect(
		func():
			$AttackTrail.hide()
			$AttackTrail.modulate.a = 1.0
	)
