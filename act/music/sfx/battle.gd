extends Node

## Plays attack battle SFX
func play_attack(sharp: bool, sound_name: String) -> void:
	var attack: String = 'sword_' if sharp else 'blow_'
	attack = attack + sound_name
	get_node('Attack/' + attack.to_pascal_case()).play()

## Plays Evade battle SFX
func play_evade(attack_animation_name: String) -> void:
	get_node('Evade/' + attack_animation_name.capitalize()).play()

## Plays parry battle SFX
func play_parry() -> void:
	$Attack/Parry.play()

## Plays block battle SFX
func play_block(win: bool = false) -> void:
	if win:
		$Block/GuardedWin.play()
	else:
		$Block/Guarded.play()

## Plays DaeChi
func play_daechi() -> void:
	$Block/DaeChi.play()
