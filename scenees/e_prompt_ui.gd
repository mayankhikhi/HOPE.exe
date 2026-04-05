extends CanvasLayer
# Unified E prompt display system for interactables

var prompt_label: Label
var current_interactable = null
var show_prompt = false

func _ready():
	setup_prompt_ui()
	print("=== E Prompt UI: Ready ===")

func setup_prompt_ui():
	print("DEBUG: Setting up E prompt UI...")
	
	# Create label at bottom center
	prompt_label = Label.new()
	prompt_label.text = "[E] Interact"
	prompt_label.set_anchors_preset(Control.PRESET_BOTTOM_CENTER)
	prompt_label.offset_top = -60
	prompt_label.add_theme_font_size_override("font_size", 24)
	prompt_label.add_theme_color_override("font_color", Color.YELLOW)
	prompt_label.modulate = Color(1, 1, 1, 0)  # Start invisible
	add_child(prompt_label)
	
	print("✓ E prompt label created at bottom center")

func show_prompt_for(interactable: Node, text: String = "[E] Interact") -> void:
	"""Show prompt when player enters interactable area"""
	if not is_instance_valid(current_interactable) or current_interactable != interactable:
		current_interactable = interactable
		prompt_label.text = text
		prompt_label.modulate = Color.WHITE
		show_prompt = true
		print("✓ Prompt shown for: %s" % text)

func hide_prompt() -> void:
	"""Hide prompt when player leaves interactable area"""
	if current_interactable:
		current_interactable = null
		prompt_label.modulate = Color(1, 1, 1, 0)
		show_prompt = false
		print("✓ Prompt hidden")
