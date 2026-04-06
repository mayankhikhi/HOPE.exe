extends Control

var button_type = null
var is_transitioning = false

func _ready():
	# Connect buttons to their handlers
	var play_button = $Panel/Button
	var options_button = $Panel/Button2
	var quit_button = $Panel/Button3
	
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
		play_button.grab_focus()  # Focus on Play button by default
		print("✓ Play button connected")
	
	if options_button:
		options_button.pressed.connect(_on_options_pressed)
		print("✓ Options button connected")
	
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
		print("✓ Quit button connected")

func _on_play_pressed():
	if is_transitioning:
		return
	is_transitioning = true
	button_type = "play"
	print("Play button pressed - loading level...")
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenees/level_test.scn")

func _on_options_pressed():
	if is_transitioning:
		return
	is_transitioning = true
	button_type = "options"
	print("Options button pressed")
	await get_tree().create_timer(0.3).timeout
	# TODO: Create options scene at res://scenees/options.tscn
	print("Options scene not yet created - returning to menu")
	is_transitioning = false

func _on_quit_pressed():
	if is_transitioning:
		return
	print("Quit button pressed - closing game...")
	get_tree().quit()
