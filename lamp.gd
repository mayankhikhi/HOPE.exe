extends Node3D

@onready var light = $"../OmniLight3D"

var is_on = true

func interact():
	if is_on:
		light.visible = false
		is_on = false
	else:
		light.visible = true
		is_on = true
