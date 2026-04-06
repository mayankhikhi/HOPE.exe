extends Area3D

var player = null
var is_done = false

func _ready():
	body_entered.connect(_enter)
	body_exited.connect(_exit)
	add_to_group("interactable")  # ADD THIS SO PLAYER CAN INTERACT

func _enter(body):
	if body.name == "ProtoController":
		player = body
		player.set_interactable(self)

func _exit(body):
	if body.name == "ProtoController":
		player = null
		body.set_interactable(null)

func interact():
	if is_done:
		return
	
	is_done = true
	await cinematic()

func cinematic():
	# Save player reference FIRST - it may become null when teddy is freed
	var saved_player = player
	
	var cam = saved_player.get_node("Head/Camera3D")
	var teddy = get_parent()
	var crack_sound = teddy.get_node_or_null("cracking")
	
	# Use eyes node for the rotation effect
	var eyes_node = teddy.get_node_or_null("Sketchfab_model/a86697fc1617443da37c4f96ab6a688d_fbx/RootNode/ojos_low/ojos_low_ojos_low0_0")

	print("Teddy cinematic started")
	
	# lock movement
	saved_player.can_move = false

	# move teddy in front of camera (pickup effect)
	var target_pos = cam.global_position + cam.global_transform.basis.z * -0.8
	teddy.global_position = target_pos

	# face camera
	teddy.look_at(cam.global_position, Vector3.UP)

	await get_tree().create_timer(0.3).timeout

	# play crack sound BEFORE animation (so it plays during the sequence)
	if crack_sound:
		crack_sound.volume_db = 20  # BOOST VOLUME
		crack_sound.play()
		print("Crack sound playing at +20dB")
	else:
		print("WARNING: cracking sound not found on Teddy - add AudioStreamPlayer3D named 'cracking'")

	# eye snap animation - rotate eyes violently
	if eyes_node:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_IN)
		
		# Violent rotation sequence for horror effect
		tween.tween_property(eyes_node, "rotation_degrees", Vector3(45, 90, -45), 0.15)
		tween.tween_property(eyes_node, "rotation_degrees", Vector3(-30, -60, 60), 0.1)
		tween.tween_property(eyes_node, "rotation_degrees", Vector3(180, 0, 90), 0.15)
		
		print("Eyes rotated - horror effect")

	await get_tree().create_timer(0.5).timeout

	# throw teddy forward with tween first (camera effect)
	var throw_dir = -cam.global_transform.basis.z
	var original_teddy_pos = teddy.global_position
	var tween_throw = create_tween()
	tween_throw.set_trans(Tween.TRANS_BACK)
	tween_throw.set_ease(Tween.EASE_IN)
	tween_throw.tween_property(teddy, "global_position", original_teddy_pos + throw_dir * 3.0, 0.4)
	await tween_throw.finished

	# NOW apply physics impulse to make it fall realistically
	if teddy is RigidBody3D:
		teddy.freeze = false
		teddy.apply_impulse(Vector3.ZERO, Vector3(randf_range(-2, 2), -3, randf_range(-2, 2)))
		print("Physics impulse applied - teddy falling")

	await get_tree().create_timer(1.0).timeout

	teddy.queue_free()
	saved_player.can_move = true
	
	# Register destroy with GameManager
	GameManager.register_destroy("teddy")
	print("Teddy destroyed and removed")
