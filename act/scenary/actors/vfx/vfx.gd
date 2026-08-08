extends Node2D

## Parent Actor
var parent_actor: Actor

func init() -> void:
	$GuardedShock.init(parent_actor.code)

## Flip VFX horizontally
func flip_h_vfx(flip: bool) -> void:
	if flip:
		$AttackTrail.position = Vector2(-94, 0)
		$AttackTrail.flip_h = true
		$GuardedShock.position = Vector2(-50, 0)
		$GuardedShock.flip_h = true
	else:
		$AttackTrail.position = Vector2(94, 0)
		$AttackTrail.flip_h = false
		$GuardedShock.position = Vector2(50, 0)
		$GuardedShock.flip_h = false

## Show Attack Trail of animation
func show_attack_trail_of(animation: String) -> void:
	var texture: Texture2D = load(
		'res://media/actors/sprites/'
		+ parent_actor.code
		+ '/effects/' 
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

## Show Staggered VFX
func show_staggered_vfx() -> void:
	$Staggered.show_vfx()

## Show Max Damage VFX
func show_max_damage_vfx() -> void:
	$MaxDamage.show_vfx()
