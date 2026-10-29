# class TutorialFinalizer
extends Finalizer

const Finalizer = preload("res://database/acts/default_finalizer.gd")

## Lucine Reference
var lucine: Actor

## Lucine give up if her hp drops bellow this percentaje
var lucine_hp_limit: float = 0.5

## Is act finalized?
func is_act_finalized() -> bool:
	var juline: Actor = actors.find_by_id(1)
	lucine = actors.find_by_id(2)
	# For tutorial we check if juline is staggered 
	# or lucine has hp lower than 50%
	return juline.staggered or is_lucine_below_limit()

## Get Act results
func get_act_results() -> Variant:
	# For tutorial, player wins if lucine's hp drops bellow 50%
	return {
		"is_mortal_act": false,
		"victory": is_lucine_below_limit(),
	}

## Is Lucine Bellow Limit?
func is_lucine_below_limit() -> bool:
	var result: bool = true
	if lucine:
		result = lucine.hp < int(lucine.max_hp * lucine_hp_limit)
	return result
