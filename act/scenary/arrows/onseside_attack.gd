extends Arrow

const Arrow = preload('res://act/scenary/arrows/arrow.gd')

## Draw Oneside Attack Arrow
func draw_oneside_attack_arrow(
	speed_dice: SpeedDice, 
	enemy_dice_targeting: SpeedDice
) -> void:
	start_position = speed_dice.get_global_rect().get_center()
	end_position = enemy_dice_targeting.get_global_rect().get_center()
	color = Color.BLACK
	style = 'solid'
	set_process(true)
	show()
