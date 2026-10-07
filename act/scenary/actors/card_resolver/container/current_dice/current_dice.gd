extends TextureRect

## Dice Resource
var dice_resource: DiceResource

## Dice Value
var value: int

## Set Dice
func set_dice(dice: DiceResource) -> void:
	dice_resource = dice
	$Value.hide()
	$Roulette.start()
	$Range.text = (
		str(dice.min_value) + '~' + str(dice.max_value)
	)
	$Range.show()
	$Icon.show()
	$Icon.texture = load(
		'res://media/act/icons/dice_types/' + dice.get_type_code() + '.png'
	)

## Play Dice
func play_dice() -> void:
	var result_value: int = randi_range(
		dice_resource.min_value,
		dice_resource.max_value,
	)
	$Roulette.stop()
	$Range.hide()
	$Icon.show()
	$Value.show()
	$Value.set_value(result_value)
	value = result_value

## Clear Current Dice
func clear_dice() -> void:
	$Icon.hide()
	$Value.hide()
	dice_resource = null

## Plays Fade Out animation
func fade_out_dice() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($Icon, "modulate:a", 0.0, 0.3)
	tween.tween_property($Range, "modulate:a", 0.0, 0.3)
	tween.tween_property($Roulette, "modulate:a", 0.0, 0.3)
	tween.finished.connect(
		func():
			$Icon.modulate.a = 1.0
			$Range.modulate.a = 1.0
			$Roulette.modulate.a = 0.7
	)

## Destroy Dice
func destroy_dice() -> void:
	$Icon.hide()
	$Destroyed.show()
	# Grow and fadeout animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		$Destroyed,
		 "scale", Vector2.ONE * 0.75, 0.5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		$Destroyed, "modulate:a", 0.0, 1.0
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.finished.connect(reset_destroyed_dice)

## Reset destroyed dice animation
func reset_destroyed_dice() -> void:
	$Destroyed.hide()
	$Destroyed.scale = Vector2(0.5, 0.5)
	$Destroyed.modulate = Color(1, 1, 1, 1)

## Recycle Dice
func recycle_dice() -> void:
	set_dice(dice_resource)
