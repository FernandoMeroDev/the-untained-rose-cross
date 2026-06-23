extends Node2D

const pointer_arrow_scene: PackedScene = preload('res://act/hud/hand/arrows/arrow/pointer.tscn')

const oneside_arrow_scene: PackedScene = preload('res://act/hud/hand/arrows/events/oneside.tscn')

const clash_arrow_scene: PackedScene = preload('res://act/hud/hand/arrows/events/clash.tscn')

var pointer_arrow: Node2D = null

var dependencies = {}

func init(p_dependencies):
	dependencies = p_dependencies

func handle_dice_mouse_entered(dice):
	# Mostrar las flechas de targets
	if dice.targeting:
		if dice.targeted_by.size() > 0:
			var has_clash: bool = false
			for enemy_dice in dice.targeted_by:
				if enemy_dice.id == dice.targeting.id:
					# Mostrar clash
					create_clash(enemy_dice, dice)
					has_clash = true
				else:
					create_one_side_attack(enemy_dice, dice)
			if not has_clash:
				create_one_side_attack(dice, dice.targeting)
		else:
			# Esta haciendo targeting y no esta siendo targeteado
			create_one_side_attack(dice, dice.targeting)
	else:
		if dice.targeted_by.size() > 0:
			for enemy_dice in dice.targeted_by:
				create_one_side_attack(enemy_dice, dice)

func create_clash(dice_a, dice_b):
	var arrow = clash_arrow_scene.instantiate()
	$EventArrows.add_child(arrow);
	arrow.create(
		dice_a.get_global_rect().get_center(), 
		dice_b.get_global_rect().get_center(), 
		'solid',
		Color.RED
	)
	arrow.add_to_group('event_arrows_for_' + str(dice_a.id))
	arrow.add_to_group('event_arrows_for_' + str(dice_b.id))

func remove_event_arrows():
	var focused_dice = dependencies['hand'].focused_dice
	for event_arrow in $EventArrows.get_children():
		if focused_dice:
			if event_arrow.is_in_group('event_arrows_for_' + str(focused_dice.id)):
				continue
		$EventArrows.remove_child(event_arrow)

func create_one_side_attack(dice_from, dice_to):
	var arrow = oneside_arrow_scene.instantiate()
	arrow.add_to_group('event_arrows_for_' + str(dice_from.id))
	arrow.add_to_group('event_arrows_for_' + str(dice_to.id))
	$EventArrows.add_child(arrow);
	arrow.create(
		dice_from.get_global_rect().get_center(), 
		dice_to.get_global_rect().get_center(), 
		'solid'
	)

func handle_dice_mouse_exited(_dice):
	remove_event_arrows()

func _on_hand_card_focused(dice: Variant) -> void:
	# Instanciate the arrow and set the start position
	var arrow = pointer_arrow_scene.instantiate()
	add_child(arrow)
	var start_pos = dice.get_global_rect().get_center()
	var end_pos = 'mouse_global_position'
	arrow.create(start_pos, end_pos, 'dotted')
	pointer_arrow = arrow


func _on_hand_card_unfocused() -> void:
	remove_child(pointer_arrow)
	pointer_arrow = null
