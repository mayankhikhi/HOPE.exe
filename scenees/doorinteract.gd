extends Area3D

var locked = true
var player = null
var scene_changing = false

func _ready():
	body_entered.connect(_enter)
	body_exited.connect(_exit)
	add_to_group("exitdoor")

func _enter(body):
	if body.name == "ProtoController":
		player = body
		if not locked:
			player.set_interactable(self)

func _exit(body):
	if body.name == "ProtoController":
		player = null
		body.set_interactable(null)

func unlock():
	locked = false
	print("Door unlocked!")
	if player:
		player.set_interactable(self)

func interact():
	if locked:
		print("Door is locked")
		return
	
	if scene_changing:
		print("Scene change already in progress")
		return
	
	scene_changing = true
	
	# Play door open sound if it exists
	var door_open_sound = get_parent().get_node_or_null("dooropen")
	if door_open_sound:
		door_open_sound.play()
		print("Door open sound playing")
	else:
		print("Note: Door open sound not found - add AudioStreamPlayer3D named 'dooropen'")
	
	# Wait a moment for sound to start
	await get_tree().create_timer(0.5).timeout
	
	print("CHANGING SCENE TO LEVEL 2")
	
	# Change scene - use call_deferred for reliable scene change
	get_tree().call_deferred("change_scene_to_file", "res://scenees/level_test_2.scn")
