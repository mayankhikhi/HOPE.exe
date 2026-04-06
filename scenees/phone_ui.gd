extends CanvasLayer

# UI References
var notification_panel: PanelContainer
var notification_label: Label
var instruction_label: Label
var chat_panel: Control
var phone_screen: Control  # Changed from PanelContainer to Control
var chat_display: TextEdit
var chat_input: LineEdit
var send_btn: Button
var contact_buttons: Dictionary = {}

# State tracking
var is_phone_open = false
var current_contact = ""
var chat_history = {
	"girlfriend": ["Hey babe", "How are you?", "I miss you <3", "i love you <3"],
	"dad": ["Call me when you get home", "Work was exhausting", "How's school?"],
	"mom": ["Don't forget dinner", "Love you sweetheart", "Be safe"]
}
var messages_sent = {
	"girlfriend": false,
	"dad": false,
	"mom": false
}

# Messages to send
var message_queue = {
	"girlfriend": "FUCK YOU BITCH!",
	"dad": "I hope you die. You can never become a good father",
	"mom": "I hate you"
}

# Sound placeholders
var sound_message_arrival: AudioStreamPlayer
var sound_typing: AudioStreamPlayer
var sound_message_sent: AudioStreamPlayer

func _ready():
	print("=== Phone UI: Initializing ===")
	setup_ui()
	setup_sounds()
	show_initial_notification()

func setup_sounds():
	# Create sound player nodes (placeholders - attach actual audio streams in editor)
	sound_message_arrival = AudioStreamPlayer.new()
	sound_message_arrival.name = "MessageArrivalSound"
	add_child(sound_message_arrival)
	print("✓ Message arrival sound placeholder created")
	
	sound_typing = AudioStreamPlayer.new()
	sound_typing.name = "TypingSound"
	add_child(sound_typing)
	print("✓ Typing sound placeholder created")
	
	sound_message_sent = AudioStreamPlayer.new()
	sound_message_sent.name = "MessageSentSound"
	add_child(sound_message_sent)
	print("✓ Message sent sound placeholder created")

func setup_ui():
	print("DEBUG: Setting up phone UI...")
	
	# Create notification panel (bottom right) - style like text message
	notification_panel = PanelContainer.new()
	notification_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	notification_panel.offset_left = -360
	notification_panel.offset_top = -140
	notification_panel.size = Vector2(340, 120)
	add_child(notification_panel)
	
	# Style the notification panel
	var notification_style = StyleBoxFlat.new()
	notification_style.bg_color = Color(0.15, 0.15, 0.15, 0.95)
	notification_style.border_color = Color(0.3, 0.7, 1.0, 1.0)
	notification_style.set_border_width_all(2)
	notification_panel.add_theme_stylebox_override("panel", notification_style)
	
	var notif_vbox = VBoxContainer.new()
	notif_vbox.add_theme_constant_override("separation", 5)
	notification_panel.add_child(notif_vbox)
	
	notification_label = Label.new()
	notification_label.text = "👧 Girlfriend\ni love you <3"
	notification_label.custom_minimum_size = Vector2(320, 50)
	notification_label.add_theme_font_size_override("font_size", 14)
	notif_vbox.add_child(notification_label)
	
	instruction_label = Label.new()
	instruction_label.text = "--1 pending message--\n'P' to interact"
	instruction_label.custom_minimum_size = Vector2(320, 40)
	instruction_label.add_theme_font_size_override("font_size", 12)
	instruction_label.add_theme_color_override("font_color", Color.YELLOW)
	notif_vbox.add_child(instruction_label)
	
	print("✓ Notification panel created (bottom right)")
	
	# Create phone screen (center) - initially hidden - PHONE-LIKE APPEARANCE
	phone_screen = Control.new()
	phone_screen.set_anchors_preset(Control.PRESET_CENTER)
	phone_screen.size = Vector2(420, 740)
	phone_screen.visible = false
	add_child(phone_screen)
	
	# Phone background (bezel-like)
	var phone_bg = ColorRect.new()
	phone_bg.color = Color.BLACK
	phone_bg.anchor_right = 1.0
	phone_bg.anchor_bottom = 1.0
	phone_screen.add_child(phone_bg)
	move_child(phone_bg, 0)
	
	# Screen inside phone
	chat_panel = PanelContainer.new()
	chat_panel.anchor_left = 0
	chat_panel.anchor_top = 0
	chat_panel.anchor_right = 1
	chat_panel.anchor_bottom = 1
	chat_panel.offset_left = 10
	chat_panel.offset_top = 20
	chat_panel.offset_right = -10
	chat_panel.offset_bottom = -20
	phone_screen.add_child(chat_panel)
	
	var screen_style = StyleBoxFlat.new()
	screen_style.bg_color = Color(0.05, 0.05, 0.05, 1.0)
	chat_panel.add_theme_stylebox_override("panel", screen_style)
	
	var chat_vbox = VBoxContainer.new()
	chat_vbox.add_theme_constant_override("separation", 8)
	chat_panel.add_child(chat_vbox)
	
	# Status bar at top
	var status_label = Label.new()
	status_label.text = "📱 Messages"
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color.WHITE)
	status_label.custom_minimum_size = Vector2(0, 40)
	chat_vbox.add_child(status_label)
	
	# Contact buttons
	var buttons_hbox = HBoxContainer.new()
	buttons_hbox.add_theme_constant_override("separation", 5)
	buttons_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons_hbox.custom_minimum_size = Vector2(0, 50)
	chat_vbox.add_child(buttons_hbox)
	
	for contact in ["girlfriend", "dad", "mom"]:
		var btn = Button.new()
		btn.text = contact.capitalize()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 40)
		btn.pressed.connect(_on_contact_selected.bindv([contact]))
		
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.2, 0.2, 0.2, 1.0)
		btn_style.border_color = Color(0.4, 0.4, 0.4, 1.0)
		btn_style.set_border_width_all(1)
		btn.add_theme_stylebox_override("normal", btn_style)
		
		buttons_hbox.add_child(btn)
		contact_buttons[contact] = btn
	
	# Chat display
	chat_display = TextEdit.new()
	chat_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chat_display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chat_display.custom_minimum_size = Vector2(0, 250)
	chat_display.editable = false
	var chat_display_style = StyleBoxFlat.new()
	chat_display_style.bg_color = Color(0.1, 0.1, 0.1, 1.0)
	chat_display.add_theme_stylebox_override("normal", chat_display_style)
	chat_vbox.add_child(chat_display)
	
	# Chat input area
	var input_container = VBoxContainer.new()
	input_container.add_theme_constant_override("separation", 3)
	input_container.custom_minimum_size = Vector2(0, 90)
	input_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chat_vbox.add_child(input_container)
	
	chat_input = LineEdit.new()
	chat_input.placeholder_text = "Type message..."
	chat_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chat_input.custom_minimum_size = Vector2(0, 40)
	chat_input.text_changed.connect(_on_typing)
	chat_input.text_submitted.connect(_on_send_message)
	var input_style = StyleBoxFlat.new()
	input_style.bg_color = Color(0.15, 0.15, 0.15, 1.0)
	chat_input.add_theme_stylebox_override("normal", input_style)
	input_container.add_child(chat_input)
	
	# Send button
	send_btn = Button.new()
	send_btn.text = "SEND ✓"
	send_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	send_btn.custom_minimum_size = Vector2(0, 35)
	send_btn.add_theme_font_size_override("font_size", 14)
	send_btn.pressed.connect(_on_send_message)
	input_container.add_child(send_btn)
	
	print("✓ Send button created and visible")
	
	# Close button (bottom)
	var close_btn = Button.new()
	close_btn.text = "Close (P)"
	close_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close_btn.custom_minimum_size = Vector2(0, 35)
	close_btn.pressed.connect(close_phone)
	chat_vbox.add_child(close_btn)
	
	print("✓ Phone UI created with phone-like styling")

func show_initial_notification():
	print("DEBUG: Showing girlfriend notification...")
	notification_panel.show()
	play_sound(sound_message_arrival)
	# This stays visible until phone is opened

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_P:
			if not is_phone_open:
				open_phone()
			else:
				close_phone()
			get_tree().root.set_input_as_handled()  # Prevent P key reaching player

func open_phone():
	print("DEBUG: Phone opened (P key)")
	is_phone_open = true
	notification_panel.hide()
	phone_screen.show()
	
	# Lock player movement
	lock_player_movement()
	
	# Unlock mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Default to girlfriend if no contact selected
	if current_contact == "":
		print("✓ Selecting default contact: girlfriend")
		_on_contact_selected("girlfriend")
		await get_tree().process_frame  # Ensure UI is updated
	
	# Focus on chat input
	chat_input.grab_focus()
	print("✓ Chat input focused - ready to type")

func close_phone():
	print("DEBUG: Phone closed")
	is_phone_open = false
	phone_screen.hide()
	
	# Unlock player movement
	unlock_player_movement()
	
	# Lock mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if not all_messages_sent():
		notification_panel.show()

func lock_player_movement():
	# Disable player input
	var player = get_tree().get_first_node_in_group("players")
	if not player:
		player = get_tree().root.find_child("ProtoController", true, false)
	
	if player and player.has_method("disable_input"):
		player.disable_input()
		print("✓ Player movement locked")
	elif player:
		# Fallback: disable physics if available
		if "velocity" in player:
			player.velocity = Vector3.ZERO
		print("✓ Player velocity zeroed")

func unlock_player_movement():
	# Enable player input
	var player = get_tree().get_first_node_in_group("players")
	if not player:
		player = get_tree().root.find_child("ProtoController", true, false)
	
	if player and player.has_method("enable_input"):
		player.enable_input()
		print("✓ Player movement unlocked")

func _on_contact_selected(contact: String):
	print("DEBUG: Selected contact: %s" % contact)
	current_contact = contact
	
	# Update button states - highlight active
	for c in contact_buttons:
		var btn_style = StyleBoxFlat.new()
		if c == contact:
			btn_style.bg_color = Color(0.3, 0.6, 1.0, 1.0)  # Highlight active
			btn_style.border_color = Color(0.5, 0.8, 1.0, 1.0)
		else:
			btn_style.bg_color = Color(0.2, 0.2, 0.2, 1.0)
			btn_style.border_color = Color(0.4, 0.4, 0.4, 1.0)
		btn_style.set_border_width_all(2)
		contact_buttons[c].add_theme_stylebox_override("normal", btn_style)
	
	# Display chat history
	chat_display.clear()
	for msg in chat_history[contact]:
		chat_display.text += msg + "\n"
	
	# Auto-fill with queued message if not sent
	if not messages_sent[contact]:
		var msg_to_send = message_queue[contact]
		chat_input.text = msg_to_send
		print("✓ Pre-filled message: %s" % msg_to_send)
	else:
		chat_input.text = ""
		print("✓ Already sent message to %s" % contact)
	
	# Focus on input field so user can edit if needed
	chat_input.grab_focus()

func _on_typing():
	# Play typing sound - uncomment when you add audio
	# play_sound(sound_typing)
	pass

func _on_send_message():
	print("DEBUG: _on_send_message called - contact:%s, text:%s" % [current_contact, chat_input.text])
	
	if current_contact == "":
		print("ERROR: No contact selected!")
		return
	
	if chat_input.text == "":
		print("ERROR: No message to send!")
		return
	
	var sent_msg = chat_input.text
	
	print("✓✓✓ MESSAGE SENT TO %s: %s" % [current_contact.to_upper(), sent_msg])
	
	# Record in history
	chat_history[current_contact].append("[You]: " + sent_msg)
	chat_display.text += "[You]: " + sent_msg + "\n"
	
	# Auto-scroll to bottom
	chat_display.set_caret_line(chat_display.get_line_count())
	
	# Mark as sent
	messages_sent[current_contact] = true
	chat_input.clear()
	
	# Play send sound
	play_sound(sound_message_sent)
	print("✓ Message marked as sent for", current_contact)
	
	# Check if all messages sent
	if all_messages_sent():
		print("!!! ALL MESSAGES SENT - TRIGGERING HORROR FOR LEVEL 2 !!!")
		trigger_level2_horror()

func all_messages_sent() -> bool:
	return messages_sent["girlfriend"] and messages_sent["dad"] and messages_sent["mom"]

func trigger_level2_horror():
	# Remove the close button restriction - system continues
	close_phone()
	
	# Signal to GameManager that level 2 horror should start
	var game_manager = get_tree().get_first_node_in_group("gamemanager")
	if game_manager and game_manager.has_method("trigger_level2_horror"):
		game_manager.trigger_level2_horror()
		# Start showing flashy messages
		show_horror_messages_level2()
	else:
		print("ERROR: GameManager not found or missing trigger_level2_horror method")

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

func play_sound(audio_player: AudioStreamPlayer):
	# Placeholder - will play sound when you attach audio stream in editor
	if audio_player and audio_player.stream:
		audio_player.play()
	# If no stream assigned, silently skip (no error)
