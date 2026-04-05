extends CanvasLayer

# Phone notification and chat UI system

var notification_label: Label
var chat_panel: Panel
var chat_messages_display: Label
var input_field: LineEdit
var send_button: Button
var chat_open = false
var current_chat = ""  # "girlfriend", "dad", "mom"

# Predefined messages the player will send
var player_messages = {
	"girlfriend": "FUCK YOU BITCH!",
	"dad": "I hope you die. You can never become a good father",
	"mom": "I hate you"
}

var sent_messages = {}  # Track which chats have received messages

func _ready():
	# Create notification label (bottom right)
	notification_label = Label.new()
	notification_label.text = ""
	notification_label.add_theme_font_size_override("font_size", 20)
	notification_label.custom_minimum_size = Vector2(300, 60)
	notification_label.modulate.a = 0  # Hidden at start
	add_child(notification_label)
	
	# Position: bottom right
	var viewport_size = get_viewport_rect().size
	notification_label.anchor_left = 1.0
	notification_label.anchor_top = 1.0
	notification_label.anchor_right = 1.0
	notification_label.anchor_bottom = 1.0
	notification_label.offset_left = -320
	notification_label.offset_top = -80
	
	print("✓ Phone UI initialized")

func show_notification(sender: String, message: String):
	# Show notification on bottom right
	notification_label.text = "[%s]\n%s" % [sender, message]
	notification_label.modulate = Color.WHITE
	print("📱 Notification from %s: %s" % [sender, message])
	
	# Auto-hide after 5 seconds
	await get_tree().create_timer(5.0).timeout
	notification_label.modulate.a = 0

func open_chat(contact_name: String):
	if chat_open and current_chat == contact_name:
		return  # Already open
	
	current_chat = contact_name
	chat_open = true
	print("📱 Opening chat with: %s" % contact_name)
	
	# Create or show chat interface
	if not chat_panel:
		_create_chat_interface()
	
	chat_panel.modulate = Color.WHITE
	_update_chat_display()

func close_chat():
	if chat_panel:
		chat_panel.modulate.a = 0
	chat_open = false
	current_chat = ""
	print("📱 Chat closed")

func _create_chat_interface():
	# Main chat panel
	chat_panel = Panel.new()
	chat_panel.modulate.a = 0
	chat_panel.custom_minimum_size = Vector2(400, 600)
	add_child(chat_panel)
	
	# Position: center-right
	chat_panel.anchor_left = 0.5
	chat_panel.anchor_top = 0.5
	chat_panel.anchor_right = 0.5
	chat_panel.anchor_bottom = 0.5
	chat_panel.offset_left = 100
	chat_panel.offset_top = -300
	
	# Chat messages display
	chat_messages_display = Label.new()
	chat_messages_display.text = ""
	chat_messages_display.add_theme_font_size_override("font_size", 16)
	chat_messages_display.autowrap_mode = TextServer.AUTOWRAP_WORD
	chat_messages_display.custom_minimum_size = Vector2(380, 450)
	chat_panel.add_child(chat_messages_display)
	
	# Input field
	input_field = LineEdit.new()
	input_field.placeholder_text = "Type message..."
	input_field.custom_minimum_size = Vector2(380, 40)
	chat_panel.add_child(input_field)
	
	# Send button
	send_button = Button.new()
	send_button.text = "SEND"
	send_button.custom_minimum_size = Vector2(380, 40)
	send_button.pressed.connect(_on_send_pressed)
	chat_panel.add_child(send_button)
	
	# Layout
	var vbox = VBoxContainer.new()
	vbox.add_child(chat_messages_display)
	vbox.add_child(input_field)
	vbox.add_child(send_button)
	chat_panel.add_child(vbox)

func _update_chat_display():
	if not chat_messages_display:
		return
	
	var contact = current_chat
	var display_text = "[Chat with %s]\n\n" % contact.to_upper()
	
	if contact in sent_messages:
		display_text += "You: %s\n" % sent_messages[contact]
	else:
		display_text += "(No messages yet)"
	
	chat_messages_display.text = display_text

func _on_send_pressed():
	if current_chat == "":
		return
	
	# Send the predefined message
	var message = player_messages[current_chat]
	sent_messages[current_chat] = message
	
	print("✓ Sent to %s: %s" % [current_chat, message])
	_update_chat_display()
	
	# Check if all 3 messages sent
	if sent_messages.size() >= 3:
		print("!!! ALL MESSAGES SENT - HORROR STARTING !!!")
		close_chat()
		trigger_level2_horror()

func trigger_level2_horror():
	# Trigger horror sequence in level 2
	var gamemanager = get_tree().root.find_child("GameManager", true, false)
	if gamemanager and gamemanager.has_method("start_level2_horror"):
		gamemanager.start_level2_horror()
	else:
		print("ERROR: Level2 horror method not found")

func _process(delta):
	# Press P to toggle phone
	if Input.is_action_just_pressed("ui_select"):  # Will replace with P key mapping
		if chat_open:
			close_chat()
		else:
			# Default to girlfriend chat
			open_chat("girlfriend")
