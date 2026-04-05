extends CanvasLayer

# UI References
var notification_panel: PanelContainer
var notification_label: Label
var chat_panel: PanelContainer
var chat_display: TextEdit
var chat_input: LineEdit
var contact_buttons: Dictionary = {}

# State tracking
var is_phone_open = false
var current_contact = ""
var chat_history = {
	"girlfriend": [],
	"dad": [],
	"mom": []
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

func _ready():
	print("=== Phone UI: Initializing ===")
	setup_ui()
	show_initial_notification()

func setup_ui():
	print("DEBUG: Setting up phone UI...")
	
	# Create notification panel (bottom right)
	notification_panel = PanelContainer.new()
	notification_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	notification_panel.offset_left = -320
	notification_panel.offset_top = -100
	notification_panel.size = Vector2(300, 80)
	add_child(notification_panel)
	
	var notification_bg = StyleBox.new()
	notification_panel.add_theme_stylebox_override("panel", notification_bg)
	
	var notif_vbox = VBoxContainer.new()
	notification_panel.add_child(notif_vbox)
	
	notification_label = Label.new()
	notification_label.text = "👧 Girlfriend: i love you <3"
	notification_label.custom_minimum_size = Vector2(280, 60)
	notif_vbox.add_child(notification_label)
	
	print("✓ Notification panel created (bottom right)")
	
	# Create chat panel (center) - initially hidden
	chat_panel = PanelContainer.new()
	chat_panel.set_anchors_preset(Control.PRESET_CENTER)
	chat_panel.size = Vector2(600, 400)
	chat_panel.visible = false
	add_child(chat_panel)
	
	var chat_vbox = VBoxContainer.new()
	chat_panel.add_child(chat_vbox)
	
	# Contact buttons
	var buttons_hbox = HBoxContainer.new()
	chat_vbox.add_child(buttons_hbox)
	
	for contact in ["girlfriend", "dad", "mom"]:
		var btn = Button.new()
		btn.text = contact.capitalize()
		btn.pressed.connect(_on_contact_selected.bindv([contact]))
		buttons_hbox.add_child(btn)
		contact_buttons[contact] = btn
	
	# Chat display
	chat_display = TextEdit.new()
	chat_display.custom_minimum_size = Vector2(560, 250)
	chat_display.editable = false
	chat_vbox.add_child(chat_display)
	
	# Chat input
	chat_input = LineEdit.new()
	chat_input.placeholder_text = "Type message..."
	chat_input.custom_minimum_size = Vector2(560, 40)
	chat_vbox.add_child(chat_input)
	
	# Send button
	var send_btn = Button.new()
	send_btn.text = "Send"
	send_btn.pressed.connect(_on_send_message)
	chat_vbox.add_child(send_btn)
	
	print("✓ Chat panel created (center)")

func show_initial_notification():
	print("DEBUG: Showing girlfriend notification...")
	notification_panel.show()
	# This stays visible until phone is opened

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_P:
			if not is_phone_open:
				open_phone()
			else:
				close_phone()

func open_phone():
	print("DEBUG: Phone opened (P key)")
	is_phone_open = true
	notification_panel.hide()
	chat_panel.show()
	
	# Default to girlfriend
	if current_contact == "":
		_on_contact_selected("girlfriend")

func close_phone():
	print("DEBUG: Phone closed")
	is_phone_open = false
	chat_panel.hide()
	if not all_messages_sent():
		notification_panel.show()

func _on_contact_selected(contact: String):
	print("DEBUG: Selected contact: %s" % contact)
	current_contact = contact
	
	# Update button states
	for c in contact_buttons:
		contact_buttons[c].modulate = Color.GRAY
	contact_buttons[contact].modulate = Color.WHITE
	
	# Display chat history
	chat_display.clear()
	for msg in chat_history[contact]:
		chat_display.text += msg + "\n"
	
	# Auto-fill with queued message if not sent
	if not messages_sent[contact]:
		chat_input.text = message_queue[contact]
	else:
		chat_input.text = ""

func _on_send_message():
	if current_contact == "" or chat_input.text == "":
		return
	
	# Check if this is the expected message for this contact
	var expected_msg = message_queue[current_contact]
	var sent_msg = chat_input.text
	
	print("✓ Message sent to %s: %s" % [current_contact, sent_msg])
	
	# Record in history
	chat_history[current_contact].append("[You]: " + sent_msg)
	chat_display.text += "[You]: " + sent_msg + "\n"
	
	# Mark as sent
	messages_sent[current_contact] = true
	chat_input.clear()
	
	# Check if all messages sent
	if all_messages_sent():
		print("!!! ALL MESSAGES SENT - TRIGGERING HORROR FOR LEVEL 2 !!!")
		trigger_level2_horror()

func all_messages_sent() -> bool:
	return messages_sent["girlfriend"] and messages_sent["dad"] and messages_sent["mom"]

func trigger_level2_horror():
	# Signal to GameManager that level 2 horror should start
	var game_manager = get_tree().get_first_node_in_group("gamemanager")
	if game_manager and game_manager.has_method("trigger_level2_horror"):
		close_phone()
		game_manager.trigger_level2_horror()
	else:
		print("ERROR: GameManager not found or missing trigger_level2_horror method")
