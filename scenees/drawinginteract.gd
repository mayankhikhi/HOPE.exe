extends Area3D

@export var type := "drawing"
var is_destroyed = false
var player = null

func _ready():
	body_entered.connect(_enter)
	body_exited.connect(_exit)
	add_to_group("interactable")

func _enter(body):
	if body.name == "ProtoController":
		player = body
		player.set_interactable(self)

func _exit(body):
	if body.name == "ProtoController":
		if player:
			player.set_interactable(null)
		player = null

func interact():
	if is_destroyed:
		return
	
	is_destroyed = true
	var drawing = get_parent()

	print("Drawing destroyed: ", drawing.name)
	
	# Play tear sound if available
	var tear_sound = drawing.get_node_or_null("TearSound")
	if tear_sound:
		tear_sound.play()
		print("Tear sound playing")
	else:
		print("Note: TearSound not found - add AudioStreamPlayer3D named 'TearSound' for sound")
	
	# Animate the drawing disappearing - works for 3D nodes
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	
	# Scale down to make it disappear (works for 3D objects)
	tween.tween_property(drawing, "scale", Vector3.ZERO, 0.5)
	await tween.finished

	drawing.queue_free()
	
	GameManager.register_destroy("drawing")
