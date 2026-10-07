extends Control

var team: String

var resource: CardResource

## Load Card Resource
func load_card_resource(card_resource: CardResource) -> void:
	$Front/Name.text = card_resource.name
	var image: Texture2D = load('res://media/act/cards/' + card_resource.code + '.png')
	$Front/Art.texture = image
	$Front/Light/Number.text = str(card_resource.cost)
	init_dices(card_resource.dices)
	init_back(card_resource)
	resource = card_resource

## Unload Card Resource
func unload_card_resource() -> void:
	var dices: Array = get_children().filter(
		func (node):
			return node.name != 'Front' and node.name != 'Back'
	)
	if dices.size() > 0:
		for dice in dices:
			remove_child(dice)
		for dice in $Back/Dices.get_children():
			$Back/Dices.remove_child(dice)

func init_dices(dices: Array[DiceResource]) -> void:
	var count: int = dices.size()
	var i: int = 0;
	for dice_resource in dices:
		var dice: TextureRect = TextureRect.new()
		dice.texture = load(
			'res://media/act/icons/dice_types/' + dice_resource.get_type_code() + '.png'
		)
		# Positionate
		var dice_scale: Vector2 = Vector2(0.6, 0.6)
		dice.scale = dice_scale
		dice.position = Vector2(0, 0)
		var centerx: float = size.x / 4
		var dice_width: float = dice.size.x * dice_scale.x
		var gap: int = 3
		var total_width: float = (dice_width + gap) * count
		var startx: float = centerx - (total_width / 2)
		dice.position.x = startx + ((dice_width + gap) * i)
		dice.position.y = size.y - (dice.size.y * dice_scale.y)
		add_child(dice)
		dice.add_to_group(team + '_card_dices')
		i += 1

func init_back(card_resource: CardResource) -> void:
	var dice_scene = preload('res://act/hud/hand/card/back/dice.tscn')
	for dice_resource in card_resource.dices:
		var dice: HBoxContainer = dice_scene.instantiate()
		var icon: TextureRect = dice.get_node('Icon')
		icon.texture = load(
			'res://media/act/icons/dice_types/' + dice_resource.get_type_code() + '.png'
		)
		var detail: Label = dice.get_node('Detail')
		detail.text = (
			str(int(dice_resource.min_value)) + ' - ' 
			+ str(int(dice_resource.max_value))
		)
		$Back/Dices.add_child(dice)
