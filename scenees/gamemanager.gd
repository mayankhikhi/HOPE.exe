extends Node

var total_interactables = 0  # Total count from group
var interacted_objects = {}  # Track which ones have been interacted
var triggered = false
var horror_in_progress = false  # Prevent concurrent horror sequences
var last_scene_name = ""
var flicker_lights_saved = []  # Store references to lights for flickering during horror

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
	
	# Initialize the level
	initialize_level()

func initialize_level():
	print("=== GameManager: Initializing level ===")
	
	# Reset horror state for new level
	triggered = false
	horror_in_progress = false
	interacted_objects.clear()
	flicker_lights_saved.clear()
	
	# Count all interactables in the "interactable" group
	var interactables = get_tree().get_nodes_in_group("interactable")
	total_interactables = interactables.size()
	
	print("Found %d interactables in 'interactable' group" % total_interactables)
	print("Ready - interact with all objects to trigger horror")
	print("DEV: Press F to trigger horror")
	
	# Find and save lamp/tubelight references BEFORE turning them off
	find_and_save_flicker_lights()
	
	# Turn off lamp and tubelight at start (they will flicker during horror)
	turn_off_initial_lights()

func _process(delta):
	# Detect scene change by checking if current scene name changed
	# Ignore GameManager (autoload), only trigger on actual game level changes
	var current_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	var current_scene_name = current_scene.name
	
	if last_scene_name != "" and last_scene_name != current_scene_name and current_scene_name != "GameManager":
		print("*** SCENE CHANGED: %s -> %s ***" % [last_scene_name, current_scene_name])
		initialize_level()
	
	last_scene_name = current_scene_name
	
	# DEV KEY: Press F to trigger horror
	if Input.is_key_pressed(KEY_F) and not triggered and not horror_in_progress:
		triggered = true
		print("DEV: Horror triggered manually by F key")
		start_horror()

func find_and_save_flicker_lights():
	# Find lamp and tubelight lights and save their references for later flickering
	print("DEBUG: Finding flicker lights...")
	flicker_lights_saved.clear()
	
	# Search for tablelamplight and tubelight in all lights
	var all_lights = get_tree().get_nodes_in_group("lights")
	for light in all_lights:
		if light and "light_energy" in light and light.name in ["tablelamplight", "tubelight"]:
			flicker_lights_saved.append(light)
			print("  ✓ Saved ", light.name, " for flickering")
	
	# Also search in entire scene for any stray lamp/tubelight lights
	for node in get_tree().root.find_children("*", "Light3D", true, false):
		if node and "light_energy" in node and node.name in ["tablelamplight", "tubelight"]:
			# Check if not already in list
			if node not in flicker_lights_saved:
				flicker_lights_saved.append(node)
				print("  ✓ Saved stray ", node.name, " for flickering")
	
	print("Total flicker lights saved: %d" % flicker_lights_saved.size())

func turn_off_initial_lights():
	# Turn off lamp and tubelight lights at the start (they will flicker when horror begins)
	print("DEBUG: Turning off initial lamp and tubelight lights...")
	var lights_off = 0
	
	# Use the saved references to turn them off
	for light in flicker_lights_saved:
		if is_instance_valid(light):
			light.light_energy = 0
			lights_off += 1
			print("  ✓ ", light.name, " turned OFF")
	
	print("Initial lights disabled: %d" % lights_off)

func register_destroy(type):
	# Mark this object as interacted (only count first time)
	# Don't check group - just track whatever is passed
	
	if type not in interacted_objects:
		# New object type, add it
		interacted_objects[type] = true
		print("✓ Interacted: %s" % type)
	elif not interacted_objects[type]:
		# Already seen but marked false, mark as true
		interacted_objects[type] = true
		print("✓ Interacted: %s" % type)
	else:
		# Already interacted, ignore duplicate
		print("Already interacted: %s (ignoring duplicate)" % type)
		return
	
	# Count how many unique objects have been interacted
	var interacted_count = 0
	for obj_name in interacted_objects.keys():
		if interacted_objects[obj_name]:
			interacted_count += 1
	
	print("Progress: %d unique objects interacted" % interacted_count)
	
	# Check if all objects from the group have been interacted
	# If we have interacted with at least as many as were in the group, start horror
	if total_interactables > 0 and interacted_count >= total_interactables and not triggered and not horror_in_progress:
		triggered = true
		print("!!! ALL INTERACTABLES INTERACTED - HORROR STARTING !!!")
		start_horror()

func stop_music_box():
	# Comprehensive search for music box/ambient music
	print("DEBUG: Searching for music box audio...")
	var stopped = false
	
	# Try specific names first (case variations)
	var search_names = ["Music Box", "musicbox", "music_box", "MusicBox", "AudioStreamPlayer"]
	for name in search_names:
		var found = get_tree().get_root().find_child(name, true, false)
		if found and (found is AudioStreamPlayer or found is AudioStreamPlayer3D):
			if found.playing:
				found.stop()
				print("✓ Music stopped: ", name)
				stopped = true
				return
	
	# Try all groups: music, audio, ambient, bgm
	for group_name in ["music", "musicbox", "ambient", "bgm"]:
		var audio = get_tree().get_first_node_in_group(group_name)
		if audio and (audio is AudioStreamPlayer or audio is AudioStreamPlayer3D):
			if audio.playing:
				audio.stop()
				print("✓ Music stopped from group: ", group_name)
				stopped = true
				return
	
	# Last resort: find ALL audio players and stop ones that are playing (ambient/music)
	var all_audio_3d = get_tree().root.find_children("*", "AudioStreamPlayer3D", true, false)
	for audio in all_audio_3d:
		if audio and audio.playing:
			# Skip baby/chase sounds - only stop ambient/music
			if "baby" not in audio.name.to_lower() and "chase" not in audio.name.to_lower():
				audio.stop()
				print("✓ Music stopped (found stray): ", audio.name)
				stopped = true
				return
	
	var all_audio_2d = get_tree().root.find_children("*", "AudioStreamPlayer", true, false)
	for audio in all_audio_2d:
		if audio and audio.playing:
			# Skip baby/chase sounds - only stop ambient/music
			if "baby" not in audio.name.to_lower() and "chase" not in audio.name.to_lower():
				audio.stop()
				print("✓ Music stopped (found stray 2D): ", audio.name)
				stopped = true
				return
	
	if not stopped:
		print("WARNING: Music box/audio not found or not playing")

func start_horror():
	# Prevent concurrent horror sequences
	if horror_in_progress:
		print("WARNING: Horror already in progress, ignoring duplicate trigger")
		return
	
	horror_in_progress = true
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
	
	# First, turn off lights in "lights" group (but not the flickering lamp/tubelight)
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
					print("  Found stray light: ", node.name, " at energy ", node.light_energy)
					node.light_energy = 0
					lights_found += 1
					print("    ✓ ", node.name, " turned OFF")
	
	print("Turned off %d total lights" % lights_found)
	
	# Start flickering the saved lamp/tubelight lights
	if flicker_lights_saved.size() > 0:
		start_flicker(flicker_lights_saved)
		print("Flickering started for %d lights" % flicker_lights_saved.size())
	else:
		print("WARNING: No flicker lights saved")

	await get_tree().create_timer(1.0).timeout

	# STOP music box when horror starts - comprehensive search
	stop_music_box()

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
			chase.volume_db = 25  # Loud chase effect
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
