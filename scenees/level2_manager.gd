extends Node

# Level 2 manager script
# Handles: phone notification, horror trigger, flickering lights, audio
# Attach to Level2 scene root

var phone_ui: CanvasLayer
var horror_started = false
var flicker_lights_saved = []

func _ready():
	print("=== Level 2 initialized ===")
	
	# Get phone UI (CanvasLayer with phone_ui.gd script)
	phone_ui = get_tree().root.find_child("PhoneUI", true, false)
	if not phone_ui:
		print("ERROR: PhoneUI CanvasLayer not found")
	
	# Find and save flickering lights
	find_and_save_flicker_lights()
	
	# Show initial notification from girlfriend
	await get_tree().create_timer(1.0).timeout
	if phone_ui:
		phone_ui.show_notification("Girlfriend 💕", "i love you <3")
	
	print("Ready - press P to check phone")

func find_and_save_flicker_lights():
	# Find lamp and tubelight lights
	print("DEBUG: Finding tubelight for Level 2...")
	flicker_lights_saved.clear()
	
	# Search for tubelight Light3D nodes
	for node in get_tree().root.find_children("*", "Light3D", true, false):
		if node and "light_energy" in node and "tubelight" in node.name.to_lower():
			flicker_lights_saved.append(node)
			print("  ✓ Saved %s for flickering" % node.name)
	
	print("Total flicker lights saved: %d" % flicker_lights_saved.size())

func start_level2_horror():
	# Called when player sends all 3 messages
	if horror_started:
		return
	
	horror_started = true
	print("!!! LEVEL 2 HORROR STARTING !!!")
	
	await get_tree().create_timer(1.0).timeout
	
	# Start flickering tubelight
	if flicker_lights_saved.size() > 0:
		start_flicker(flicker_lights_saved)
		print("✓ Tubelight flickering started")
	else:
		print("WARNING: No flicker lights found for horror")
	
	# Start chase sound
	start_chase_sound()
	
	# Optional: show horror message
	show_horror_message_l2()
	
	print("Horror sequence active - player must reach void to escape")

func start_flicker(lights: Array):
	# Flicker multiple lights
	var original_energy = 1.5
	var dim_energy = 0.3
	
	while true:
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
				light.light_energy = 0
		await get_tree().create_timer(0.12).timeout
		
		# Check if any lights valid
		var any_valid = false
		for light in lights:
			if is_instance_valid(light):
				any_valid = true
				break
		
		if not any_valid:
			break
	
	print("Light flicker stopped")

func start_chase_sound():
	# Find and play chase sound
	var player = get_tree().root.find_child("ProtoController", true, false)
	if not player:
		player = get_tree().get_first_node_in_group("players")
	
	if player:
		var chase = null
		chase = player.get_node_or_null("chasesound")
		if not chase:
			chase = player.get_node_or_null("ChasingSound")
		if not chase:
			# Search children
			for child in player.find_children("*", "AudioStreamPlayer3D", true, false):
				if "chase" in child.name.to_lower():
					chase = child
					break
		
		if chase and chase is AudioStreamPlayer3D:
			chase.volume_db = 25
			chase.play()
			print("✓ Chase sound started")
		else:
			print("WARNING: Chase sound not found on player")
	else:
		print("WARNING: Player not found for chase sound")

func show_horror_message_l2():
	# Show horror message to player
	var messages = [
		"YOU DESTROYED EVERYTHING",
		"LOOK WHAT YOU'VE DONE",
		"THERE'S NO GOING BACK"
	]
	
	var label = get_tree().root.find_child("HorrorLabel", true, false)
	if not (label and label is Label):
		print("ERROR: HorrorLabel not found")
		return
	
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	for i in range(3):
		var message = messages[i]
		label.text = message
		label.modulate = Color.WHITE
		print("✓ FLASH %d: %s" % [i+1, message])
		
		await get_tree().create_timer(0.15).timeout
		label.modulate = Color(1, 1, 1, 0)
		
		if i < 2:
			await get_tree().create_timer(0.25).timeout
	
	print("✓ Horror messages complete")
