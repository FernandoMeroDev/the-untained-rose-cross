extends Node2D

const ArrowPointerScene: PackedScene = preload('res://act/scenary/arrows/arrow_pointer.tscn')
const OnesideAttackArrowScene: PackedScene = preload('res://act/scenary/arrows/onseside_attack.tscn')
const ClashArrowScene: PackedScene = preload('res://act/scenary/arrows/clash.tscn')
const Arrow = preload('res://act/scenary/arrows/arrow.gd')
const ArrowPointer = preload('res://act/scenary/arrows/arrow_pointer.gd')
const OnesideAttackArrow = preload('res://act/scenary/arrows/onseside_attack.gd')
const ClashArrow = preload('res://act/scenary/arrows/clash.gd')
const Card = preload('res://act/hud/hand/card/card.gd')
const DetailsPanel = preload('res://act/hud/actor_details/panels/panel.gd')

## Left Actor Details Panel
var left_panel: DetailsPanel

## Right Actor Details Panel
var right_panel: DetailsPanel

## Arrow used to target enemies
var arrow_pointer: ArrowPointer

# --- Hand Events Observers
func _on_enemy_speed_dice_targeted(
	speed_dice: SpeedDice,
	enemy_speed_dice: SpeedDice,
	card_resource: CardResource
) -> void:
	handle_enemy_speed_dice_targeted(
		speed_dice, enemy_speed_dice, card_resource
	)

func _on_card_selected(card: Card, speed_dice: SpeedDice) -> void:
	handle_card_selected(card, speed_dice)

func _on_card_deselected(card: Card) -> void:
	handle_card_deselected(card)

# --- Speed Dice Events Observers
func _on_speed_dice_right_click_pressed(speed_dice: SpeedDice) -> void:
	handle_speed_dice_right_click_pressed(speed_dice)

func _on_speed_dice_mouse_entered(speed_dice: SpeedDice) -> void:
	handle_speed_dice_mouse_entered(speed_dice)

func _on_speed_dice_mouse_exited(speed_dice: SpeedDice) -> void:
	handle_speed_dice_mouse_exited(speed_dice)

# --- Panels (Left, Right) Events Observers
func _on_left_panel_speed_dice_focused_changed(speed_dice: SpeedDice) -> void:
	handle_left_panel_speed_dice_focused_changed(speed_dice)

func _on_right_panel_speed_dice_focused_changed(speed_dice: SpeedDice) -> void:
	handle_right_panel_speed_dice_focused_changed(speed_dice)

# --- Right Click Event Handlers
func handle_right_click_pressed() -> void:
	if get_children().size() > 0:
		for arrow: Arrow in get_children():
			# Prevents Remove arrows of current hovered dice
			if left_panel.speed_dice_hovered:
				if arrow.is_in_group(
					build_hovered_dice_group_name('left')
				): continue
			if right_panel.speed_dice_hovered:
				if arrow.is_in_group(
					build_hovered_dice_group_name('right')
				): continue
			remove_child(arrow)

# --- Hand Events Handlers
func handle_enemy_speed_dice_targeted(
	speed_dice: SpeedDice,
	enemy_speed_dice: SpeedDice,
	_card_resource: CardResource
) -> void:
	# Refresh Arrows of Speed Dices
	refresh_speed_dice_arrows(speed_dice)
	refresh_speed_dice_arrows(enemy_speed_dice)

func handle_card_selected(_card: Card, speed_dice: SpeedDice) -> void:
	var arrow: ArrowPointer = ArrowPointerScene.instantiate()
	add_child(arrow)
	arrow.draw_arrow(
		speed_dice.get_global_rect().get_center(), 
		'mouse_global_position', 
		'dotted'
	)
	arrow_pointer = arrow

func handle_card_deselected(_card: Card) -> void:
	if get_children().has(arrow_pointer):
		remove_child(arrow_pointer)
		arrow_pointer = null

# --- Speed Dice Events Handlers
func handle_speed_dice_right_click_pressed(speed_dice: SpeedDice) -> void:
	refresh_speed_dice_arrows(speed_dice)

func handle_speed_dice_mouse_entered(speed_dice: SpeedDice) -> void:
	draw_speed_dice_arrows(speed_dice)

func handle_speed_dice_mouse_exited(_speed_dice: SpeedDice) -> void:
	for arrow: Arrow in get_children():
		# Prevents Remove arrow pointer
		if arrow_pointer:
			if arrow_pointer == arrow: continue
		# Prevents Remove arrows of Focused Dices
		if left_panel.speed_dice_focused:
			if arrow.is_in_group(build_focused_dice_group_name('left')): continue
		if right_panel.speed_dice_focused:
			if arrow.is_in_group(build_focused_dice_group_name('right')): continue
		remove_child(arrow)

# --- Panels (Left, Right) Events Observers
func handle_left_panel_speed_dice_focused_changed(speed_dice: SpeedDice) -> void:
	for arrow: Arrow in get_children():
		# Remove arrows of speed dice focused
		if arrow.is_in_group(
			build_focused_dice_group_name('left')
		): remove_child(arrow)
	handle_speed_dice_mouse_entered(speed_dice)

func handle_right_panel_speed_dice_focused_changed(speed_dice: SpeedDice) -> void:
	for arrow: Arrow in get_children():
		# Remove arrows of speed dice focused
		if arrow.is_in_group(
			build_focused_dice_group_name('right')
		): remove_child(arrow)
	handle_speed_dice_mouse_entered(speed_dice)

## Refresh Speed Dice Arrows
func refresh_speed_dice_arrows(speed_dice: SpeedDice) -> void:
	clear_speed_dice_arrows(speed_dice)
	draw_speed_dice_arrows(speed_dice)

## Draw Speed Dice Arrows
func draw_speed_dice_arrows(speed_dice: SpeedDice) -> void:
	if speed_dice.enemy_dice_targeting:
		if speed_dice.targeted_by_enemies.size() > 0:
			var has_clash: bool = false
			for enemy_speed_dice: SpeedDice in speed_dice.targeted_by_enemies:
				if enemy_speed_dice.id == speed_dice.enemy_dice_targeting.id:
					create_clash(speed_dice, enemy_speed_dice)
					has_clash = true
				else:
					create_oneside_attack(enemy_speed_dice, speed_dice)
			if not has_clash:
				create_oneside_attack(
					speed_dice,
					speed_dice.enemy_dice_targeting
				)
		else:
			# Speed Dice is targeting but isn't being targeted
			create_oneside_attack(
				speed_dice,
				speed_dice.enemy_dice_targeting
			)
	else:
		if speed_dice.targeted_by_enemies.size() > 0:
			for enemy_speed_dice: SpeedDice in speed_dice.targeted_by_enemies:
				create_oneside_attack(enemy_speed_dice, speed_dice)

## Clear Arrows
func clear_speed_dice_arrows(speed_dice: SpeedDice) -> void:
	for arrow: Arrow in get_children():
		# Remove arrows of speed dice
		if arrow.is_in_group(
			'event_arrows_for_' + str(speed_dice.id)
		): remove_child(arrow)

## Build group name for speed dice focused in a panel
func build_focused_dice_group_name(side: String) -> String:
	return 'event_arrows_for_' + str(
		get(side + '_panel').speed_dice_focused.id
	)

## Build group name for speed dice hovered in a panel
func build_hovered_dice_group_name(side: String) -> String:
	return 'event_arrows_for_' + str(
		get(side + '_panel').speed_dice_hovered.id
	)

## Create Oneside Attack Arrow
func create_oneside_attack(
	speed_dice: SpeedDice, enemy_speed_dice: SpeedDice
) -> void:
	var arrow: OnesideAttackArrow = OnesideAttackArrowScene.instantiate()
	arrow.draw_oneside_attack_arrow(speed_dice, enemy_speed_dice)
	arrow.add_to_group('event_arrows_for_' + str(speed_dice.id))
	arrow.add_to_group('event_arrows_for_' + str(enemy_speed_dice.id))
	add_child(arrow)

## Create Clash Arrow
func create_clash(
	speed_dice: SpeedDice, enemy_speed_dice: SpeedDice
) -> void:
	var arrow: ClashArrow = ClashArrowScene.instantiate()
	arrow.draw_clash_arrow(speed_dice, enemy_speed_dice)
	arrow.add_to_group('event_arrows_for_' + str(speed_dice.id))
	arrow.add_to_group('event_arrows_for_' + str(enemy_speed_dice.id))
	add_child(arrow)
