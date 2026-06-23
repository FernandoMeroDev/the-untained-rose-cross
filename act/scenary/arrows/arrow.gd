extends Node2D

## The Arrow start position
var start_position: Vector2

## The Arrow end position.
## Types: Vector2 | 'mouse_global_position'
var end_position: Variant

## Set follow the mouse cursor
var follow_mouse: bool = false

## The style can be:
## @var 'solid' | 'dotted'
var style: String = 'solid'

# The Arrow Color
var color: Color = Color.BLACK

## Quadratic Bezier Curve Perp
var perp: Vector2

## Quadratic Bezier Curve Control
var control: Vector2

## Quadratic Bezier Curve Orientation
var orientation: String

func _ready() -> void:
	z_index = 3

func _process(_delta: float) -> void:
	queue_redraw()

## Draw Arrow.
## @var p_end_position: Vector2 | 'mouse_global_position'
func draw_arrow(
	p_start_position: Vector2, 
	p_end_position: Variant, 
	p_style_input: String = 'solid',
	p_color: Color = Color.BLACK
) -> void:
	color = p_color
	start_position = p_start_position
	if str(p_end_position) == 'mouse_global_position':
		follow_mouse = true
	else:
		end_position = p_end_position
	style = p_style_input
	set_process(true)
	show()

func _draw():
	# Config
	var line_width: int = 4
	var arc_height: int = 100 * 3
	if follow_mouse:
		end_position = get_global_mouse_position()
	# Positions
	orientation = 'right' if (start_position.x - end_position.x) < 0 else 'left'
	var middle: Vector2 = (start_position + end_position) / 2
	var direction: Vector2 = (start_position - end_position).normalized()
	perp = Vector2(-direction.y, direction.x)
	## Beizer Curve
	control = middle + perp * arc_height  if orientation == 'right' else middle - perp * arc_height
	var prev: Vector2 = start_position
	var steps: int = 32  # More steps, the curve is more smooth
	for i in range(1, steps + 1):
		var t: float = float(i) / steps
		var p: Vector2 = _quadratic_bezier(start_position, control, end_position, t)
		if style == 'dotted':
			if i % 2 != 1:
				draw_line(prev, p, color, line_width)
		else:
			draw_line(prev, p, color, line_width)
		prev = p
	## Arrow Tip
	arrow_tip()

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0: Vector2 = p0.lerp(p1, t)
	var q1: Vector2 = p1.lerp(p2, t)
	var r: Vector2 = q0.lerp(q1, t)
	return r

func arrow_tip(options: Dictionary = { "change_side": false }):
	var pos_a: Vector2 = start_position
	var pos_b: Vector2 = end_position
	if options['change_side']:
		pos_b = start_position
		pos_a = end_position
	var arrow_size: int = 14	
	var tip_dir = (
		_quadratic_bezier(pos_a, control, pos_b, 1.0) 
		- _quadratic_bezier(pos_a, control, pos_b, 0.98)
	).normalized()
	var arrow_top: Vector2  = pos_b - (tip_dir * arrow_size) + (perp * arrow_size)
	var arrow_bottom: Vector2 = pos_b - (tip_dir * arrow_size) - (perp * arrow_size)
	if orientation == 'right':
		arrow_bottom -= (tip_dir * 15)
	elif orientation == 'left':
		arrow_top -= (tip_dir * 15)
	draw_polygon(
		PackedVector2Array([pos_b, arrow_top, arrow_bottom]), 
		PackedColorArray([color, color, color])
	)
