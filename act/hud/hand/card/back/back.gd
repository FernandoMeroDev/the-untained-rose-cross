extends TextureRect

func init(card_resource: CardResource) -> void:
	var dice_scene = preload('res://act/hud/hand/card/back/dice.tscn')
	for dice_resource in card_resource.dices:
		var dice: HBoxContainer = dice_scene.instantiate()
		var icon: TextureRect = dice.get_node('Icon')
		icon.texture = load(
			'res://media/icons/dice_types/' + dice_resource.get_type_code() + '.png'
		)
		var detail: Label = dice.get_node('Detail')
		detail.text = (
			str(int(dice_resource.min_value)) + ' - ' 
			+ str(int(dice_resource.max_value))
		)
		$Dices.add_child(dice)

func focus(new_x_offset: float) -> void:
	var tween: Tween = create_tween()
	tween.parallel().tween_property(
		self, "position", 
		Vector2(new_x_offset, 0), 
		0.15
	)

func unfocus() -> void:
	var tween: Tween = create_tween()
	tween.parallel().tween_property(self, "position", Vector2(0, 0), 0.15)
