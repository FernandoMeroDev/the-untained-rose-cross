extends Arrow

const Arrow = preload('res://act/hud/hand/arrows/arrow/arrow.gd')

func _draw():
	super()
	arrow_tip({ "change_side": true })
