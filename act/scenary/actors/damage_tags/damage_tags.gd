extends Control

const NormalDamageScene: PackedScene = preload('res://act/scenary/actors/damage_tags/normal_damage.tscn')
const StaggerDamageScene: PackedScene = preload('res://act/scenary/actors/damage_tags/stagger_damage.tscn')
const DamageTag = preload('res://act/scenary/actors/damage_tags/damage_tag.gd')

## Damage Tags Original Position
var original_position: Vector2

## Actor resistences values reference
var resistences_values: Dictionary

## Resistences Icons
var resistences_icons: Dictionary[String, Texture] = {}

## Resistences Colors
var resistences_colors: Dictionary = {
	"damage": {
		"fatal": { "font": Color("b1ddeb"), "outline": Color("b1ddeb") },
		"weak": { "font": Color("86a8ee"), "outline": Color("1c3671") },
		"normal": { "font": Color("557dd9"), "outline": Color("000000")},
		"endured": { "font": Color("385a8a"), "outline": Color("000000")},
		"ineffective": { "font": Color("112E45"), "outline": Color("000000")},
	},
	"resist": {
		"fatal": { "font": Color("D4DFE0"), "outline": Color("fff") },
		"weak": { "font": Color("376E8C"), "outline": Color("fff") },
		"normal": { "font": Color("000"), "outline": Color("fff")},
		"endured": { "font": Color("28405d"), "outline": Color("000000")},
		"ineffective": { "font": Color("112E45"), "outline": Color("000000")},
	}
}

func _on_fade_animation_finished(tag: DamageTag) -> void:
	remove_child(tag)

func _ready() -> void:
	original_position = position
	# Slash
	resistences_icons['fatal_slash_damage'] = preload('res://media/act/icons/resistences/fatal_slash_damage.png')
	resistences_icons['fatal_slash_resist'] = preload('res://media/act/icons/resistences/fatal_slash_resist.png')
	resistences_icons['weak_slash_damage'] = preload('res://media/act/icons/resistences/weak_slash_damage.png')
	resistences_icons['weak_slash_resist'] = preload('res://media/act/icons/resistences/weak_slash_resist.png')
	resistences_icons['normal_slash_damage'] = preload('res://media/act/icons/resistences/normal_slash_damage.png')
	resistences_icons['normal_slash_resist'] = preload('res://media/act/icons/resistences/normal_slash_resist.png')
	resistences_icons['endured_slash_damage'] = preload('res://media/act/icons/resistences/endured_slash_damage.png')
	resistences_icons['endured_slash_resist'] = preload('res://media/act/icons/resistences/endured_slash_resist.png')
	resistences_icons['ineffective_slash_damage'] = preload('res://media/act/icons/resistences/ineffective_slash_damage.png')
	resistences_icons['ineffective_slash_resist'] = preload('res://media/act/icons/resistences/ineffective_slash_resist.png')
	# Pierce
	resistences_icons['fatal_pierce_damage'] = preload('res://media/act/icons/resistences/fatal_pierce_damage.png')
	resistences_icons['fatal_pierce_resist'] = preload('res://media/act/icons/resistences/fatal_pierce_resist.png')
	resistences_icons['weak_pierce_damage'] = preload('res://media/act/icons/resistences/weak_pierce_damage.png')
	resistences_icons['weak_pierce_resist'] = preload('res://media/act/icons/resistences/weak_pierce_resist.png')
	resistences_icons['normal_pierce_damage'] = preload('res://media/act/icons/resistences/normal_pierce_damage.png')
	resistences_icons['normal_pierce_resist'] = preload('res://media/act/icons/resistences/normal_pierce_resist.png')
	resistences_icons['endured_pierce_damage'] = preload('res://media/act/icons/resistences/endured_pierce_damage.png')
	resistences_icons['endured_pierce_resist'] = preload('res://media/act/icons/resistences/endured_pierce_resist.png')
	resistences_icons['ineffective_pierce_damage'] = preload('res://media/act/icons/resistences/ineffective_pierce_damage.png')
	resistences_icons['ineffective_pierce_resist'] = preload('res://media/act/icons/resistences/ineffective_pierce_resist.png')
	# Blunt
	resistences_icons['fatal_blunt_damage'] = preload('res://media/act/icons/resistences/fatal_blunt_damage.png')
	resistences_icons['fatal_blunt_resist'] = preload('res://media/act/icons/resistences/fatal_blunt_resist.png')
	resistences_icons['weak_blunt_damage'] = preload('res://media/act/icons/resistences/weak_blunt_damage.png')
	resistences_icons['weak_blunt_resist'] = preload('res://media/act/icons/resistences/weak_blunt_resist.png')
	resistences_icons['normal_blunt_damage'] = preload('res://media/act/icons/resistences/normal_blunt_damage.png')
	resistences_icons['normal_blunt_resist'] = preload('res://media/act/icons/resistences/normal_blunt_resist.png')
	resistences_icons['endured_blunt_damage'] = preload('res://media/act/icons/resistences/endured_blunt_damage.png')
	resistences_icons['endured_blunt_resist'] = preload('res://media/act/icons/resistences/endured_blunt_resist.png')
	resistences_icons['ineffective_blunt_damage'] = preload('res://media/act/icons/resistences/ineffective_blunt_damage.png')
	resistences_icons['ineffective_blunt_resist'] = preload('res://media/act/icons/resistences/ineffective_blunt_resist.png')

## Show Damage Tag
func show_damage(category: String, value: int, damage_type: String) -> void:
	var i: int = get_child_count()
	var damage_tag: DamageTag
	var resistence: String
	var icon: Texture
	var colors: Dictionary
	damage_tag = NormalDamageScene.instantiate() if(
		category == 'normal'
	) else StaggerDamageScene.instantiate()
	category = 'damage' if category == 'normal' else 'resist'
	resistence = resistences_values[damage_type + '_' + category]
	colors = resistences_colors[category][resistence]
	icon = resistences_icons[resistence + '_' + damage_type + '_' + category]
	add_child(damage_tag)
	damage_tag.init(
		value, 
		'ACT_ACTOR_DAMAGE_TAG_' + resistence.to_upper(), 
		icon, colors
	)
	damage_tag.position = Vector2(
		calc_random_offset(-150),
		calc_random_offset(-80 * i)
	)
	damage_tag.fade_animation_finished.connect(_on_fade_animation_finished)

## Show Defelct Damage Tag
func show_deflect_damage(value: int) -> void:
	var i: int = get_child_count()
	var damage_tag: DamageTag = StaggerDamageScene.instantiate()
	var icon: Texture = resistences_icons['normal_slash_resist']
	var colors = resistences_colors['resist']['normal']
	add_child(damage_tag)
	damage_tag.init(
		value, tr('ACT_ACTOR_DAMAGE_TAG_DEFLECT'), icon, colors
	)
	damage_tag.position = Vector2(
		calc_random_offset(-150),
		calc_random_offset(-80 * i)
	)
	damage_tag.fade_animation_finished.connect(_on_fade_animation_finished)

## Calc slight initial tag position variation
func calc_random_offset(offset: int, variation: int = 20) -> int:
	return randi_range(offset - variation, offset + variation)

## Flip Horizontally
func flip_h_tags(flip: bool) -> void:
	if flip:
		position.x = original_position.x + 200
	else:
		position.x = 0
