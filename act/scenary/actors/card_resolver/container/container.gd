extends TextureRect

var original_position: Vector2

var name_original_position: Vector2

var dice_slot_original_position: Vector2

var dice_queue_original_position: Vector2

func _ready() -> void:
	original_position = position
	name_original_position = $Name.position
	dice_slot_original_position = $CurrentDice.position
	dice_queue_original_position = $DiceQueue.position

## Flip Container Horizontally
func flip_h_container(flip: bool) -> void:
	$DiceQueue.flip_h_queue(flip)
	if flip:
		position = original_position + Vector2(abs(original_position.x) + 50, 0)
		rotation_degrees = -5.0
		$Name.position = Vector2(96, name_original_position.y)
		$Name.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
		$CurrentDice.position = Vector2(21, dice_slot_original_position.y)
		$DiceQueue.position = Vector2(81, dice_queue_original_position.y)
		$DiceQueue.alignment = BoxContainer.AlignmentMode.ALIGNMENT_BEGIN
	else:
		position = original_position
		rotation_degrees = 5.0
		$Name.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT
		$Name.position = name_original_position
		$CurrentDice.position = dice_slot_original_position
		$DiceQueue.position = dice_queue_original_position
		$DiceQueue.alignment = BoxContainer.AlignmentMode.ALIGNMENT_END
