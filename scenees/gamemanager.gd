extends Node

var total_required = 0
var destroyed = 0
var triggered = false

func _ready():
	# Hide the horror label at start
	var label = get_tree().root.find_child("HorrorLabel", true, false)
	if label and label is Label:
		label.modulate = Color(1, 1, 1, 0)  # Invisible at start
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block mouse
		
		# Also disable mouse filter on all children (ColorRect, TextureRect, etc)
		for child in label.find_children("*", "Control", true, false):
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		print("✓ HorrorLabel & children: mouse passthrough enabled")
	
	# Turn off lamp and tubelight at start (they will flicker during horror)
	turn_off_initial_lights()
	
	# Count all interactable objects
	var interactables = get_tree().get_nodes_in_group("interactable")
	total_required = interactables.size()
	print("GameManager: Found %d interactable objects to destroy" % total_required)
	print("DEV: Press F to trigger horror")

func _process(delta):
	# DEV KEY: Press F only while also pressing nothing else to trigger horror
	if Input.is_key_pressed(KEY_F) and not triggered:
		triggered = true
		print("DEV: Horror triggered manually by F key")
		start_horror()

func turn_off_initial_lights():
	# Turn off lamp and tubelight lights at the start (they will flicker when horror begins)
	print("DEBUG: Turning off initial lamp and tubelight lights...")
	var lights_off = 0
	
	# Search for tablelamplight and tubelight in all lights
	var all_lights = get_tree().get_nodes_in_group("lights")
	for light in all_lights:
		if light and "light_energy" in light and light.name in ["tablelamplight", "tubelight"]:
			light.light_energy = 0
			lights_off += 1
			print("  ✓ ", light.name, " turned OFF")
	
	# Also search in entire scene for any stray lamp/tubelight lights
	for node in get_tree().root.find_children("*", "Light3D", true, false):
		if node and "light_energy" in node and node.name in ["tablelamplight", "tubelight"]:
			if node.light_energy > 0:
				node.light_energy = 0
				lights_off += 1
				print("  ✓ Found stray ", node.name, " and turned OFF")
	
	print("Initial lights disabled: %d" % lights_off)

func register_destroy(type):
	destroyed += 1
	print("Destroyed: %d/%d (%s)" % [destroyed, total_required, type])

	# ONLY trigger if destroyed ALL objects AND counter is valid
	if total_required > 0 and destroyed >= total_required and not triggered:
		triggered = true
		print("!!! ALL %d OBJECTS DESTROYED - HORROR STARTING !!!" % total_required)
		start_horror()

func start_horror():
	print("HORROR START")

	await get_tree().create_timer(1.0).timeout

	# Turn off world environment for darkness
	print("DEBUG: Disabling environment...")
	var env_disabled = 0
	for env in get_tree().get_nodes_in_group("env"):
		print("  Found env node: ", env.name, " type: ", env.get_class())
		if env and env is WorldEnvironment:
			# Create a completely dark environment
			var dark_env = Environment.new()
			dark_env.ambient_light_energy = 0  # No ambient light
			dark_env.background_mode = Environment.BG_COLOR
			dark_env.background_color = Color.BLACK
			env.environment = dark_env
			env_disabled += 1
			print("  ✓ ", env.name, " set to dark environment")
	
	print("Environment disabled: %d nodes" % env_disabled)

	# lights OFF - turn off ALL lights in the scene (not just group)
	print("DEBUG: Turning off lights...")
	var lights_found = 0
	# Array will be created in the loop below
	
	# First, turn off lights in "lights" group
	var all_lights = get_tree().get_nodes_in_group("lights")
	var flicker_lights = []  # Array to store multiple lights for flickering
	print("  Total lights in 'lights' group: ", all_lights.size())
	for light in all_lights:
		print("  Found grouped light: ", light.name, " type: ", light.get_class())
		if light and "light_energy" in light:
			# Save lights for flickering instead of turning off
			if light.name in ["tablelamplight", "tubelight"]:
				flicker_lights.append(light)
				print("    ✓ ", light.name, " saved for flickering")
			else:
				light.light_energy = 0
				lights_found += 1
				print("    ✓ ", light.name, " turned OFF")
	
	# Second, find ALL DirectionalLight3D, OmniLight3D, SpotLight3D in the entire scene
	for node in get_tree().root.find_children("*", "Light3D", true, false):
		if node and "light_energy" in node:
			if node.light_energy > 0:
				# ADD LIGHT NAMES HERE for flickering
				if node.name in ["tablelamplight", "tubelight"]:  # PLACEHOLDER: Add light names here
					flicker_lights.append(node)
					print("  Found stray ", node.name, " for flickering")
				else:
					print("  Found stray light: ", node.name, " at energy ", node.light_energy)
					node.light_energy = 0
					lights_found += 1
					print("    ✓ ", node.name, " turned OFF")
	
	print("Turned off %d total lights" % lights_found)
	
	# Start flickering all saved lights
	if flicker_lights.size() > 0:
		start_flicker(flicker_lights)
		print("Flickering started for %d lights" % flicker_lights.size())
	else:
		print("WARNING: No lights found for flickering")

	await get_tree().create_timer(1.0).timeout

	# STOP music box when horror starts - check all possible names
	var music_box = get_tree().get_root().find_child("Music Box", true, false)
	if not music_box:
		music_box = get_tree().get_root().find_child("musicbox", true, false)
	if not music_box:
		music_box = get_tree().get_root().find_child("music_box", true, false)
	
	if music_box and music_box is AudioStreamPlayer3D:
		music_box.stop()
		print("✓ Music box stopped")
	else:
		# Try to find in audio group
		var music_audio = get_tree().get_first_node_in_group("music")
		if music_audio and music_audio is AudioStreamPlayer3D:
			music_audio.stop()
			print("✓ Music box stopped (from 'music' group)")
		else:
			print("WARNING: Music box not found")

	# baby cry - INCREASE VOLUME for psychological impact
	var baby = get_tree().get_first_node_in_group("baby_audio")
	if baby and baby is AudioStreamPlayer3D:
		baby.volume_db = 20  # LOUD baby cry for horror
		baby.play()
		print("✓ Baby cry started at +15dB LOUDLY")
	else:
		print("WARNING: baby_audio not found in groups")

	# Play chase sound - check multiple locations
	var player = get_tree().get_first_node_in_group("players")
	if not player:
		player = get_tree().root.find_child("ProtoController", true, false)
	
	if player:
		# Try multiple node names for chase sound
		var chase = null
		chase = player.get_node_or_null("chasesound")
		if not chase:
			chase = player.get_node_or_null("ChasingSound")
		if not chase:
			chase = player.get_node_or_null("chase")
		if not chase:
			# List all audio children
			for child in player.find_children("*", "AudioStreamPlayer3D", true, false):
				print("  Found audio on player: ", child.name)
				if "chase" in child.name.to_lower() or child.name == "AudioStreamPlayer3D":
					chase = child
					break
		
		if chase and chase is AudioStreamPlayer3D:
			chase.volume_db = 18  # Loud chase effect
			chase.play()
			print("✓ Chase sound started - following player")
		else:
			print("WARNING: chasesound not found on player - checking scene...")
	else:
		print("WARNING: ProtoController not found")

	# SHOW HORROR MESSAGE TO PLAYER
	show_horror_message()

	# shake floor while baby cries - this will run until unlocked/scene changes
	shake_floor()
	
	# unlock door immediately so player can leave during shake
	for d in get_tree().get_nodes_in_group("exitdoor"):
		if d.has_method("unlock"):
			d.unlock()
		else:
			d.set("locked", false)
	
	print("Horror sequence started - floor will shake until scene change")
	
func shake_floor():
	var floor = get_tree().get_first_node_in_group("floor")
	
	if not floor:
		print("WARNING: Floor not found in 'floor' group - skipping shake")
		return
	
	# Only shake if it's a Node3D (not MeshInstance which can't be translated)
	if not (floor is Node3D):
		print("WARNING: Floor is not a Node3D - cannot shake")
		return

	var original_pos = floor.position
	print("Floor shake started at ", original_pos)
	
	# Shake continuously until scene changes (no reset)
	# Player must navigate to exit during the shaking
	var shake_iter = 0
	while is_instance_valid(floor):  # Check if floor still exists
		floor.position = original_pos + Vector3(
			randf_range(-0.2, 0.2),  # X shake
			0,  # No vertical movement
			randf_range(-0.2, 0.2)   # Z shake
		)
		shake_iter += 1
		await get_tree().create_timer(0.05).timeout
	
	# This only runs if floor is deleted
	print("Floor shake stopped after %d iterations" % shake_iter)

func start_flicker(lights: Array):
	# Flicker multiple lights continuously until scene changes
	var original_energy = 1.5  # Bright flicker
	var dim_energy = 0.3  # Dim flicker
	
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

func show_horror_message():
	# Array of psychological horror messages
	var horror_messages = [
		"SOMETHING WOKE UP...",
		"YOU SHOULDN'T HAVE TOUCHED THEM",
		"THEY'RE WATCHING YOU NOW",
		"YOU CAN'T ESCAPE NOW",
		"THE NURSERY REMEMBERS",
		"TURN AROUND...",
		"IT'S INSIDE WITH YOU",
		"DON'T LOOK BACK"
	]
	
	var label = get_tree().root.find_child("HorrorLabel", true, false)
	
	if not (label and label is Label):
		print("ERROR: HorrorLabel not found")
		return
	
	# Ensure mouse input is ignored (so it doesn't block interaction)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Show 3 messages in quick succession with SNAP effect
	for i in range(3):
		var message = horror_messages[randi() % horror_messages.size()]
		
		# SNAP in instantly (no tween)
		label.text = message
		label.modulate = Color.WHITE
		print("✓ FLASH %d: %s" % [i+1, message])
		
		# PLACEHOLDER: Play sound effect on message
		var horror_sound = label.get_node_or_null("horrorflashsound")
		if horror_sound and horror_sound is AudioStreamPlayer:
			horror_sound.play()
			print("  └─ Horror flash sound")
		
		await get_tree().create_timer(0.15).timeout  # Show for 0.15 seconds
		
		# SNAP out instantly (no tween)
		label.modulate = Color(1, 1, 1, 0)
		
		if i < 2:  # Gap between messages
			await get_tree().create_timer(0.25).timeout
	
	print("✓ Horror messages complete")
