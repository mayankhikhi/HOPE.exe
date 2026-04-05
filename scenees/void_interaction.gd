extends Area3D

# Void portal interaction - transitions to level_test_3.scn

@export var transition_scene = "res://scenees/level_test_3.tscn"
var can_interact = true
var e_prompt_visible = false

func _ready():
	print("✓ Void portal ready")
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area):
	if area.is_in_group("players"):
		show_e_prompt()
		can_interact = true

func _on_area_exited(area):
	if area.is_in_group("players"):
		hide_e_prompt()
		can_interact = false

func show_e_prompt():
	# Show E prompt UI (similar to other interactables)
	e_prompt_visible = true
	var prompt = get_tree().root.find_child("EPrompt", true, false)
	if prompt:
		prompt.visible = true
		print("E Prompt shown (void)")

func hide_e_prompt():
	e_prompt_visible = false
	var prompt = get_tree().root.find_child("EPrompt", true, false)
	if prompt:
		prompt.visible = false

func _process(delta):
	if Input.is_key_pressed(KEY_E) and can_interact and e_prompt_visible:
		interact()

func interact():
	print("✓ Void entered - transitioning to level_test_3...")
	can_interact = false
	get_tree().change_scene_to_file(transition_scene)
