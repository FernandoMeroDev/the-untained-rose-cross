extends RefCounted

const CardResolver = preload("res://act/scenary/actors/card_resolver/card_resolver.gd")
const BattleSFX = preload('res://act/music/sfx/battle.gd')
const Camera = preload("res://act/scenary/camera/camera.gd")

# Act Reference
var act: Act

## Camera reference
var camera: Camera

## Battle SFX reference
var battle_sfx: BattleSFX

func _init(
	p_act: Act,
	p_camera: Camera,
	p_battle_sfx: BattleSFX,
) -> void:
	act = p_act
	camera = p_camera
	battle_sfx = p_battle_sfx

## Resolve Clash
func resolve(
	card_resolver_a: CardResolver,
	card_resolver_b: CardResolver
) -> void:
	var actor_a: Actor = card_resolver_a.parent_actor
	var actor_b: Actor = card_resolver_b.parent_actor
	var a_value: int = card_resolver_a.get_dice_value()
	var b_value: int = card_resolver_b.get_dice_value()
	if a_value > b_value:
		await resolve_clash_win(actor_a, actor_b)
	elif a_value < b_value:
		await resolve_clash_win(actor_b, actor_a)
	else:
		await resolve_draw(actor_a, actor_b)

## Resolve draw
func resolve_draw(
	actor_a: Actor,
	actor_b: Actor
) -> void:
	var card_resolver_a: CardResolver = actor_a.get_card_resolver()
	var card_resolver_b: CardResolver = actor_b.get_card_resolver()
	var a_dice_resource: DiceResource = card_resolver_a.get_current_dice_resource()
	var b_dice_resource: DiceResource = card_resolver_b.get_current_dice_resource()
	if(
		a_dice_resource.is_offensive() 
		and b_dice_resource.is_offensive()
	):
		await parry(actor_a, actor_b)
	elif(
		a_dice_resource.is_offensive() 
		and b_dice_resource.is_defensive()
	):
		match b_dice_resource.type:
			DiceResource.Types.BLOCK:
				# B Block draw A Offensive
				await block_draw_offensive(actor_b, actor_a)
			DiceResource.Types.EVADE:
				# B Evade draw A Offensive
				await evade_draw_offensive(actor_b, actor_a)
	elif(
		a_dice_resource.is_defensive() 
		and b_dice_resource.is_offensive()
	):
		match a_dice_resource.type:
			DiceResource.Types.BLOCK:
				# A Block draw B Offensive
				await block_draw_offensive(actor_a, actor_b)
			DiceResource.Types.EVADE:
				# A Evaded draw B Offensive
				await evade_draw_offensive(actor_a, actor_b)
	elif(
		a_dice_resource.is_defensive() 
		and b_dice_resource.is_defensive()
	):
		match a_dice_resource.type:
			DiceResource.Types.EVADE:
				match b_dice_resource.type:
					DiceResource.Types.EVADE:
						await evade_draw_evade(actor_a, actor_b)
					DiceResource.Types.BLOCK:
						await block_draw_evade(actor_b, actor_a)
			DiceResource.Types.BLOCK:
				match b_dice_resource.type:
					DiceResource.Types.EVADE:
						await block_draw_evade(actor_a, actor_b)
					DiceResource.Types.BLOCK:
						await block_draw_block(actor_a, actor_b)

## Block draw Evade
func block_draw_evade(
	actor_a: Actor,
	actor_b: Actor,
) -> void:
	battle_sfx.play_evade('defense')
	actor_a.play_block_animation(false)
	actor_b.play_evade_animation(actor_a.global_position)
	await set_timeout()
	actor_a.get_card_resolver().discard_current_dice()
	actor_b.get_card_resolver().discard_current_dice()

## Block draw Block
func block_draw_block(
	actor_b: Actor,
	actor_a: Actor
) -> void:
	battle_sfx.play_block()
	actor_a.play_block_animation(false)
	actor_b.play_block_animation(false)
	await set_timeout()
	actor_a.get_card_resolver().discard_current_dice()
	actor_b.get_card_resolver().discard_current_dice()

## Evade draw Evade
func evade_draw_evade(
	actor_b: Actor,
	actor_a: Actor
) -> void:
	actor_a.play_evade_animation(actor_b.global_position)
	actor_b.play_evade_animation(actor_a.global_position)
	battle_sfx.play_evade('defense')
	await set_timeout()
	actor_a.get_card_resolver().discard_current_dice()
	actor_b.get_card_resolver().discard_current_dice()

## Evade draw Offensive
func evade_draw_offensive(
	actor_b: Actor,
	actor_a: Actor
) -> void:
	var b_value: int = actor_b.get_card_resolver().get_dice_value()
	var attack_animation: String = actor_a.play_attack_animation()
	battle_sfx.play_evade(attack_animation)
	actor_b.play_evade_animation(actor_a.global_position)
	actor_b.recover_resist(b_value)
	await set_timeout()
	actor_b.get_card_resolver().discard_current_dice()
	actor_a.get_card_resolver().discard_current_dice()

## Block draw Offensive
func block_draw_offensive(
	actor_b: Actor,
	actor_a: Actor
) -> void:
	battle_sfx.play_block()
	actor_b.play_block_animation(false)
	actor_a.play_attack_animation(false)
	await set_timeout()
	actor_a.get_card_resolver().discard_current_dice()
	actor_b.get_card_resolver().discard_current_dice()

## Handle Parry
func parry(
	actor_a: Actor,
	actor_b: Actor
) -> void:
	camera.shake()
	battle_sfx.play_parry()
	actor_a.play_parry_sparks(
		(actor_a.global_position + actor_b.global_position) / 2
	)
	actor_a.handle_parry()
	actor_b.handle_parry()
	await set_timeout(0.5)
	actor_b.get_card_resolver().discard_current_dice()
	actor_a.get_card_resolver().discard_current_dice()

## Resolve Clash Win
func resolve_clash_win(
	winner: Actor,
	loser: Actor
) -> void:
	var winner_card_resolver: CardResolver = winner.get_card_resolver()
	var winner_dice_resource: DiceResource = winner_card_resolver.get_current_dice_resource()
	var loser_card_resolver: CardResolver = loser.get_card_resolver()
	var loser_dice_resource: DiceResource = loser_card_resolver.get_current_dice_resource()
	# A wins B
	if winner_dice_resource.is_offensive():
		await handle_offensive_wins(winner, loser)
	elif winner_dice_resource.is_defensive():
		if loser_dice_resource.is_offensive():
			match winner_dice_resource.type:
				DiceResource.Types.BLOCK:
					await block_wins_offensive(winner, loser)
				DiceResource.Types.EVADE:
					await evade_wins_offensive(winner, loser)
		elif loser_dice_resource.is_defensive():
			match winner_dice_resource.type:
				DiceResource.Types.BLOCK:
					match loser_dice_resource.type:
						DiceResource.Types.BLOCK:
							# A Block wins B Block
							await block_wins_block(winner, loser)
						DiceResource.Types.EVADE:
							# A Block wins B Evade
							await block_wins_evade(winner, loser)
				DiceResource.Types.EVADE:
					match loser_dice_resource.type:
						DiceResource.Types.BLOCK:
							# A Evade wins B Block
							await evade_wins_block(winner, loser)
						DiceResource.Types.EVADE:
							# A Evade wins B Evade
							await evade_wins_evade(winner, loser)

## Evade wins Evade
func evade_wins_evade(
	actor_x: Actor,
	actor_y: Actor
) -> void:
	actor_x.play_block_animation(false)
	actor_y.play_block_animation(false)
	battle_sfx.play_daechi()
	await set_timeout(0.5)
	actor_y.get_card_resolver().discard_current_dice()
	actor_x.get_card_resolver().discard_current_dice()

## Evade wins Block
func evade_wins_block(
	actor_x: Actor,
	actor_y: Actor
) -> void:
	actor_y.play_block_animation(false)
	battle_sfx.play_evade('defense')
	actor_x.play_evade_animation(actor_y.global_position)
	await set_timeout(0.5)
	actor_y.get_card_resolver().discard_current_dice()
	actor_x.get_card_resolver().discard_current_dice()

## Block wins Evade. X wins Y
func block_wins_evade(
	actor_x: Actor,
	actor_y: Actor
) -> void:
	var card_resolver_x: CardResolver = actor_x.get_card_resolver()
	var card_resolver_y: CardResolver = actor_y.get_card_resolver()
	var x_value: int = card_resolver_x.get_dice_value()
	camera.shake()
	battle_sfx.play_daechi()
	actor_x.play_block_animation()
	actor_y.handle_deflected(
		x_value,
		actor_x.global_position
	)
	await set_timeout(0.5)
	card_resolver_y.discard_current_dice()
	card_resolver_x.discard_current_dice()

## Block wins Block. X wins Y
func block_wins_block(
	actor_x: Actor,
	actor_y: Actor
) -> void:
	var card_resolver_x: CardResolver = actor_x.get_card_resolver()
	var card_resolver_y: CardResolver = actor_y.get_card_resolver()
	var x_value: int = card_resolver_x.get_dice_value()
	camera.shake()
	battle_sfx.play_daechi()
	actor_x.play_block_animation()
	actor_y.handle_deflected(
		x_value,
		actor_x.global_position
	)
	await set_timeout(0.5)
	card_resolver_y.discard_current_dice()
	card_resolver_x.discard_current_dice()

## Evade wins Offensive. X wins Y
func evade_wins_offensive(
	actor_x: Actor,
	actor_y: Actor
) -> void:
	var card_resolver_x: CardResolver = actor_x.get_card_resolver()
	var card_resolver_y: CardResolver = actor_y.get_card_resolver()
	var x_value: int = card_resolver_x.get_dice_value()
	var attack_animation: String = actor_y.play_attack_animation()
	battle_sfx.play_evade(attack_animation)
	actor_x.play_evade_animation(actor_y.global_position)
	actor_x.recover_resist(x_value)
	await set_timeout(0.5)
	card_resolver_y.discard_current_dice()
	card_resolver_x.recycle_current_dice()

## Block wins Offensive. X wins Y
func block_wins_offensive(
	actor_x: Actor,
	actor_y: Actor
) -> void:
	var x_value: int = actor_x.get_card_resolver().get_dice_value()
	var y_value: int = actor_y.get_card_resolver().get_dice_value()
	camera.shake()
	battle_sfx.play_block(true)
	actor_x.play_block_animation()
	actor_y.handle_deflected(
		x_value - y_value,
		actor_x.global_position
	)
	await set_timeout(0.5)
	actor_y.get_card_resolver().discard_current_dice()
	actor_x.get_card_resolver().discard_current_dice()

## Offensive wins. X wins Y
func handle_offensive_wins(
	actor_x: Actor,
	actor_y: Actor
) -> void:
	var card_resolver_x: CardResolver = actor_x.get_card_resolver()
	var card_resolver_y: CardResolver = actor_y.get_card_resolver()
	var x_dice_resource: DiceResource = card_resolver_x.get_current_dice_resource()
	var y_dice_resource: DiceResource = card_resolver_y.get_current_dice_resource()
	var x_value: int = card_resolver_x.get_dice_value()
	var y_value: int = card_resolver_y.get_dice_value()
	camera.shake()
	var attack_animation: String = actor_x.play_attack_animation()
	battle_sfx.play_attack(actor_x.sharp_weapon, attack_animation)
	card_resolver_y.destroy_current_dice()
	# Block damage reduction
	if y_dice_resource.type == DiceResource.Types.BLOCK:
		x_value -= y_value
	await actor_y.handle_hit(
		x_value, 
		x_dice_resource.get_type_code(), 
		actor_x.global_position, 
		attack_animation,
		card_resolver_x.get_current_dice_max_value()
	)
	card_resolver_y.discard_current_dice()
	card_resolver_x.discard_current_dice()

## Await timeout
func set_timeout(time: float = 0.3):
	await act.get_tree().create_timer(time).timeout
