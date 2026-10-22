extends StatusEffectResource

const StatusEffectResource = preload("res://database/resources/status_effects/status_effect.gd")

## Nullify physical damage
func alter_physical_damage(_damage: int) -> int:
	return 0
