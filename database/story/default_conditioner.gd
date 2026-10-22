# class Database/Story/DefaultConditioner
extends RefCounted

## Narration Chapter Name
var chapter_name: String

## Evaluate Narration Condition
func evaluate_condition(
	condition_name: String, args: Array = []
) -> Variant:
	var result: Variant = callv(condition_name, args)
	return result
