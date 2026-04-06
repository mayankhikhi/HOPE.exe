extends Node

# Level 2 specific horror management
var tubelight_saved = []
var horror_started = false

func _ready():
	print("=== Level 2 Manager: Initializing ===")
	add_to_group("gamemanager")  # Register as gamemanager for phone_ui to find
	find_and_save_tubelights()

func find_and_save_tubelights():
	# Find tubelight references for flickering - EXACTLY LIKE GAMEMANAGER
	print("DEBUG: Finding tubelights for Level 2...")
	tubelight_saved.clear()
	
	# Search for tubelight in all lights
	var all_lights = get_tree().get_nodes_in_group("lights")
	for light in all_lights:
		if light and "light_energy" in light and light.name == "tubelight":
			tubelight_saved.append(light)
			print("  ✓ Saved ", light.name, " for flickering")
	
	# Also search in entire scene for any stray tubelights
	for node in get_tree().root.find_children("*", "Light3D", true, false):
		if node and "light_energy" in node and node.name == "tubelight":
			# Check if not already in list
			if node not in tubelight_saved:
				tubelight_saved.append(node)
				print("  ✓ Saved stray ", node.name, " for flickering")
	
	print("Total tubelights saved: %d" % tubelight_saved.size())

func trigger_level2_horror():
	# Called by phone_ui when all messages sent
	if horror_started:
		print("WARNING: Level 2 horror already started")
		return
	
	horror_started = true
	print("!!! LEVEL 2 HORROR TRIGGERED ===")
	
	await get_tree().create_timer(1.0).timeout

	# Turn off world environment for darkness - EXACTLY LIKE GAMEMANAGER
	print("DEBUG: Disabling environment...")
	var env_disabled = 0
	for env in get_tree().get_nodes_in_group("env"):
		print("  Found env node: ", env.name, " type: ", env.get_class())
		if env and env is WorldEnvironment:
			# Create a completely dark environment
			var dark_env = Environment.new()
			dark_env.ambient_light_energy = 0.0  # Absolute zero ambient light
			dark_env.background_mode = Environment.BG_COLOR  # Use color mode for black
			dark_env.background_color = Color.BLACK  # Pure black color
			dark_env.tonemap_exposure = 0.1  # Darken the entire scene
			dark_env.adjustment_enabled = true
			dark_env.adjustment_brightness = 0.3  # Very dim
			dark_env.adjustment_contrast = 1.5  # Increase contrast for flicker effect
			env.environment = dark_env
			env_disabled += 1
			print("  ✓ ", env.name, " set to PITCH BLACK environment")
	
	print("Environment disabled: %d nodes" % env_disabled)

	# lights OFF - turn off ALL lights in the scene (not just group) - EXACTLY LIKE GAMEMANAGER
	print("DEBUG: Turning off lights...")
	var lights_found = 0
	
	# First, turn off lights in "lights" group (but not the flickering tubelight)
	var all_lights = get_tree().get_nodes_in_group("lights")
	print("  Total lights in 'lights' group: ", all_lights.size())
	for light in all_lights:
		print("  Found grouped light: ", light.name, " type: ", light.get_class())
		if light and "light_energy" in light:
			# Skip flickering lights - they're already saved separately
			if light.name in ["tablelamplight", "tubelight"]:
				print("    ✓ ", light.name, " reserved for flickering")
			else:
				light.light_energy = 0
				lights_found += 1
				print("    ✓ ", light.name, " turned OFF")
	
	# Second, find ALL DirectionalLight3D, OmniLight3D, SpotLight3D in the entire scene (but not flickering lights)
	for node in get_tree().root.find_children("*", "Light3D", true, false):
		if node and "light_energy" in node:
			if node.light_energy > 0:
				# Skip flickering lights - they're already saved separately
				if node.name in ["tablelamplight", "tubelight"]:
					print("  Found stray ", node.name, " reserved for flickering")
				else:
					# For DirectionalLight3D, reduce energy instead of turning off
					# This keeps some ambient light for flickering visibility
					if node is DirectionalLight3D:
						node.light_energy = 0.2  # Keep some light for contrast
						lights_found += 1
						print("    ✓ ", node.name, " reduced to 0.2 energy (for flicker contrast)")
					else:
						node.light_energy = 0
						lights_found += 1
						print("    ✓ ", node.name, " turned OFF")
	
	print("Turned off %d total lights" % lights_found)
	
	# Start flickering the saved tubelight lights - EXACTLY LIKE GAMEMANAGER
	if tubelight_saved.size() > 0:
		start_flicker(tubelight_saved)
		print("Flickering started for %d lights" % tubelight_saved.size())
	else:
		print("WARNING: No tubelights found for flickering")

	await get_tree().create_timer(1.0).timeout

	# Play chase sound
	play_chase_sound()
	
	# Show horror messages
	show_horror_messages_level2()
	
	# Game continues - player must navigate to void

func show_horror_messages_level2():
	# Flashy horror messages for level 2 (teen angst/guilt theme)
	var horror_messages = [
		"WHAT HAVE YOU DONE...",
		"THEY WILL NEVER FORGIVE YOU",
		"YOU SAID THOSE WORDS...",
		"CAN YOU TAKE THEM BACK?",
		"THE WORDS HAUNT YOU",
		"YOU MONSTER...",
		"THEY'RE SUFFERING BECAUSE OF YOU",
		"THERE'S NO ESCAPE NOW"
	]
	
	var label = get_tree().root.find_child("HorrorLabel", true, false)
	
	if not (label and label is Label):
		print("ERROR: HorrorLabel not found - skipping flashy messages")
		return
	
	# Show 3 messages in quick succession
	for i in range(3):
		var message = horror_messages[randi() % horror_messages.size()]
		
		# SNAP in instantly
		label.text = message
		label.modulate = Color.WHITE
		print("✓ FLASH %d: %s" % [i+1, message])
		
		await get_tree().create_timer(0.15).timeout
		
		# SNAP out instantly
		label.modulate = Color(1, 1, 1, 0)
		
		if i < 2:  # Gap between messages
			await get_tree().create_timer(0.25).timeout
	
	print("✓ Horror messages complete")

func start_flicker(lights: Array):
	# Flicker multiple lights continuously until scene changes - EXACTLY LIKE GAMEMANAGER
	var original_energy = 3.0  # BRIGHT flicker (increased from 1.5)
	var dim_energy = 0.8  # DIM flicker (increased from 0.3)
	
	if lights.is_empty():
		print("ERROR: No lights provided for flickering")
		return
	
	print("Starting flicker for %d lights" % lights.size())
	
	while true:
		# Flicker all lights simultaneously
		for light in lights:
			if is_instance_valid(light):
				light.light_energy = original_energy
		await get_tree().create_timer(0.1).timeout
		
		for light in lights:
			if is_instance_valid(light):
				light.light_energy = dim_energy
		await get_tree().create_timer(0.15).timeout
		
		# Bright again
		for light in lights:
			if is_instance_valid(light):
				light.light_energy = original_energy
		await get_tree().create_timer(0.08).timeout
		
		# Dim again
		for light in lights:
			if is_instance_valid(light):
				light.light_energy = dim_energy
		await get_tree().create_timer(0.12).timeout
		
		for light in lights:
			if is_instance_valid(light):
				light.light_energy = original_energy
		await get_tree().create_timer(0.08).timeout
		
		for light in lights:
			if is_instance_valid(light):
				light.light_energy = 0  # Full off
		await get_tree().create_timer(0.12).timeout
		
		# Check if any lights are still valid
		var any_valid = false
		for light in lights:
			if is_instance_valid(light):
				any_valid = true
				break
		
		if not any_valid:
			break
	
	print("Light flicker stopped")

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
