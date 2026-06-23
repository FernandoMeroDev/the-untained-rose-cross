extends Arrow

const Arrow = preload('res://act/scenary/arrows/arrow.gd')

func _draw():
	super()
	# Draw the other tip of the double arrow
	arrow_tip({ "change_side": true })

## Draw Clash Arrow
func draw_clash_arrow(
	speed_dice: SpeedDice, 
	enemy_dice_targeting: SpeedDice
) -> void:
	start_position = speed_dice.get_global_rect().get_center()
	end_position = enemy_dice_targeting.get_global_rect().get_center()
	color = Color.RED
	style = 'solid'
	set_process(true)
	show()
