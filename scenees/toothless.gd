extends RigidBody3D
var player = null
var is_destroyed = false

func _ready():
	body_entered.connect(_enter)
	body_exited.connect(_exit)
	add_to_group("interactable")

func _enter(body):
	if body.name == "ProtoController":
		player = body
		player.set_interactable(self)

func _exit(body):
	if body.name == "ProtoController":
		player = null
		body.set_interactable(null)

func interact():
	if is_destroyed:
		return
	
	is_destroyed = true
	var toothless = get_parent()
	
	# Try to find cracking sound - check multiple possible names
	var crack_sound = null
	
	# Try exact name first
	crack_sound = toothless.get_node_or_null("cracking")
	
	# If not found, try alternative names
	if not crack_sound:
		crack_sound = toothless.get_node_or_null("CrackingSound")
	if not crack_sound:
		crack_sound = toothless.get_node_or_null("Cracking")
	if not crack_sound:
		crack_sound = toothless.get_node_or_null("crack_sound")
	
	# If still not found, list all children for debugging
	if not crack_sound:
		print("DEBUG: Toothless children are:")
		for child in toothless.get_children():
			print("  - ", child.name, " (type: ", child.get_class(), ")")

	# Play crack sound and boost volume
	if crack_sound and crack_sound is AudioStreamPlayer3D:
		# Ensure it's not muted and volume is audible
		crack_sound.volume_db = 20  # Loudly audible at +20dB
		crack_sound.bus = &"Master"  # Use master bus
		crack_sound.play()
		print("Toothless crack sound PLAYING at volume +20dB - LOUDLY")
	else:
		print("WARNING: Toothless cracking sound not found or not AudioStreamPlayer3D")

	await get_tree().create_timer(1.0).timeout

	# Apply physics impulse if it's a RigidBody3D
	if toothless is RigidBody3D:
		toothless.freeze = false
		toothless.apply_impulse(Vector3.ZERO, Vector3(0, 2, -4))
		print("Toothless thrown")

	GameManager.register_destroy("toothless")
