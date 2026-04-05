extends Area3D

# When player interacts with void, transition to next level
var can_interact = false

func _ready():
	print("=== Void Interaction: Ready ===")
	add_to_group("void")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Check if it's the player
	if body.is_in_group("players") or "ProtoController" in body.name:
		print("DEBUG: Player entered void area - can interact (press E)")
		can_interact = true

func _on_body_exited(body):
	if body.is_in_group("players") or "ProtoController" in body.name:
		print("DEBUG: Player left void area")
		can_interact = false

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		if can_interact:
			print("!!! VOID INTERACTION: Transitioning to level_test_3.tscn ===")
			get_tree().change_scene_to_file("res://scenees/level_test_3.tscn")
