extends Node

## Plays attack battle SFX
func play_attack(sharp: bool, sound_name: String) -> void:
	var attack: String = 'sword_' if sharp else 'blow_'
	attack = attack + sound_name
	get_node('Attack/' + attack.to_pascal_case()).play()

## Plays parry battle SFX
func play_parry() -> void:
	$Attack/Parry.play()
