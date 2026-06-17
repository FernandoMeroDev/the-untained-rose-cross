extends Node


func fatal_error(message):
	push_error(message)
	Engine.get_main_loop().quit(1)
