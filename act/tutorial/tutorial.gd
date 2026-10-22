extends CanvasLayer

const Hand = preload("res://act/hud/hand/hand.gd")

## Act reference
var act: Act

## Scene Presentation Timer
var presentation_timer: Timer

## Dice Roller reference
var dice_roller: Control

## Actors reference
var actors: Node2D

## Juline reference
var juline: Actor

## Lucine reference
var lucine: Actor

## Hand Reference
var hand: Hand

## Current Tutorial Page Number
var current_page: int

## Current Tutorial Guided Step
var current_guided_step: Control

func _on_act_presentation_timeout() -> void:
	current_page = 1
	show_page(current_page)

func _on_page_mouse_pressed(page) -> void:
	if page.name == 'Page2':
		hide_page(current_page)
		$RollSpeed.show()
		current_guided_step = $RollSpeed
		act.dices_rolled.connect(
			guide_select_dice,
			Object.ConnectFlags.CONNECT_ONE_SHOT
		)
	elif page.name == 'Page6':
		hide_page(current_page)
		get_tree().paused = false
	else:
		go_to_next_page()

func init() -> void:
	presentation_timer.timeout.connect(
		_on_act_presentation_timeout,
		Object.ConnectFlags.CONNECT_ONE_SHOT
	)
	for i in 6:
		get_node(
			'Page' + str(i + 1)
		).page_mouse_pressed.connect(_on_page_mouse_pressed)

## Guide Select Dice
func guide_select_dice() -> void:
	guide_step($SelectDice)
	#dice_roller.dice_roller_pressed.disconnect(guide_select_dice)
	juline = actors.find_by_id(1)
	juline.get_speed_dices()[0].speed_dice_pressed.connect(
		guide_select_card,
		Object.ConnectFlags.CONNECT_ONE_SHOT
	)

## Guide Select Card
func guide_select_card(_juline_speed_dice_p) -> void:
	guide_step($SelectCard)
	#juline.get_speed_dices()[0].speed_dice_pressed.disconnect(guide_select_card)
	connect_hand_signals()
	hand.hand_shown.connect(connect_hand_signals)

## Connect Hand select card signals
func connect_hand_signals() -> void:
	for card in hand.get_children():
		card.card_pressed.connect(
			guide_select_enemy_dice,
			Object.ConnectFlags.CONNECT_ONE_SHOT
		)

## Guide Select Enemy Dice
func guide_select_enemy_dice(_juline_card_p) -> void:
	guide_step($SelectEnemyDice)
	lucine = actors.find_by_id(2)
	var speed_dice = lucine.get_speed_dices()[0]
	if not speed_dice.speed_dice_pressed.is_connected(guide_start_battle):
		speed_dice.speed_dice_pressed.connect(
			guide_start_battle,
			Object.ConnectFlags.CONNECT_ONE_SHOT
		)

## Guide Start Battle
func guide_start_battle(_lucine_speed_dice_p) -> void:
	hand.hand_shown.disconnect(connect_hand_signals)
	guide_step($StartBattle)
	act.dices_rolled.connect(
		return_to_pages,
		Object.ConnectFlags.CONNECT_ONE_SHOT
	)

## Return to tutorial remaining pages
func return_to_pages() -> void:
	current_guided_step.hide()
	go_to_next_page()
	#dice_roller.dice_roller_pressed.disconnect(return_to_pages)
	get_tree().paused = true

## Guide step
func guide_step(step: Control) -> void:
	current_guided_step.hide()
	step.show()
	current_guided_step = step

## Go to next Page
func go_to_next_page() -> void:
	hide_page(current_page)
	current_page += 1
	show_page(current_page)

## Hide Page
func hide_page(page_n: int) -> void:
	$Background.hide()
	get_node('Page' + str(page_n)).hide()

## Show Page
func show_page(page_n: int) -> void:
	$Background.show()
	get_node('Page' + str(page_n)).show()
