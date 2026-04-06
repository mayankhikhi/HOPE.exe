extends Area3D

@export var type := "train"
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
	var train = get_parent()

	print("Train destroyed")
	
	# Stop train animation if it's playing
	var anim_player = train.get_node_or_null("AnimationPlayer")
	if anim_player and anim_player.is_playing():
		anim_player.stop()
		print("Train animation stopped")

	# Stop running sound (if playing)
	var running_sound = train.get_node_or_null("RunningSound")
	if running_sound and running_sound.playing:
		running_sound.stop()

	# Play destroy sound
	var destroy_sound = train.get_node_or_null("DestroySound")
	if destroy_sound:
		destroy_sound.play()
	else:
		print("WARNING: Train DestroySound not found")

	# Detach train parts - these are paths RELATIVE to the train node
	var parts_to_detach = [
		"Sketchfab_model/root/GLTF_SceneRootNode/Cube_003_2/Object_4",
		"Sketchfab_model/root/GLTF_SceneRootNode/Cube_004_3/Object_16",
		"Sketchfab_model/root/GLTF_SceneRootNode/Cube_005_4/Object_22",
	]
	
	for part_name in parts_to_detach:
		var part = train.get_node_or_null(part_name)
		if part:
			# Rotate the part
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_SINE)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(part, "rotation_degrees", Vector3(randf_range(-45, 45), randf_range(-45, 45), randf_range(-45, 45)), 0.3)
			
			# Move it outward slightly
			tween.parallel()
			tween.tween_property(part, "position", part.position + Vector3(randf_range(-0.5, 0.5), 0.2, randf_range(-0.5, 0.5)), 0.3)
		else:
			print("Note: Train part '%s' not found - add the actual part node names to the parts_to_detach array" % part_name)

	# Main train base rotates slightly
	train.rotation_degrees.z = 45
	
	await get_tree().create_timer(0.5).timeout
	
	# Register destroy with GameManager
	GameManager.register_destroy("train")
