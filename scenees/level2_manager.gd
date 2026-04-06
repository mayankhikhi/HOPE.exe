extends Node

# Level 2 specific horror management
var tubelight_saved = []
var horror_started = false

func _ready():
	print("=== Level 2 Manager: Initializing ===")
	add_to_group("gamemanager")  # Register as gamemanager for phone_ui to find
	find_and_save_tubelights()

func find_and_save_tubelights():
	# Find tubelight references for flickering
	print("DEBUG: Finding tubelights for Level 2...")
	tubelight_saved.clear()
	
	# Search in lights group
	for light in get_tree().get_nodes_in_group("lights"):
		if light and "light_energy" in light and light.name == "tubelight":
			tubelight_saved.append(light)
			print("  ✓ Saved tubelight from lights group")
	
	# Find stray tubelights
	for node in get_tree().root.find_children("*", "Light3D", true, false):
		if node and "light_energy" in node and node.name == "tubelight":
			if node not in tubelight_saved:
				tubelight_saved.append(node)
				print("  ✓ Saved stray tubelight")
	
	print("Total tubelights saved: %d" % tubelight_saved.size())

func trigger_level2_horror():
	# Called by phone_ui when all messages sent
	if horror_started:
		print("WARNING: Level 2 horror already started")
		return
	
	horror_started = true
	print("!!! LEVEL 2 HORROR TRIGGERED ===")
	
	# Turn off world environment for darkness - AGGRESSIVE DARKENING
	print("DEBUG: Disabling environment and lights...")
	var lights_disabled = 0
	
	# First, disable environment
	for env in get_tree().get_nodes_in_group("env"):
		if env and env is WorldEnvironment:
			var dark_env = Environment.new()
			dark_env.ambient_light_energy = 0.0
			dark_env.background_mode = Environment.BG_COLOR
			dark_env.background_color = Color.BLACK
			dark_env.tonemap_exposure = 0.1
			dark_env.adjustment_enabled = true
			dark_env.adjustment_brightness = 0.3
			dark_env.adjustment_contrast = 1.5
			env.environment = dark_env
			print("  ✓ ", env.name, " set to PITCH BLACK")
	
	# Turn off ALL lights except tubelight
	for light in get_tree().get_nodes_in_group("lights"):
		if light and "light_energy" in light:
			if light.name != "tubelight":
				light.light_energy = 0
				lights_disabled += 1
				print("  ✓ Turned OFF: ", light.name)
	
	# Also search entire scene for stray lights
	for node in get_tree().root.find_children("*", "Light3D", true, false):
		if node and "light_energy" in node:
			if node.light_energy > 0 and node.name != "tubelight":
				node.light_energy = 0
				lights_disabled += 1
				print("  ✓ Turned OFF stray light: ", node.name)
	
	print("Total lights disabled: %d" % lights_disabled)
	
	# Start flickering tubelights
	if tubelight_saved.size() > 0:
		start_flicker(tubelight_saved)
	else:
		print("WARNING: No tubelights found for flickering")
	
	# Play chase sound
	play_chase_sound()
	
	# Game continues - player must navigate to void

func start_flicker(lights: Array):
	print("Starting tubelight flicker for %d lights" % lights.size())
	
	# Flicker pattern: bright -> dim -> bright -> off
	var original_energy = 1.5
	var dim_energy = 0.3
	
	while true:
		# Set all lights to bright
		for light in lights:
			if is_instance_valid(light):
				light.light_energy = original_energy
		await get_tree().create_timer(0.1).timeout
		
		# Set all lights to dim
		for light in lights:
			if is_instance_valid(light):
				light.light_energy = dim_energy
		await get_tree().create_timer(0.15).timeout
		
		# Set all lights to bright
		for light in lights:
			if is_instance_valid(light):
				light.light_energy = original_energy
		await get_tree().create_timer(0.08).timeout
		
		# Set all lights to off
		for light in lights:
			if is_instance_valid(light):
				light.light_energy = 0
		await get_tree().create_timer(0.12).timeout
		
		# Check if any lights still valid
		var any_valid = false
		for light in lights:
			if is_instance_valid(light):
				any_valid = true
				break
		
		if not any_valid:
			print("Tubelight flicker stopped (lights invalid)")
			break

func play_chase_sound():
	# Try to find and play chase sound from player
	var player = get_tree().get_first_node_in_group("players")
	if not player:
		player = get_tree().root.find_child("ProtoController", true, false)
	
	if player:
		# Try various node names for chase sound
		var chase = null
		for node_name in ["chasesound", "ChasingSound", "chase", "AudioStreamPlayer3D"]:
			chase = player.get_node_or_null(node_name)
			if chase and (chase is AudioStreamPlayer3D):
				break
			chase = null
		
		if chase:
			chase.volume_db = 25
			chase.play()
			print("✓ Chase sound started")
		else:
			print("WARNING: Chase sound not found on player")
	else:
		print("WARNING: Player not found for chase sound")
