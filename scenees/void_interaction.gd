extends Area3D

# When player interacts with void, transition to next level
var can_interact = false
var e_prompt_ui: CanvasLayer

func _ready():
	print("=== Void Interaction: Ready ===")
	add_to_group("void")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Get reference to E prompt UI
	e_prompt_ui = get_tree().root.find_child("EPromptUI", true, false)
	if not e_prompt_ui:
		print("WARNING: E Prompt UI not found in scene")

func _on_body_entered(body):
	# Check if it's the player
	if body.is_in_group("players") or "ProtoController" in body.name:
		print("DEBUG: Player entered void area - can interact")
		can_interact = true
		
		# Show E prompt
		if e_prompt_ui:
			e_prompt_ui.show_prompt_for(self, "[E] Enter Void")

func _on_body_exited(body):
	if body.is_in_group("players") or "ProtoController" in body.name:
		print("DEBUG: Player left void area")
		can_interact = false
		
		# Hide E prompt
		if e_prompt_ui:
			e_prompt_ui.hide_prompt()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		if can_interact:
			print("!!! VOID INTERACTION: Transitioning to level_test_3.tscn ===")
			get_tree().change_scene_to_file("res://scenees/level_test_3.tscn")
