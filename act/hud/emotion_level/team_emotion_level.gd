extends TextureRect

## Side or team
var side: TurnManager.Teams

## Actors references
var actors: Array[Actor]

func _on_actor_emotionalized() -> void:
	# Calc Average emotion level
	var total: int = 0
	for actor: Actor in actors:
		if actor.alive:
			total += actor.emotion_level
	var average: float = float(total) / float(alive_actors_count())
	var current_level: int = int(average)
	var start_point: int
	var gap: int
	match side:
		TurnManager.Teams.LEFT:
			start_point = calc_left_start_point(current_level)
			gap = calc_percentaje_point(average - float(current_level))
		TurnManager.Teams.RIGHT:
			start_point = calc_right_start_point(current_level)
			gap = - calc_percentaje_point(average - float(current_level))
	var position_x: int = start_point + gap
	$Indicator.animate_movement(position_x)

## Get Right Team's start point for indicator's X position
func calc_right_start_point(current_level: int) -> int:
	var start_point: int = 0
	match current_level:
		0: start_point = 757
		1: start_point = 757 - 117 - 32
		2: start_point = 757 - ((117 + 32) * 2)
		3: start_point = 757 - ((117 + 32) * 3)
		4: start_point = 757 - ((117 + 32) * 4)
		5: start_point = 757 - ((117 + 32) * 4) - 117
	return start_point

## Get Left Team's start point for indicator's X position
func calc_left_start_point(current_level: int) -> int:
	var start_point: int = 0
	match current_level:
		0: start_point = 42
		1: start_point = 42 + 117 + 32
		2: start_point = 42 + ((117 + 32) * 2)
		3: start_point = 42 + ((117 + 32) * 3)
		4: start_point = 42 + ((117 + 32) * 4)
		5: start_point = 42 + ((117 + 32) * 4) + 117
	return start_point

## Calc position X in function of current Level percentaje
func calc_percentaje_point(percentaje: float) -> int:
	var gap: float = percentaje * 117
	return int(gap)

## Count Alive Actors
func alive_actors_count() -> int:
	var count: int = 0
	for actor: Actor in actors:
		if actor.alive: count += 1
	return count
