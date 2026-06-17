extends Button


signal selected(card)

signal card_mouse_entered(card)

var resource: CardResource

## Is this card currently being focused?
var focused: bool = false

var original: Dictionary = {
	'scale': null,
	'position': null,
	'z_index': null
}

func init(card_resource: CardResource) -> void:
	$Front/Name.text = card_resource.name
	var image: Texture2D = load('res://media/cards/' + card_resource.code + '.png')
	$Front/Art.texture = image
	init_dices(card_resource.dices)
	$Back.init(card_resource)
	resource = card_resource

func init_dices(dices: Array[DiceResource]) -> void:
	var count: int = dices.size()
	var i: int = 0;
	for dice_resource in dices:
		var dice: TextureRect = TextureRect.new()
		dice.texture = load(
			'res://media/icons/dice_types/' + dice_resource.get_type_code() + '.png'
		)
		# Positionate
		var dice_scale: Vector2 = Vector2(0.3, 0.3)
		dice.scale = dice_scale
		dice.position = Vector2(0, 0)
		var centerx: float = size.x / 2
		var dice_width: float = dice.size.x * dice_scale.x
		var gap: int = 3
		var total_width: float = (dice_width + gap) * count
		var startx: float = centerx - (total_width / 2)
		dice.position.x = startx + ((dice_width + gap) * i)
		dice.position.y = size.y - (dice.size.y * dice_scale.y)
		add_child(dice)
		i += 1

func _on_mouse_entered() -> void:
	card_mouse_entered.emit(self)

func _on_mouse_exited() -> void:
	if not focused:
		unfocus()

func focus() -> void:
	var new_scale: Vector2 = Vector2(1.2, 1.2)
	var new_y_offset: int = -40
	var new_z_index: int = 2
	var tween: Tween = create_tween()
	backup_original('scale')
	tween.parallel().tween_property(
		self, "scale", new_scale, 0.15
	).set_trans(Tween.TRANS_QUAD)
	backup_original('position')
	var new_x_offset: float = (size.x / 2) * new_scale.x
	tween.parallel().tween_property(
		self, "position", 
		original['position'] 
			+ Vector2(
				- new_x_offset,
				new_y_offset
			), 
		0.15
	)
	backup_original('z_index')
	z_index = new_z_index
	$Back.focus(size.x)

func backup_original(property: String) -> void:
	if original[property] == null:
		original[property] = self[property]


func unfocus() -> void:
	var tween: Tween = create_tween()
	backup_original('scale')
	tween.parallel().tween_property(
		self, "scale", original['scale'], 0.15
	).set_trans(Tween.TRANS_QUAD)
	backup_original('position')
	tween.parallel().tween_property(
		self, "position", original['position'], 0.15
	)
	backup_original('z_index')
	z_index = original['z_index']
	$Back.unfocus()

func _on_button_down() -> void:
	selected.emit(self)
