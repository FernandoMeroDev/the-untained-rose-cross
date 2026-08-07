extends Control

func take_damage(normal_damage: int, stagger_damage: int) -> void:
	$Health.take_damage(normal_damage)
	$Resist.take_damage(stagger_damage)

func take_stagger_damage(stagger_damage: int) -> void:
	$Resist.take_damage(stagger_damage)
